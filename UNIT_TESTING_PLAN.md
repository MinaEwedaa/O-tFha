# 🧪 OTFHA Mobile App - Unit Testing Plan

## 📋 Overview

This document outlines the comprehensive unit testing strategy for the OTFHA Agricultural Marketplace Flutter mobile application. The plan focuses on testing business logic, models, utilities, and services in isolation.

---

## 📁 Project Testing Structure

```
otfha/
├── test/
│   ├── unit/                          # Unit tests
│   │   ├── core/
│   │   │   ├── models/                # Model tests
│   │   │   │   ├── user_model_test.dart
│   │   │   │   ├── product_model_test.dart
│   │   │   │   ├── order_model_test.dart
│   │   │   │   ├── cart_item_model_test.dart
│   │   │   │   ├── crop_model_test.dart
│   │   │   │   ├── expense_model_test.dart
│   │   │   │   ├── resource_model_test.dart
│   │   │   │   ├── weather_model_test.dart
│   │   │   │   └── disease_prediction_model_test.dart
│   │   │   └── utils/                 # Utility tests
│   │   │       ├── validators_test.dart
│   │   │       ├── formatters_test.dart
│   │   │       └── helpers_test.dart
│   │   ├── models/                    # Additional model tests
│   │   │   ├── app_notification_test.dart
│   │   │   ├── chat_message_test.dart
│   │   │   ├── schedule_task_test.dart
│   │   │   └── seed_inventory_model_test.dart
│   │   └── services/                  # Service tests
│   │       ├── auth_service_test.dart
│   │       ├── cart_service_test.dart
│   │       ├── orders_service_test.dart
│   │       ├── products_service_test.dart
│   │       ├── crop_service_test.dart
│   │       ├── expense_service_test.dart
│   │       ├── weather_service_test.dart
│   │       ├── chat_service_test.dart
│   │       ├── notification_service_test.dart
│   │       ├── resource_service_test.dart
│   │       ├── schedule_service_test.dart
│   │       ├── seed_inventory_service_test.dart
│   │       └── report_service_test.dart
│   ├── mocks/                         # Shared mocks
│   │   ├── firebase_mocks.dart
│   │   ├── service_mocks.dart
│   │   └── mock_data.dart
│   ├── helpers/                       # Test helpers
│   │   └── test_helpers.dart
│   └── fixtures/                      # Test data fixtures
│       ├── user_fixtures.dart
│       ├── product_fixtures.dart
│       └── order_fixtures.dart
```

---

## 🔧 Required Dependencies

Add these to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  
  # Testing utilities
  mocktail: ^1.0.4              # Mocking library (easier than mockito)
  fake_cloud_firestore: ^3.1.0  # Fake Firestore for testing
  firebase_auth_mocks: ^0.14.1  # Mock Firebase Auth
  clock: ^1.1.1                 # Controllable clock for time-based tests
  
  # Optional but recommended
  test: any                      # Additional testing utilities
```

---

## 📊 Testing Priority Matrix

| Priority | Category | Components | Test Count (Est.) |
|----------|----------|------------|-------------------|
| 🔴 **P0 - Critical** | Models | All data models | ~50 tests |
| 🔴 **P0 - Critical** | Validators | Form validation | ~40 tests |
| 🟠 **P1 - High** | Formatters | Date, currency, text formatting | ~35 tests |
| 🟠 **P1 - High** | Cart Service | Cart operations | ~20 tests |
| 🟡 **P2 - Medium** | Auth Service | Authentication flows | ~15 tests |
| 🟡 **P2 - Medium** | Order Service | Order management | ~15 tests |
| 🟢 **P3 - Lower** | Other Services | Weather, Notifications, etc. | ~30 tests |

**Total Estimated Tests: ~205 unit tests**

---

## 📝 Detailed Test Cases

### 1. Core Models Testing (`/core/models/`)

#### 1.1 User Model (`user_model_test.dart`)

```dart
// Test groups for User model
group('User Model', () {
  // Creation & Factory Tests
  test('should create User from Map with all fields');
  test('should create User from Map with missing optional fields');
  test('should handle null values gracefully');
  
  // Serialization Tests
  test('should serialize User to Map correctly');
  test('should handle Timestamp conversion for dates');
  
  // copyWith Tests
  test('should create copy with updated displayName');
  test('should preserve unchanged fields in copyWith');
  
  // Equality Tests (Equatable)
  test('should be equal when all properties match');
  test('should not be equal when any property differs');
  
  // Edge Cases
  test('should handle empty strings');
  test('should handle default role as Farmer');
});

