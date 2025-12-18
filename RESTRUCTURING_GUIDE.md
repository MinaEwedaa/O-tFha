# Flutter App Restructuring Guide

## Overview
This document outlines the comprehensive restructuring of the Otfha Agricultural Marketplace Flutter application following clean architecture and best practices.

## New Project Structure

```
lib/
├── core/                          # Core functionality shared across features
│   ├── config/                    # App configuration
│   │   ├── app_config.dart       # Application constants and configuration
│   │   └── routes.dart           # Route definitions and navigation
│   ├── theme/                     # Theming
│   │   ├── app_theme.dart        # Theme configuration
│   │   └── app_colors.dart       # Color palette
│   ├── constants/                 # Constants
│   │   ├── app_strings.dart      # String constants
│   │   └── asset_paths.dart      # Asset path constants
│   ├── models/                    # Shared domain models
│   │   ├── user_model.dart
│   │   ├── crop_model.dart
│   │   ├── resource_model.dart
│   │   ├── product_model.dart
│   │   ├── cart_item_model.dart
│   │   ├── expense_model.dart
│   │   ├── weather_model.dart
│   │   └── disease_prediction_model.dart
│   ├── error/                     # Error handling
│   │   ├── exceptions.dart       # Custom exception classes
│   │   └── failures.dart         # Failure classes for error handling
│   └── utils/                     # Utility classes
│       ├── validators.dart       # Form validation utilities
│       ├── formatters.dart       # Data formatting utilities
│       ├── helpers.dart          # General helper functions
│       └── logger.dart           # Logging utilities
│
├── features/                      # Feature-based modules
│   ├── auth/                     # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/      # Firebase auth data source
│   │   │   ├── repositories/     # Repository implementation
│   │   │   └── models/           # Data transfer objects
│   │   ├── domain/
│   │   │   ├── entities/         # Business entities
│   │   │   ├── repositories/     # Repository interfaces
│   │   │   └── usecases/         # Business logic
│   │   └── presentation/
│   │       ├── providers/        # State management
│   │       ├── screens/          # UI screens
│   │       └── widgets/          # Feature-specific widgets
│   │
│   ├── home/                     # Home dashboard feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── crops/                    # Crop management feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── market/                   # Marketplace feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── schedule/                 # Task scheduling feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── resources/                # Resource management feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── expenses/                 # Expense tracking feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── diagnosis/                # Plant disease diagnosis feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── loans/                    # Loan application feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── weather/                  # Weather information feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/                        # Shared UI components
│   ├── widgets/                   # Reusable widgets
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   ├── forms/
│   │   └── loading/
│   └── providers/                 # Shared providers
│
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # App entry point
```

## Key Improvements

### 1. **Clean Architecture**
- Separation of concerns with data, domain, and presentation layers
- Repository pattern for data access
- Use cases for business logic
- Dependency injection ready

### 2. **Feature-Based Organization**
- Each feature is self-contained
- Easy to locate and modify feature-specific code
- Better scalability for team collaboration

### 3. **Improved Code Quality**
- Equatable for value comparison
- Immutable models with copyWith methods
- Type-safe constants
- Comprehensive error handling

### 4. **Better State Management**
- Provider pattern for state management
- Separation of business logic from UI
- Testable state management

### 5. **Reusable Components**
- Shared widgets for common UI elements
- Utility classes for validation, formatting
- Consistent theming

### 6. **Enhanced Developer Experience**
- Clear naming conventions
- Comprehensive documentation
- Easy to test structure
- Better code navigation

## Migration Steps

### Phase 1: Core Setup ✅
- [x] Create core directory structure
- [x] Set up configuration files (app_config, routes, theme)
- [x] Create utility classes (validators, formatters, helpers, logger)
- [x] Define error handling (exceptions, failures)
- [x] Create core models

### Phase 2: Feature Migration (In Progress)
- [ ] Move and refactor authentication feature
- [ ] Reorganize home dashboard
- [ ] Migrate crops management
- [ ] Restructure marketplace
- [ ] Refactor schedule management
- [ ] Move resources management
- [ ] Migrate expenses tracking
- [ ] Restructure diagnosis feature
- [ ] Move loan application
- [ ] Migrate weather feature

### Phase 3: UI Components
- [ ] Extract reusable widgets into shared/widgets
- [ ] Create button components
- [ ] Build card components
- [ ] Develop form components
- [ ] Create dialog components
- [ ] Build loading indicators

### Phase 4: State Management
- [ ] Implement providers for each feature
- [ ] Connect UI to state management
- [ ] Add error handling in providers
- [ ] Implement loading states

### Phase 5: Testing & Documentation
- [ ] Write unit tests for utilities
- [ ] Add integration tests for features
- [ ] Document architecture decisions
- [ ] Create component documentation

## Best Practices Implemented

### 1. **Naming Conventions**
- Files: snake_case (e.g., `user_model.dart`)
- Classes: PascalCase (e.g., `UserModel`)
- Variables/Functions: camelCase (e.g., `getUserData`)
- Constants: SCREAMING_SNAKE_CASE or camelCase with const (e.g., `AppConfig.apiBaseUrl`)

### 2. **Code Organization**
- One class per file
- Related functionality grouped together
- Clear separation of concerns
- Minimal file length (< 500 lines)

### 3. **Error Handling**
- Custom exception classes
- Failure classes for error propagation
- Try-catch blocks in appropriate places
- User-friendly error messages

### 4. **State Management**
- Provider for dependency injection
- ChangeNotifier for reactive state
- Separation of business logic from UI
- Immutable state where possible

### 5. **Testing**
- Testable architecture with dependency injection
- Mock-friendly repository pattern
- Unit testable utilities and validators
- Integration testable features

## Dependencies to Add

Add these to `pubspec.yaml`:

```yaml
dependencies:
  # State Management
  provider: ^6.1.2
  
  # Equality
  equatable: ^2.0.5
  
  # Functional Programming
  dartz: ^0.10.1  # For Either type in error handling
```

## Usage Examples

### Using Validators
```dart
TextFormField(
  validator: Validators.combine([
    (value) => Validators.required(value, fieldName: 'Email'),
    Validators.email,
  ]),
)
```

### Using Formatters
```dart
Text(Formatters.formatCurrency(price))
Text(Formatters.formatDate(DateTime.now()))
Text(Formatters.formatRelativeTime(timestamp))
```

### Using Helpers
```dart
// Show success message
Helpers.showSuccess(context, 'Saved successfully!');

// Confirm action
if (await Helpers.showDeleteConfirmDialog(context)) {
  // Delete item
}

// Pick image
final image = await Helpers.showImageSourceDialog(context);
```

### Using Models
```dart
// Create a crop
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

// Update a crop
final updatedCrop = crop.copyWith(status: 'Growing');
```

## Next Steps

1. **Continue Feature Migration**: Move existing screens into feature-based structure
2. **Extract Widgets**: Identify and extract reusable UI components
3. **Implement Repositories**: Create repository layer for all data sources
4. **Add Use Cases**: Implement business logic in use case classes
5. **Setup Providers**: Create providers for state management
6. **Write Tests**: Add unit and integration tests
7. **Update Documentation**: Document each feature and component

## Notes

- The old structure in `lib/screens` and `lib/services` will be gradually migrated
- Keep both old and new structures until migration is complete
- Test thoroughly after migrating each feature
- Update imports as files are moved

## Resources

- [Flutter Clean Architecture](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Equatable Package](https://pub.dev/packages/equatable)
- [Flutter Best Practices](https://flutter.dev/docs/development/ui/assets-and-images)


















