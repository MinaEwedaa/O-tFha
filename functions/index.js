const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const vision = require("@google-cloud/vision");

// Initialize Firebase Admin
admin.initializeApp();

// Create a Vision API client
const visionClient = new vision.ImageAnnotatorClient();

/**
 * Annotate an image using Google Cloud Vision API
 * This function is callable from authenticated Flutter clients
 */
exports.annotateImage = onCall(async (request) => {
  // Check if user is authenticated
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const requestData = request.data;

  // Validate input
  if (!requestData || !requestData.image || !requestData.image.content) {
    throw new HttpsError(
        "invalid-argument",
        "The function must be called with an image object containing content.",
    );
  }

  try {
    const imageContent = requestData.image.content;
    const features = requestData.features || [
      {type: "LABEL_DETECTION", maxResults: 10},
    ];

    // Prepare the request for Cloud Vision API
    const visionRequest = {
      image: {content: imageContent},
      features: features,
    };

    // Call Cloud Vision API
    const [result] = await visionClient.annotateImage(visionRequest);

    console.log("Vision API response received successfully");

    // Return the result
    return {
      success: true,
      data: result,
      timestamp: admin.firestore.Timestamp.now().toDate().toISOString(),
    };
  } catch (error) {
    console.error("Vision API error:", error);
    throw new HttpsError(
        "internal",
        "Failed to process image with Cloud Vision API",
        error.message,
    );
  }
});

/**
 * Detect plant diseases using Cloud Vision API
 * Specialized version for plant disease detection
 */
exports.detectPlantDisease = onCall(async (request) => {
  // Check if user is authenticated
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const requestData = request.data;

  // Validate input
  if (!requestData || !requestData.image || !requestData.image.content) {
    throw new HttpsError(
        "invalid-argument",
        "The function must be called with an image object containing content.",
    );
  }

  try {
    const imageContent = requestData.image.content;

    // Prepare the request with multiple features for comprehensive analysis
    const visionRequest = {
      image: {content: imageContent},
      features: [
        {type: "LABEL_DETECTION", maxResults: 10},
        {type: "IMAGE_PROPERTIES"},
        {type: "OBJECT_LOCALIZATION", maxResults: 5},
      ],
    };

    // Call Cloud Vision API
    const [result] = await visionClient.annotateImage(visionRequest);

    // Process labels to identify plant-related information
    const labels = result.labelAnnotations || [];
    const objects = result.localizedObjectAnnotations || [];
    const imageProps = result.imagePropertiesAnnotation;

    // Filter for plant and disease-related labels
    const plantLabels = labels.filter((label) =>
      label.description.toLowerCase().match(
          /plant|leaf|disease|fungus|blight|spot|wilt|rot|mold|pest|insect/,
      ),
    );

    // Determine if plant appears healthy or diseased
    const diseaseKeywords = [
      "disease",
      "fungus",
      "blight",
      "spot",
      "wilt",
      "rot",
      "mold",
      "pest",
      "damage",
      "brown",
      "yellow",
      "dead",
    ];
    const healthyKeywords = ["healthy", "green", "fresh", "vibrant"];

    let isDiseased = false;
    let isHealthy = false;
    let topDisease = null;
    let confidence = 0;

    for (const label of labels) {
      const desc = label.description.toLowerCase();
      const score = label.score;

      if (diseaseKeywords.some((keyword) => desc.includes(keyword))) {
        isDiseased = true;
        if (score > confidence) {
          confidence = score;
          topDisease = label.description;
        }
      }

      if (healthyKeywords.some((keyword) => desc.includes(keyword))) {
        isHealthy = true;
      }
    }

    // Determine diagnosis
    let diagnosis = "Unknown";
    if (isDiseased && topDisease) {
      diagnosis = topDisease;
    } else if (isHealthy && !isDiseased) {
      diagnosis = "Healthy Plant";
    } else if (labels.length > 0) {
      diagnosis = labels[0].description;
      confidence = labels[0].score;
    }

    // Store prediction in Firestore for tracking
    const predictionRef = await admin.firestore().collection("predictions").add({
      userId: request.auth.uid,
      diagnosis: diagnosis,
      confidence: confidence,
      labels: labels.map((l) => ({description: l.description, score: l.score})),
      objects: objects.map((o) => ({name: o.name, score: o.score})),
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      source: "cloud_vision",
    });

    console.log("Prediction saved with ID:", predictionRef.id);

    // Return structured result
    return {
      success: true,
      data: {
        disease: diagnosis,
        confidence: confidence,
        isHealthy: isHealthy && !isDiseased,
        predictionId: predictionRef.id,
        topPredictions: labels.slice(0, 5).map((label) => ({
          className: label.description,
          confidence: label.score,
        })),
        allLabels: labels,
        detectedObjects: objects,
        imageProperties: imageProps,
      },
      timestamp: admin.firestore.Timestamp.now().toDate().toISOString(),
    };
  } catch (error) {
    console.error("Plant disease detection error:", error);
    throw new HttpsError(
        "internal",
        "Failed to detect plant disease",
        error.message,
    );
  }
});