group('UserPreferences Model', () {
  test('should create with default values');
  test('should serialize/deserialize correctly');
  test('should support copyWith');
});
```

**Expected Test Count: 15 tests**

---

#### 1.2 Product Model (`product_model_test.dart`)

```dart
group('Product Model', () {
  // Factory & Creation
  test('should create Product from Map');
  test('should handle missing imageUrls as empty list');
  test('should convert price from int to double');
  
  // Serialization
  test('should serialize to Map with Timestamps');
  test('should include isActive field');
  
  // copyWith
  test('should update price correctly');
  test('should update availableQuantity');
  
  // Equality
  test('products with same id should be equal');
  test('products with different prices should not be equal');
  
  // Edge Cases
  test('should handle zero rating');
  test('should default isOrganic to false');
  test('should default isActive to true');
});

group('OrderItem Model', () {
  test('should create from Map');
  test('should calculate subtotal correctly');
  test('subtotal should be price * quantity');
  test('should serialize to Map');
});
```

**Expected Test Count: 16 tests**

---

#### 1.3 Order Model (`order_model_test.dart`)

```dart
group('Order Model', () {
  // Factory
  test('should create Order from Map');
  test('should parse items list correctly');
  test('should parse OrderStatus from string');
  test('should handle unknown status as pending');
  
  // Serialization
  test('should serialize to Map');
  test('should include nested deliveryInfo');
  test('should include nested paymentInfo');
  
  // Status Parsing
  test('should parse "pending" status');
  test('should parse "confirmed" status');
  test('should parse "processing" status');
  test('should parse "shipped" status');
  test('should parse "delivered" status');
  test('should parse "cancelled" status');
  
  // Edge Cases
  test('should handle empty items list');
  test('should calculate with zero delivery fee');
});

group('DeliveryInfo Model', () {
  test('should create from Map');
  test('should handle empty notes');
  test('should serialize correctly');
});

group('PaymentInfo Model', () {
  test('should create from Map');
  test('should parse PaymentMethod correctly');
  test('should parse PaymentStatus correctly');
  test('should default to cash method');
  test('should default to pending status');
});
```

**Expected Test Count: 24 tests**

---

#### 1.4 Cart Item Model (`cart_item_model_test.dart`)

```dart
group('Cart Model', () {
  test('should create from Map');
  test('should handle empty items list');
  test('should calculate subtotal correctly');
  test('should calculate itemCount correctly');
  test('should calculate totalQuantity correctly');
  test('should serialize to Map');
  test('should support copyWith');
});

group('CartItem Model', () {
  test('should create from Map');
  test('should calculate total (price * quantity)');
  test('should serialize to Map with Timestamp');
  test('should support copyWith');
  test('should handle default unit as kg');
});
```

**Expected Test Count: 12 tests**

---

#### 1.5 Crop Model (`crop_model_test.dart`)

```dart
group('Crop Model', () {
  // Factory
  test('should create Crop from Map');
  test('should handle null actualHarvestDate');
  test('should handle null expectedYield');
  test('should handle null actualYield');
  
  // Serialization
  test('should serialize to Map');
  test('should convert dates to Timestamps');
  test('should handle optional dates correctly');
  
  // copyWith
  test('should update status');
  test('should update actualHarvestDate');
  test('should preserve unchanged fields');
  
  // Defaults
  test('should default status to Planted');
  test('should default notes to empty string');
  test('should default imageUrls to empty list');
  
  // Equality
  test('crops with same id should be equal');
});
```

**Expected Test Count: 14 tests**

---

### 2. Validators Testing (`validators_test.dart`)

```dart
group('Validators.required', () {
  test('should return error for null value');
  test('should return error for empty string');
  test('should return error for whitespace only');
  test('should return null for valid string');
  test('should use custom fieldName in error message');
  test('should use default fieldName when not provided');
});

group('Validators.email', () {
  test('should return error for null');
  test('should return error for empty string');
  test('should return error for invalid format: "test"');
  test('should return error for missing @: "testexample.com"');
  test('should return error for missing domain: "test@"');
  test('should return error for missing extension: "test@example"');
  test('should return null for valid email: "test@example.com"');
  test('should return null for email with subdomain');
  test('should return null for email with + character');
});

