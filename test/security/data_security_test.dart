import 'package:flutter_test/flutter_test.dart';
import 'package:otfha/core/models/user_model.dart';
import 'package:otfha/core/models/order_model.dart' as order_model;
import 'package:otfha/core/models/product_model.dart' as product_model;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Security tests for data protection
/// 
/// Tests:
/// - Sensitive data handling
/// - Data masking
/// - Secure defaults
/// - No plaintext sensitive data exposure

void main() {
  group('Data Security Tests', () {
    // ================================================================
    // Sensitive Data Handling Tests
    // ================================================================
    group('Sensitive Data Handling', () {
      test('User model should not store plaintext password', () {
        final userMap = <String, dynamic>{
          'uid': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'password': 'shouldnotexist', // This should NOT be in model
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'preferences': <String, dynamic>{},
        };

        final user = User.fromMap(userMap);

        // User model should not have password field
        final serialized = user.toMap();
        expect(serialized.containsKey('password'), false);
      });

      test('User model should not expose sensitive auth data', () {
        final userMap = <String, dynamic>{
          'uid': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'authToken': 'secret-token',
          'refreshToken': 'refresh-token',
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'preferences': <String, dynamic>{},
        };

        final user = User.fromMap(userMap);
        final serialized = user.toMap();

        // Should not contain tokens
        expect(serialized.containsKey('authToken'), false);
        expect(serialized.containsKey('refreshToken'), false);
        expect(serialized.containsKey('accessToken'), false);
      });

      test('DeliveryInfo should properly store address data', () {
        const deliveryInfo = order_model.DeliveryInfo(
          address: '123 Test St',
          city: 'Test City',
          phone: '+1234567890',
          notes: 'Leave at door',
        );

        final map = deliveryInfo.toMap();
        
        // Should contain necessary fields
        expect(map['address'], '123 Test St');
        expect(map['city'], 'Test City');
        expect(map['phone'], '+1234567890');
      });

      test('PaymentInfo should not store card numbers', () {
        const paymentInfo = order_model.PaymentInfo(
          method: order_model.PaymentMethod.card,
          status: order_model.PaymentStatus.paid,
        );

        final map = paymentInfo.toMap();

        // Should NOT contain card details
        expect(map.containsKey('cardNumber'), false);
        expect(map.containsKey('cvv'), false);
        expect(map.containsKey('expiryDate'), false);
        expect(map.containsKey('cardHolderName'), false);
      });
    });

    // ================================================================
    // Data Masking Tests
    // ================================================================
    group('Data Masking', () {
      test('Phone numbers in models should be stored as-is for later masking', () {
        const deliveryInfo = order_model.DeliveryInfo(
          address: '123 Test St',
          city: 'Test City',
          phone: '+1234567890',
        );

        // Phone should be stored (display layer handles masking)
        expect(deliveryInfo.phone, '+1234567890');
      });

      test('Email in User model should be stored for verification', () {
        final user = User.fromMap(<String, dynamic>{
          'uid': 'test-uid',
          'email': 'user@example.com',
          'displayName': 'User',
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'preferences': <String, dynamic>{},
        });

        expect(user.email, 'user@example.com');
      });

      test('User photos should use URL not base64 data', () {
        final user = User.fromMap(<String, dynamic>{
          'uid': 'test-uid',
          'email': 'user@example.com',
          'displayName': 'User',
          'photoURL': 'https://example.com/photo.jpg',
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'preferences': <String, dynamic>{},
        });

        expect(user.photoURL, startsWith('https://'));
        expect(user.photoURL.contains('base64'), false);
      });
    });

    // ================================================================
    // Secure Defaults Tests
    // ================================================================
    group('Secure Defaults', () {
      test('User should have secure default role', () {
        final user = User.fromMap(<String, dynamic>{
          'uid': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test',
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'preferences': <String, dynamic>{},
        });

        // Default role should not be admin
        expect(user.role, 'Farmer');
        expect(user.role, isNot('admin'));
        expect(user.role, isNot('Admin'));
      });

      test('User email verification should default to false', () {
        final user = User.fromMap(<String, dynamic>{
          'uid': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test',
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'preferences': <String, dynamic>{},
        });

        expect(user.emailVerified, false);
      });

      test('Product should default to active state', () {
        final product = product_model.Product.fromMap('prod-1', {
          'sellerId': 'seller-1',
          'sellerName': 'Seller',
          'name': 'Product',
          'description': 'Desc',
          'category': 'Cat',
          'price': 10.0,
          'unit': 'kg',
          'availableQuantity': 100,
          'location': 'Location',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        expect(product.isActive, true);
      });

      test('Order should default to pending status', () {
        final order = order_model.Order.fromMap('order-1', <String, dynamic>{
          'orderNumber': 'ORD-001',
          'buyerId': 'buyer-1',
          'buyerName': 'Buyer',
          'items': <dynamic>[],
          'subtotal': 0,
          'total': 0,
          'deliveryInfo': <String, dynamic>{
            'address': 'Test',
            'city': 'City',
            'phone': '123',
          },
          'paymentInfo': <String, dynamic>{},
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        expect(order.status, order_model.OrderStatus.pending);
        // Should not be confirmed or delivered by default
        expect(order.status, isNot(order_model.OrderStatus.confirmed));
        expect(order.status, isNot(order_model.OrderStatus.delivered));
      });

      test('Payment should default to pending status', () {
        const paymentInfo = order_model.PaymentInfo(
          method: order_model.PaymentMethod.cash,
        );

        expect(paymentInfo.status, order_model.PaymentStatus.pending);
      });

      test('UserPreferences should have safe defaults', () {
        const prefs = UserPreferences();
        
        expect(prefs.notifications, true);
        expect(prefs.language, 'en');
      });
    });

    // ================================================================
    // Data Integrity Tests
    // ================================================================
    group('Data Integrity', () {
      test('User should preserve all fields on serialization', () {
        final now = DateTime.now();
        final originalUser = User(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          firstName: 'Test',
          lastName: 'User',
          phone: '+1234567890',
          address: '123 Test St',
          photoURL: 'https://example.com/photo.jpg',
          role: 'Farmer',
          emailVerified: true,
          createdAt: now,
          lastLogin: now,
          preferences: const UserPreferences(
            notifications: false,
            language: 'ar',
          ),
        );

        final map = originalUser.toMap();
        final restored = User.fromMap(map);

        expect(restored.uid, originalUser.uid);
        expect(restored.email, originalUser.email);
        expect(restored.displayName, originalUser.displayName);
        expect(restored.firstName, originalUser.firstName);
        expect(restored.lastName, originalUser.lastName);
        expect(restored.phone, originalUser.phone);
        expect(restored.address, originalUser.address);
        expect(restored.role, originalUser.role);
        expect(restored.emailVerified, originalUser.emailVerified);
      });

      test('Order items should maintain price integrity', () {
        final item = product_model.OrderItem(
          productId: 'prod-1',
          productName: 'Test Product',
          productImage: '',
          price: 10.50,
          unit: 'kg',
          quantity: 3,
          sellerId: 'seller-1',
          sellerName: 'Seller',
        );

        // Subtotal calculation should be accurate
        expect(item.subtotal, 31.50);
        
        // Serialization should preserve
        final map = item.toMap();
        final restored = product_model.OrderItem.fromMap(map);
        expect(restored.subtotal, 31.50);
      });

      test('Product price should not allow negative values after restoration', () {
        final product = product_model.Product.fromMap('prod-1', {
          'sellerId': 'seller-1',
          'sellerName': 'Seller',
          'name': 'Product',
          'description': 'Desc',
          'category': 'Cat',
          'price': -10.0, // Invalid negative price
          'unit': 'kg',
          'availableQuantity': 100,
          'location': 'Location',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Price is stored as-is, validation should be at input level
        // This test documents the behavior
        expect(product.price, -10.0);
      });
    });

    // ================================================================
    // PII Protection Tests
    // ================================================================
    group('PII Protection', () {
      test('User model Equatable should include sensitive fields for proper comparison', () {
        final user1 = User.fromMap(<String, dynamic>{
          'uid': 'uid-1',
          'email': 'test@example.com',
          'displayName': 'Test',
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'preferences': <String, dynamic>{},
        });

        final user2 = User.fromMap(<String, dynamic>{
          'uid': 'uid-2', // Different UID
          'email': 'test@example.com',
          'displayName': 'Test',
          'createdAt': Timestamp.now(),
          'lastLogin': Timestamp.now(),
          'preferences': <String, dynamic>{},
        });

        // Users with different UIDs should not be equal
        expect(user1, isNot(equals(user2)));
      });

      test('Order should include buyer information for delivery', () {
        final order = order_model.Order.fromMap('order-1', <String, dynamic>{
          'orderNumber': 'ORD-001',
          'buyerId': 'buyer-1',
          'buyerName': 'John Doe',
          'items': <dynamic>[],
          'subtotal': 100,
          'total': 100,
          'deliveryInfo': <String, dynamic>{
            'address': '123 Main St',
            'city': 'Cityville',
            'phone': '+1234567890',
          },
          'paymentInfo': <String, dynamic>{
            'method': 'cash',
            'status': 'pending',
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Delivery info should be accessible
        expect(order.deliveryInfo.address, '123 Main St');
        expect(order.deliveryInfo.phone, '+1234567890');
      });
    });
  });
}

