"""
Local TensorFlow Model Server
Runs your .h5 model locally and provides HTTP endpoint for Flutter app
Usage: python local_model_server.py
"""
import tensorflow as tf
import numpy as np
from flask import Flask, request, jsonify
from PIL import Image
import io

app = Flask(__name__)

# Load your model
MODEL_PATH = r"C:\Users\minas\OneDrive\Desktop\otfha\assets\models\apple_model (1).h5"
model = None

# Class labels - UPDATE THESE with your actual classes
CLASS_LABELS = [
    "Apple Scab",
    "Apple Black Rot",
    "Apple Cedar Rust",
    "Apple Healthy",
]

def load_model():
    global model
    try:
        # Load with legacy mode for older Keras models
        model = tf.keras.models.load_model(MODEL_PATH, compile=False)
        print(f"✅ Model loaded successfully from {MODEL_PATH}")
        print(f"Input shape: {model.input_shape}")
        print(f"Output shape: {model.output_shape}")
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        print("\n💡 Trying alternative loading method...")
        try:
            # Try loading with custom objects and safe mode
            import h5py
            model = tf.keras.models.load_model(
                MODEL_PATH,
                compile=False,
                safe_mode=False
            )
            print(f"✅ Model loaded successfully with safe_mode=False")
        except Exception as e2:
            print(f"❌ Alternative method also failed: {e2}")
            raise

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400
    
    file = request.files['image']
    
    try:
        # Load and preprocess image
        img = Image.open(io.BytesIO(file.read()))
        img = img.convert('RGB')
        img = img.resize((224, 224))  # Resize to model input size
        img_array = np.array(img) / 255.0  # Normalize to [0, 1]
        img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension
        
        # Run prediction
        predictions = model.predict(img_array)[0]
        
        # Create response
        results = []
        for i, prob in enumerate(predictions):
            if i < len(CLASS_LABELS):
                results.append({
                    'name': CLASS_LABELS[i],
                    'confidence': float(prob)
                })
        
        # Sort by confidence
        results.sort(key=lambda x: x['confidence'], reverse=True)
        
        return jsonify({
            'success': True,
            'data': {
                'disease': results[0]['name'],
                'confidence': results[0]['confidence'],
                'results': results,
                'prediction_id': str(np.random.randint(100000, 999999)),
                'plant_common_name': 'Apple',
                'plant_scientific_name': 'Malus domestica'
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy', 'model_loaded': model is not None})

if __name__ == '__main__':
    print("🚀 Starting Local Model Server...")
    load_model()
    print("\n📡 Server running on http://localhost:5000")
    print("   Use this in your Flutter app as the API endpoint")
    print("\n   Press Ctrl+C to stop\n")
    app.run(host='0.0.0.0', port=5000, debug=False)