group('Validators.password', () {
  test('should return error for null');
  test('should return error for empty string');
  test('should return error for too short password (< 6 chars)');
  test('should return null for valid password (6+ chars)');
  test('should respect custom minLength');
  test('should include minLength in error message');
});

group('Validators.confirmPassword', () {
  test('should return error for null');
  test('should return error for empty');
  test('should return error when passwords dont match');
  test('should return null when passwords match');
});

group('Validators.phoneNumber', () {
  test('should return null for null (optional)');
  test('should return null for empty (optional)');
  test('should return error for too short');
  test('should return null for valid format');
  test('should allow + prefix');
  test('should allow spaces and dashes');
});

group('Validators.number', () {
  test('should return null for null (optional)');
  test('should return null for empty (optional)');
  test('should return error for non-numeric string');
  test('should return null for integer string');
  test('should return null for decimal string');
  test('should use custom fieldName in error');
});

group('Validators.positiveNumber', () {
  test('should return null for null (optional)');
  test('should return error for zero');
  test('should return error for negative');
  test('should return null for positive');
});

group('Validators.min', () {
  test('should return null for null (optional)');
  test('should return error for value below min');
  test('should return null for value at min');
  test('should return null for value above min');
  test('should include min value in error message');
});

group('Validators.max', () {
  test('should return null for null (optional)');
  test('should return error for value above max');
  test('should return null for value at max');
  test('should return null for value below max');
});

group('Validators.minLength', () {
  test('should return null for null (optional)');
  test('should return error for string shorter than min');
  test('should return null for string at minLength');
  test('should return null for string longer than min');
});

group('Validators.maxLength', () {
  test('should return null for null (optional)');
  test('should return error for string longer than max');
  test('should return null for string at maxLength');
});

group('Validators.date', () {
  test('should return null for null (optional)');
  test('should return null for valid ISO date');
  test('should return error for invalid date format');
});

group('Validators.url', () {
  test('should return null for null (optional)');
  test('should return null for valid http url');
  test('should return null for valid https url');
  test('should return error for missing protocol');
  test('should return error for invalid format');
});

group('Validators.combine', () {
  test('should run validators in order');
  test('should return first error encountered');
  test('should return null when all validators pass');
  test('should work with multiple validators');
});
```

**Expected Test Count: 58 tests**

---

### 3. Formatters Testing (`formatters_test.dart`)

```dart
group('Formatters.formatDate', () {
  test('should format date as "MMM dd, yyyy"');
  test('should handle different months correctly');
});

group('Formatters.formatShortDate', () {
  test('should format date as "dd/MM/yyyy"');
});

group('Formatters.formatTime', () {
  test('should format time as "hh:mm a"');
  test('should show AM/PM correctly');
});

group('Formatters.formatDateTime', () {
  test('should format as "MMM dd, yyyy at hh:mm a"');
});

group('Formatters.formatRelativeTime', () {
  test('should return "Just now" for < 60 seconds');
  test('should return "X minutes ago" for < 60 minutes');
  test('should return "X hours ago" for < 24 hours');
  test('should return "X days ago" for < 7 days');
  test('should return "X weeks ago" for < 30 days');
  test('should return "X months ago" for < 365 days');
  test('should return "X years ago" for >= 365 days');
  test('should use singular form for 1 minute');
  test('should use plural form for multiple minutes');
});

group('Formatters.formatCurrency', () {
  test('should format with $ symbol by default');
  test('should include 2 decimal places');
  test('should add thousand separators');
  test('should use custom symbol');
  test('should handle zero');
  test('should handle negative values');
});

group('Formatters.formatCompactCurrency', () {
  test('should return full format for < 1000');
  test('should return K format for >= 1000');
  test('should return M format for >= 1000000');
  test('should include one decimal place');
});

group('Formatters.formatNumber', () {
  test('should add thousand separators');
  test('should respect decimal places parameter');
  test('should handle zero decimals by default');
});

group('Formatters.formatPercentage', () {
  test('should append % symbol');
  test('should respect decimal places');
});

group('Formatters.formatFileSize', () {
  test('should return bytes for < 1024');
  test('should return KB for >= 1024');
  test('should return MB for >= 1024 * 1024');
  test('should return GB for >= 1024 * 1024 * 1024');
});

group('Formatters.formatDuration', () {
  test('should format days');
  test('should format hours');
  test('should format hours with minutes');
  test('should format minutes');
  test('should format seconds');
  test('should use singular forms correctly');
});

group('Formatters.formatPhoneNumber', () {
  test('should format 10-digit US number');
  test('should format international number with +');
  test('should return original if format not recognized');
});

