# Otfha - Agricultural Marketplace Platform (Flutter App)

## 📱 About
Otfha is a comprehensive agricultural marketplace platform built with Flutter. It helps farmers manage their crops, resources, track expenses, diagnose plant diseases, and access agricultural marketplace.

## 🏗️ **New Project Architecture**

This project has been restructured following **Clean Architecture** principles and **Feature-Based Organization** for better scalability, maintainability, and testability.

### **Project Structure**

```
lib/
├── core/                          # Core functionality (shared across features)
│   ├── config/                    # App configuration & routes
│   ├── theme/                     # Theme & colors
│   ├── constants/                 # String & asset constants
│   ├── models/                    # Shared domain models
│   ├── error/                     # Error handling
│   └── utils/                     # Utility functions
│
├── features/                      # Feature-based modules
│   ├── auth/                     # Authentication
│   ├── home/                     # Home dashboard
│   ├── crops/                    # Crop management
│   ├── market/                   # Marketplace
│   ├── schedule/                 # Task scheduling
│   ├── resources/                # Resource management
│   ├── expenses/                 # Expense tracking
│   ├── diagnosis/                # Disease diagnosis
│   ├── loans/                    # Loan applications
│   └── weather/                  # Weather information
│
├── shared/                        # Shared UI components
│   ├── widgets/                  # Reusable widgets
│   └── providers/                # Shared state providers
│
└── main.dart                      # App entry point
```

### **Key Features of New Structure**

#### ✅ **Completed Restructuring**
- [x] **Core Infrastructure**: Configuration, theme, constants, utilities
- [x] **Models Layer**: All domain models with Equatable support
- [x] **Error Handling**: Custom exceptions and failures
- [x] **Utilities**: Validators, formatters, helpers, logger
- [x] **Shared Widgets**: Buttons, forms, cards, loading, dialogs
- [x] **Theme System**: Centralized colors and theming

#### 🚧 **In Progress**
- [ ] **Feature Migration**: Moving screens to feature-based structure
- [ ] **Repository Pattern**: Data layer abstraction
- [ ] **State Management**: Provider implementation for each feature
- [ ] **Screen Migration**: Reorganizing existing screens

## 🎯 Features

### Current Features
- ✅ **Authentication**
  - Email/Password login
  - Google Sign-In
  - Password recovery
  - User registration

- ✅ **Crop Management**
  - Add and track crops
  - Monitor growth stages
  - Harvest predictions
  - Crop history

- ✅ **Marketplace**
  - Browse products
  - Shopping cart
  - Product search
  - Checkout process

- ✅ **Task Scheduling**
  - Create farm tasks
  - Calendar view
  - Task reminders
  - Completion tracking

- ✅ **Resource Management**
  - Equipment tracking
  - Tools inventory
  - Resource status
  - Purchase history

- ✅ **Expense Tracking**
  - Record expenses
  - Category management
  - Expense reports
  - Financial overview

- ✅ **Disease Diagnosis**
  - AI-powered plant disease detection
  - Treatment recommendations
  - Prevention tips
  - Diagnosis history

- ✅ **Weather Information**
  - Real-time weather
  - Location-based forecasts
  - Weather alerts
  - Farming insights

- ✅ **Loan Applications**
  - Apply for agricultural loans
  - Track application status
  - Loan calculator

## 🛠️ Technologies Used

### **Framework & Language**
- Flutter 3.9.0
- Dart

### **Backend & Database**
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Cloud Functions

### **State Management**
- Provider

### **Architecture Patterns**
- Clean Architecture
- Repository Pattern
- MVVM (Model-View-ViewModel)

### **Key Packages**
- `google_fonts` - Typography
- `equatable` - Value equality
- `dartz` - Functional programming
- `intl` - Internationalization
- `image_picker` - Image selection
- `geolocator` - Location services
- `http` - Network requests

## 📂 Code Organization

### **Core Module**
Shared functionality used across all features:
- `config/` - App configuration and routing
- `theme/` - UI theming and colors
- `constants/` - App-wide constants
- `models/` - Domain models
- `error/` - Error handling
- `utils/` - Utility functions

### **Feature Modules**
Each feature follows this structure:
```
feature_name/
├── data/
│   ├── datasources/    # API & local data sources
│   ├── repositories/   # Repository implementations
│   └── models/         # Data transfer objects
├── domain/
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business logic
└── presentation/
    ├── providers/      # State management
    ├── screens/        # UI screens
    └── widgets/        # Feature-specific widgets
```

### **Shared Module**
Reusable UI components:
- `widgets/buttons/` - Custom buttons
- `widgets/forms/` - Form components
- `widgets/cards/` - Card layouts
- `widgets/loading/` - Loading indicators
- `widgets/dialogs/` - Dialog components

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.0)
- Dart SDK
- Android Studio / VS Code
- Firebase Project

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd otfha
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)
   - Update `firebase_options.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Usage Examples

### Using Custom Widgets

```dart
// Custom Button
PrimaryButton(
  text: 'Save',
  onPressed: () => _save(),
  icon: Icons.save,
)

// Custom Text Field
CustomTextField(
  label: 'Email',
  controller: _emailController,
  validator: Validators.email,
)

// Password Field
PasswordField(
  controller: _passwordController,
  validator: Validators.password,
)
```

### Using Utilities

```dart
// Validation
validator: Validators.combine([
  (value) => Validators.required(value, fieldName: 'Email'),
  Validators.email,
])

// Formatting
Text(Formatters.formatCurrency(price))
Text(Formatters.formatDate(DateTime.now()))

// Helpers
Helpers.showSuccess(context, 'Saved successfully!');
if (await Helpers.showDeleteConfirmDialog(context)) {
  // Delete item
}
```

### Using Models

```dart
// Create a model
final crop = Crop(
  id: 'crop-123',
  userId: 'user-456',
  name: 'Wheat',
  type: 'Cereal',
  plantingDate: DateTime.now(),
  expectedHarvestDate: DateTime.now().add(Duration(days: 90)),
  farmArea: 10.5,
  farmLocation: 'Field A',
  status: 'Planted',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Update a model
final updatedCrop = crop.copyWith(status: 'Growing');
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/utils/validators_test.dart
```

## 📝 Documentation

- [Restructuring Guide](./RESTRUCTURING_GUIDE.md) - Detailed architecture documentation
- [Firebase Backend Guide](./FIREBASE_BACKEND_GUIDE.md) - Backend implementation guide

## 🤝 Contributing

1. Follow the existing code structure
2. Use the shared widgets and utilities
3. Follow clean architecture principles
4. Write tests for new features
5. Document complex logic

### Code Style
- Use `snake_case` for file names
- Use `PascalCase` for class names
- Use `camelCase` for variables and functions
- Follow Flutter's official style guide

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

- Development Team: O-TFha Agricultural Platform

## 📞 Support

For support and questions:
- Open an issue on GitHub
- Contact the development team

---

**Note**: This app is currently under active restructuring to improve code quality, maintainability, and scalability. See [RESTRUCTURING_GUIDE.md](./RESTRUCTURING_GUIDE.md) for more details.
