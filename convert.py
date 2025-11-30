import tensorflow as tf
import os

# Path to your .h5 model
model_path = r"C:\Users\minas\OneDrive\Desktop\otfha\assets\models\apple_model (1).h5"

# Check if model exists
if not os.path.exists(model_path):
    print(f"Error: Model file not found at {model_path}")
    exit(1)

print(f"Loading model from: {model_path}")

try:
    # Load the Keras model
    model = tf.keras.models.load_model(model_path)
    print("Model loaded successfully!")
    
    # Print model summary
    print("\nModel Summary:")
    model.summary()
    
    # Convert to TFLite with quantization for smaller size
    print("\nConverting to TFLite with quantization...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Apply optimizations to reduce model size
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert the model
    tflite_model = converter.convert()
    
    # Save the quantized TFLite model
    output_path = r"C:\Users\minas\OneDrive\Desktop\otfha\assets\models\apple_model.tflite"
    with open(output_path, "wb") as f:
        f.write(tflite_model)
    
    # Calculate and display file sizes
    original_size = os.path.getsize(model_path) / (1024 * 1024)  # MB
    tflite_size = os.path.getsize(output_path) / (1024 * 1024)   # MB
    
    print(f"\n✅ Conversion successful!")
    print(f"Original .h5 size: {original_size:.2f} MB")
    print(f"TFLite quantized size: {tflite_size:.2f} MB")
    print(f"Size reduction: {((original_size - tflite_size) / original_size * 100):.1f}%")
    print(f"\nOutput saved to: {output_path}")
    
    # Create a labels.txt file if the model has class names
    print("\n📝 Creating labels.txt file...")
    labels_path = r"C:\Users\minas\OneDrive\Desktop\otfha\assets\models\labels.txt"
    
    # Try to get class names from the model (if available)
    # You should replace these with your actual class labels
    default_labels = [
        "0 Apple Scab",
        "1 Apple Black Rot", 
        "2 Apple Cedar Rust",
        "3 Apple Healthy"
    ]
    
    with open(labels_path, "w") as f:
        for label in default_labels:
            f.write(label + "\n")
    
    print(f"✅ Labels file created: {labels_path}")
    print("\n⚠️  IMPORTANT: Update labels.txt with your actual class names!")
    
except Exception as e:
    print(f"\n❌ Error during conversion: {e}")
    print("\nMake sure you have TensorFlow installed:")
    print("pip install tensorflow")

