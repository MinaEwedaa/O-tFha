# OtFha - Plant Disease Detection App

Flutter mobile app with ML-powered plant disease detection using PyTorch and a Flask backend API.

## 🌟 Overview

- **Flutter App**: Cross-platform mobile app (Android/iOS)
- **ML Backend**: Flask API with PyTorch disease detection model
- **Firebase**: Authentication and data storage
- **Dataset**: PlantVillage 52K+ plant disease images
- **Model**: ResNet18 trained on 38 disease classes

## 🚀 Quick Start

### 1. Clone & Setup Backend

```bash
# Clone the repo
git clone <your-repo-url>
cd otfha

# Setup Python environment
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Get ML Assets (Important!)

**The trained models and dataset are stored outside the repo** to keep it lean:

1. Get the `external_assets` folder (from Google Drive/team member)
2. Place it at: `C:\Users\<you>\OneDrive\Desktop\external_assets\`

Structure should be:
```
Desktop/
├── external_assets/              ← Models & dataset here
│   ├── PlantVillage-Dataset/
│   └── models/
│       ├── plant_disease_best.pt
│       └── classes.json
└── otfha/                        ← Your cloned repo
    ├── backend/
    └── lib/
```

### 3. Start Backend Server

```bash
cd backend
.\START_FLASK_NOW.bat
# Or manually:
venv\Scripts\activate
python app.py
```

Server runs at: `http://localhost:5000`

### 4. Run Flutter App

```bash
# Get dependencies
flutter pub get

# Run on Android emulator
flutter emulators --launch Pixel_API_33
flutter run

# Or run on your physical device
flutter run
```

## 📁 Project Structure

```
otfha/
├── lib/                          # Flutter app source
│   ├── main.dart                # Entry point
│   ├── screens/                 # UI screens
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── camera_screen.dart  # Image capture & upload
│   │   └── result_screen.dart  # Disease prediction results
│   └── services/
│       ├── auth_service.dart   # Firebase auth
│       └── ml_service.dart     # ML API calls
│
├── backend/                     # Flask API server
│   ├── app.py                   # Main server
│   ├── app/
│   │   ├── routes/              # API endpoints
│   │   ├── services/            # ML inference
│   │   │   └── plant_disease_prediction_service.py
│   │   └── utils/               # Helpers
│   ├── scripts/
│   │   └── train_local.py       # Train new models
│   ├── requirements.txt
│   └── venv/                    # Python packages (693 MB - not in Git)
│
├── android/                     # Android build config
├── ios/                         # iOS build config
└── assets/                      # App images/icons

NOT IN GIT (regenerated or external):
├── build/                       # Flutter builds (9.5 GB - ignored)
├── .dart_tool/                  # Flutter cache (ignored)
└── ../external_assets/          # ML assets (outside repo)
    ├── PlantVillage-Dataset/   # 52K images
    └── models/                  # Trained models
```

## 🔧 API Endpoints

### Health & Status
- `GET /health` - Server health check
- `GET /metrics` - Server metrics

### ML Inference
- `POST /v1/predict/disease` - Predict plant disease
  ```json
  {
    "image": <multipart file>,
    "user_id": "optional"
  }
  ```
  Response:
  ```json
  {
    "success": true,
    "disease": "Tomato___Late_blight",
    "confidence": 0.95,
    "top_predictions": [...]
  }
  ```

### Data
- `GET /v1/plants/{id}` - Plant info
- `GET /v1/diseases/{id}` - Disease info

## 🤖 ML Model Details

### Dataset
- **Source**: PlantVillage Dataset
- **Images**: 52,000+ labeled plant disease images
- **Classes**: 38 disease classes across 14 plant species
- **Location**: `../external_assets/PlantVillage-Dataset/`

### Model
- **Architecture**: ResNet18 (pretrained on ImageNet)
- **Framework**: PyTorch 2.0+
- **Input**: 224x224 RGB images
- **Output**: 38-class softmax predictions
- **Location**: `../external_assets/models/plant_disease_best.pt`

### Training

To train a new model:

```bash
cd backend
venv\Scripts\activate
python scripts/train_local.py --epochs 20 --batch-size 32

# Quick test (2 classes, 5 epochs):
python scripts/train_local.py --subset 2 --epochs 5
```

## 🔐 Firebase Setup

The app uses Firebase for:
- **Authentication**: Email/password and Google Sign-In
- **Firestore**: User data and prediction history
- **Storage**: User uploaded images

Config file: `lib/firebase_options.dart`

To set up Firebase:
1. Create project at https://console.firebase.google.com
2. Add Android app (package: `com.OtFha`)
3. Download `google-services.json` → `android/app/`
4. Run: `flutterfire configure`

## 📱 Features

- ✅ User authentication (Email + Google)
- ✅ Camera capture & gallery upload
- ✅ Real-time disease prediction
- ✅ Confidence scores & top predictions
- ✅ Disease info & treatment recommendations
- ✅ Prediction history
- ✅ Offline capability (cached models)