group('Formatters.capitalize', () {
  test('should capitalize first letter');
  test('should lowercase rest');
  test('should handle empty string');
  test('should handle single character');
});

group('Formatters.capitalizeWords', () {
  test('should capitalize each word');
  test('should handle multiple words');
});

group('Formatters.truncate', () {
  test('should not truncate if within limit');
  test('should truncate and add ellipsis');
  test('should use custom ellipsis');
});

group('Formatters.formatList', () {
  test('should return empty string for empty list');
  test('should return single item as-is');
  test('should join multiple items with separator');
  test('should use lastSeparator before final item');
});
```

**Expected Test Count: 50 tests**

---

### 4. Cart Service Testing (`cart_service_test.dart`)

```dart
group('CartService', () {
  // Setup mocks: FakeFirebaseFirestore, MockFirebaseAuth
  
  group('getCart', () {
    test('should throw AuthException when user is null');
    test('should return empty cart when document does not exist');
    test('should return cart with items from Firestore');
  });
  
  group('addToCart', () {
    test('should throw AuthException when user is null');
    test('should add new item to empty cart');
    test('should increase quantity if item already exists');
    test('should preserve other items when adding');
    test('should update timestamp on cart');
  });
  
  group('updateItemQuantity', () {
    test('should throw AuthException when user is null');
    test('should throw NotFoundException when item not in cart');
    test('should update quantity for existing item');
    test('should remove item when quantity <= 0');
  });
  
  group('removeFromCart', () {
    test('should throw AuthException when user is null');
    test('should remove item from cart');
    test('should preserve other items');
  });
  
  group('clearCart', () {
    test('should throw AuthException when user is null');
    test('should clear all items');
    test('should update timestamp');
  });
  
  group('getCartItemCount', () {
    test('should return 0 for empty cart');
    test('should return correct count');
    test('should return 0 on error');
  });
  
  group('getCartSubtotal', () {
    test('should return 0.0 for empty cart');
    test('should calculate correct subtotal');
    test('should return 0.0 on error');
  });
});
```

**Expected Test Count: 22 tests**

---

### 5. Auth Service Testing (`auth_service_test.dart`)

```dart
group('AuthService', () {
  // Requires: firebase_auth_mocks, fake_cloud_firestore
  
  group('signInWithEmail', () {
    test('should return UserCredential on successful sign in');
    test('should update lastLogin in Firestore');
    test('should throw error for invalid credentials');
    test('should handle FirebaseAuthException codes');
  });
  
  group('signUpWithEmail', () {
    test('should create user in Firebase Auth');
    test('should set displayName if provided');
    test('should create user document in Firestore');
    test('should set default role as Farmer');
    test('should store all provided user data');
  });
  
  group('signOut', () {
    test('should sign out from Firebase Auth');
    test('should sign out from Google');
  });
  
  group('getIdToken', () {
    test('should return null when user is null');
    test('should return token for authenticated user');
    test('should force refresh when requested');
  });
  
  group('_handleAuthException', () {
    test('should return correct message for user-not-found');
    test('should return correct message for wrong-password');
    test('should return correct message for email-already-in-use');
    test('should return correct message for weak-password');
    test('should return generic message for unknown code');
  });
  
  group('isAdmin', () {
    test('should return false when user is null');
    test('should return true when user role is admin');
    test('should return false for other roles');
  });
});
```

**Expected Test Count: 22 tests**

---

## 📐 Testing Patterns & Best Practices

### Mock Setup Pattern

```dart
// test/mocks/firebase_mocks.dart
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Create reusable mock instances
MockUser createMockUser({
  String uid = 'test-uid',
  String email = 'test@example.com',
  String displayName = 'Test User',
}) {
  return MockUser(
    uid: uid,
    email: email,
    displayName: displayName,
  );
}
```

### Test Data Fixtures Pattern

```dart
// test/fixtures/product_fixtures.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFixtures {
  static Map<String, dynamic> validProductMap({
    String id = 'product-1',
    String name = 'Test Product',
    double price = 99.99,
  }) {
    return {
      'sellerId': 'seller-1',
      'sellerName': 'Test Seller',
      'name': name,
      'description': 'A test product',
      'category': 'Vegetables',
      'price': price,
      'unit': 'kg',
      'availableQuantity': 100.0,
      'imageUrls': ['https://example.com/image.jpg'],
      'location': 'Test Location',
      'rating': 4.5,
      'reviewCount': 10,
      'isOrganic': true,
      'isActive': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }
  
  static Map<String, dynamic> minimalProductMap() {
    return {
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }
}
```

### Test Helper Pattern

```dart
// test/helpers/test_helpers.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Timestamp createTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}

DateTime fixedDateTime() {
  return DateTime(2024, 1, 15, 10, 30, 0);
}
```

---

## 🚀 Running Tests

### Run All Unit Tests
```bash
cd otfha
flutter test test/unit/
```

### Run Specific Test File
```bash
flutter test test/unit/core/utils/validators_test.dart
```

### Run With Coverage
```bash
flutter test --coverage test/unit/
```

### Generate Coverage Report
```bash
# Install lcov if not installed
# Then generate HTML report
genhtml coverage/lcov.info -o coverage/html
```

### Run Tests With Verbose Output
```bash
flutter test --reporter expanded test/unit/
```

---

## 📈 Coverage Goals

| Module | Target Coverage |
|--------|-----------------|
| Core Models | ≥ 95% |
| Validators | ≥ 100% |
| Formatters | ≥ 95% |
| Services | ≥ 80% |
| **Overall** | **≥ 85%** |

---

## 🔄 Implementation Order (Recommended)

### Phase 1: Pure Functions (No Dependencies) - Week 1 ✅ COMPLETED & VERIFIED
1. ✅ `validators_test.dart` - Pure validation logic - **PASSED**
2. ✅ `formatters_test.dart` - Pure formatting logic - **PASSED**
3. ✅ `test_helpers.dart` - Shared test utilities - **DONE**

**Phase 1 Test Results (December 15, 2024):**
```
PS> flutter test test/unit/core/utils/
00:07 +148: All tests passed!
```

### Integration Testing ✅ COMPLETED & VERIFIED
4. ✅ `login_screen_test.dart` - Screen integration (17 tests) - **PASSED**
5. ✅ `auth_flow_test.dart` - Auth flow tests (11 tests) - **PASSED**
6. ✅ `shopping_flow_test.dart` - Shopping flow tests (14 tests) - **PASSED**
7. ✅ `mock_auth_service.dart` - Mock authentication service - **DONE**
8. ✅ `mock_providers.dart` - Test wrappers - **DONE**

**Integration Test Results (December 15, 2024):**
```
PS> flutter test test/integration/
00:03 +42: All tests passed!
```

### Security Testing ✅ COMPLETED & VERIFIED
9. ✅ `input_validation_security_test.dart` - Injection prevention (25 tests) - **PASSED**
10. ✅ `auth_security_test.dart` - Auth security (29 tests) - **PASSED**
11. ✅ `data_security_test.dart` - Data protection (19 tests) - **PASSED**
12. ✅ `api_security_test.dart` - API security (16 tests) - **PASSED**

**Security Test Results (December 15, 2024):**
```
PS> flutter test test/security/
00:01 +89: All tests passed!
```

### Phase 2: Models (Minimal Dependencies) - Week 1-2 ⏳ PENDING
9. ⏳ `user_model_test.dart`
10. ⏳ `product_model_test.dart`
11. ⏳ `cart_item_model_test.dart`
12. ⏳ `order_model_test.dart`
13. ⏳ `crop_model_test.dart`
14. ⏳ Remaining models

### Phase 3: Services (Requires Mocking) - Week 2-3 ⏳ PENDING
15. ⏳ `cart_service_test.dart`
16. ⏳ `auth_service_test.dart`
17. ⏳ Remaining services

---

## 📋 Test Naming Convention

```dart
// Format: should_[expected behavior]_when_[condition]
test('should return error message when email is empty');
test('should create User from Map with all fields');
test('should throw AuthException when user is not logged in');
```

---

## 🎯 Success Criteria

- [ ] All P0 (Critical) tests implemented and passing
- [ ] All P1 (High) tests implemented and passing
- [ ] Code coverage ≥ 85%
- [ ] No flaky tests
- [ ] Tests run in < 30 seconds total
- [ ] All tests are independent (no shared state)
- [ ] Mocks properly reset between tests

---

## 📚 References

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Fake Cloud Firestore](https://pub.dev/packages/fake_cloud_firestore)
- [Firebase Auth Mocks](https://pub.dev/packages/firebase_auth_mocks)

---

*Document Version: 1.0*
*Last Updated: December 15, 2024*
*Author: OTFHA Development Team*