## 🛠️ Development

### Backend Development

```bash
cd backend
venv\Scripts\activate
python app.py  # Runs on localhost:5000
```

### Flutter Development

```bash
# Hot reload during development
flutter run
# Press 'r' to hot reload
# Press 'R' to hot restart

# Build APK
flutter build apk --release

# Build Windows app
flutter build windows --release
```

### Testing

```bash
# Backend API test
curl http://localhost:5000/health

# Test prediction with image
curl -X POST http://localhost:5000/v1/predict/disease \
  -F "image=@path/to/leaf.jpg"

# Flutter tests
flutter test
```

## 📦 Dependencies

### Backend (Python)
- **Flask** 2.3+ - Web framework
- **PyTorch** 2.0+ - ML framework (428 MB)
- **torchvision** 0.15+ - Image models
- **Pillow** 10.0+ - Image processing
- **Firebase Admin** 6.0+ - Firebase integration
- **NumPy**, **tqdm** - Utilities

**Total venv size**: ~693 MB (PyTorch = 62% of this)

### Flutter (Dart)
- **firebase_core** & **firebase_auth** - Firebase
- **cloud_firestore** - Database
- **image_picker** - Camera/gallery
- **http** - API calls
- **google_fonts** - UI fonts

## 🗂️ Git Repository

This repo is optimized for GitHub:
- **Size**: ~200 MB (source code only)
- **Excluded**: Build artifacts (9.5 GB), Python venv (693 MB), ML assets (external)

What's NOT tracked:
```gitignore
build/              # Flutter builds
backend/venv/       # Python packages
../external_assets/ # ML models & dataset
*.pt, *.pth         # Model files
```

## 🚨 Troubleshooting

### Backend Issues

**Port 5000 already in use:**
```bash
# Check what's using the port
netstat -ano | findstr :5000
# Or change port in .env: PORT=8080
```

**Model not found:**
```bash
# Check external_assets location
ls ../external_assets/models/
# Should contain: plant_disease_best.pt, classes.json
```

**venv activation fails:**
```bash
# Windows PowerShell:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Then retry: venv\Scripts\activate
```

### Flutter Issues

**Emulator not showing:**
```bash
# Launch manually from Android Studio
# Or use: flutter emulators --launch Pixel_API_33
```

**Build fails:**
```bash
flutter clean
flutter pub get
flutter build <platform>
```

**Firebase errors:**
```bash
# Ensure google-services.json is in android/app/
# Run: flutterfire configure
```

### ML/API Issues

**Predictions fail:**
1. Check backend is running: http://localhost:5000/health
2. For Android emulator, app uses: `http://10.0.2.2:5000`
3. For physical device, use your PC's local IP

**Model loading slow:**
- First load takes 30-60 seconds (PyTorch model initialization)
- Subsequent predictions are fast (~1-2 seconds)

## 🔄 Deployment

### For Team Members

When cloning this repo:
1. Clone the repository
2. Setup backend: `cd backend; python -m venv venv; pip install -r requirements.txt`
3. Setup Flutter: `flutter pub get`
4. **Get ML assets**: Obtain `external_assets` folder separately
5. Place `external_assets` one level above project directory

### For Production

**Not production-ready as-is.** For production deployment:
- Use proper server (Gunicorn/uWSGI, not Flask dev server)
- Add authentication/API keys
- Use cloud storage for models
- Implement proper error handling
- Add monitoring/logging
- Use HTTPS

## 📊 Model Performance

Current model (`plant_disease_best.pt`):
- **Accuracy**: ~95% on test set
- **Classes**: 38 diseases
- **Inference time**: ~1-2 seconds (CPU)
- **Model size**: 45 MB

To improve:
- Fine-tune on more epochs
- Use larger model (ResNet50, EfficientNet)
- Add data augmentation
- Collect more training data

## 💡 Tips

1. **Use demo mode** for UI development without ML model
2. **Keep external_assets separate** - never commit to Git
3. **Backend venv is 693 MB** - this is normal for PyTorch
4. **First prediction is slow** - model loads on first request
5. **Use localhost:5000** for testing on Windows
6. **Use 10.0.2.2:5000** for Android emulator

## 🤝 Contributing

1. Keep ML assets in `external_assets/` (outside repo)
2. Don't commit `build/`, `venv/`, or `.dart_tool/`
3. Follow Flutter style guide
4. Test API endpoints before pushing
5. Document new features in code

## 📄 License

[Your License Here]

## 🆘 Need Help?

- **API not responding**: Check `backend/logs/` for errors
- **Model errors**: Verify `external_assets/models/` exists
- **Build issues**: Run `flutter doctor` for diagnostics
- **Firebase issues**: Check `google-services.json` is present

---

**Ready to develop!** Start the backend, run the Flutter app, and start detecting plant diseases! 🌱

For questions or issues, check the troubleshooting section above.
