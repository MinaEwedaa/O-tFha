import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration tests for Shopping Flow
/// 
/// Tests complete shopping journeys:
/// - Browse products
/// - Add to cart
/// - Update cart quantities
/// - Remove from cart
/// - Checkout flow
/// 
/// Uses mock data to avoid Firebase dependency.

void main() {
  late MockCartService mockCartService;
  late List<MockProduct> mockProducts;
  
  setUp(() {
    mockCartService = MockCartService();
    mockProducts = [
      MockProduct(
        id: 'prod-1',
        name: 'Fresh Tomatoes',
        price: 5.99,
        unit: 'kg',
        category: 'Vegetables',
        imageUrl: 'https://example.com/tomato.jpg',
      ),
      MockProduct(
        id: 'prod-2',
        name: 'Organic Apples',
        price: 8.50,
        unit: 'kg',
        category: 'Fruits',
        imageUrl: 'https://example.com/apple.jpg',
      ),
      MockProduct(
        id: 'prod-3',
        name: 'Fresh Corn',
        price: 3.25,
        unit: 'piece',
        category: 'Vegetables',
        imageUrl: 'https://example.com/corn.jpg',
      ),
    ];
  });
  
  tearDown(() {
    mockCartService.clear();
  });

  group('Shopping Flow Integration Tests', () {
    // ================================================================
    // Product Browsing Tests
    // ================================================================
    group('Product Browsing', () {
      testWidgets('should display list of products', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestProductList(products: mockProducts),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all products are displayed
        expect(find.text('Fresh Tomatoes'), findsOneWidget);
        expect(find.text('Organic Apples'), findsOneWidget);
        expect(find.text('Fresh Corn'), findsOneWidget);
      });

      testWidgets('should display product prices', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestProductList(products: mockProducts),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('\$5.99/kg'), findsOneWidget);
        expect(find.text('\$8.50/kg'), findsOneWidget);
        expect(find.text('\$3.25/piece'), findsOneWidget);
      });

      testWidgets('should navigate to product detail on tap', (tester) async {
        bool navigatedToDetail = false;
        String? selectedProductId;
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestProductList(
              products: mockProducts,
              onProductTap: (id) {
                navigatedToDetail = true;
                selectedProductId = id;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap on first product
        await tester.tap(find.text('Fresh Tomatoes'));
        await tester.pumpAndSettle();

        expect(navigatedToDetail, true);
        expect(selectedProductId, 'prod-1');
      });
    });

    // ================================================================
    // Add to Cart Tests
    // ================================================================
    group('Add to Cart', () {
      testWidgets('should add product to cart', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestProductWithCart(
              product: mockProducts[0],
              cartService: mockCartService,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap add to cart
        await tester.tap(find.byKey(const Key('add-to-cart')));
        await tester.pumpAndSettle();

        // Verify item added
        expect(mockCartService.items.length, 1);
        expect(mockCartService.items.first.productId, 'prod-1');
      });

      testWidgets('should show success message after adding to cart', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestProductWithCart(
              product: mockProducts[0],
              cartService: mockCartService,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap add to cart
        await tester.tap(find.byKey(const Key('add-to-cart')));
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Added to cart!'), findsOneWidget);
      });

      testWidgets('should increase quantity if product already in cart', (tester) async {
        // Add product first
        mockCartService.addItem(MockCartItem(
          productId: 'prod-1',
          productName: 'Fresh Tomatoes',
          price: 5.99,
          quantity: 1,
        ));
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestProductWithCart(
              product: mockProducts[0],
              cartService: mockCartService,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap add to cart again
        await tester.tap(find.byKey(const Key('add-to-cart')));
        await tester.pumpAndSettle();

        // Verify quantity increased
        expect(mockCartService.items.length, 1);
        expect(mockCartService.items.first.quantity, 2);
      });
    });

    // ================================================================
    // Cart Management Tests
    // ================================================================
    group('Cart Management', () {
      testWidgets('should display cart items', (tester) async {
        // Add items to cart
        mockCartService.addItem(MockCartItem(
          productId: 'prod-1',
          productName: 'Fresh Tomatoes',
          price: 5.99,
          quantity: 2,
        ));
        mockCartService.addItem(MockCartItem(
          productId: 'prod-2',
          productName: 'Organic Apples',
          price: 8.50,
          quantity: 1,
        ));
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestCartScreen(cartService: mockCartService),
          ),
        );
        await tester.pumpAndSettle();

        // Verify items displayed
        expect(find.text('Fresh Tomatoes'), findsOneWidget);
        expect(find.text('Organic Apples'), findsOneWidget);
      });

      testWidgets('should calculate cart total correctly', (tester) async {
        mockCartService.addItem(MockCartItem(
          productId: 'prod-1',
          productName: 'Fresh Tomatoes',
          price: 5.99,
          quantity: 2, // 5.99 * 2 = 11.98
        ));
        mockCartService.addItem(MockCartItem(
          productId: 'prod-2',
          productName: 'Organic Apples',
          price: 8.50,
          quantity: 1, // 8.50 * 1 = 8.50
        ));
        // Total: 20.48
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestCartScreen(cartService: mockCartService),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Total: \$20.48'), findsOneWidget);
      });

      testWidgets('should update quantity in cart', (tester) async {
        mockCartService.addItem(MockCartItem(
          productId: 'prod-1',
          productName: 'Fresh Tomatoes',
          price: 5.99,
          quantity: 1,
        ));
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestCartScreen(cartService: mockCartService),
          ),
        );
        await tester.pumpAndSettle();

        // Tap increment
        await tester.tap(find.byKey(const Key('increment-prod-1')));
        await tester.pumpAndSettle();

        expect(mockCartService.items.first.quantity, 2);
      });

      testWidgets('should remove item from cart', (tester) async {
        mockCartService.addItem(MockCartItem(
          productId: 'prod-1',
          productName: 'Fresh Tomatoes',
          price: 5.99,
          quantity: 1,
        ));
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestCartScreen(cartService: mockCartService),
          ),
        );
        await tester.pumpAndSettle();

        // Tap remove
        await tester.tap(find.byKey(const Key('remove-prod-1')));
        await tester.pumpAndSettle();

        expect(mockCartService.items.isEmpty, true);
      });

      testWidgets('should show empty cart message', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestCartScreen(cartService: mockCartService),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Your cart is empty'), findsOneWidget);
      });
    });

    // ================================================================
    // Checkout Flow Tests
    // ================================================================
    group('Checkout Flow', () {
      testWidgets('should navigate to checkout with cart items', (tester) async {
        bool navigatedToCheckout = false;
        
        mockCartService.addItem(MockCartItem(
          productId: 'prod-1',
          productName: 'Fresh Tomatoes',
          price: 5.99,
          quantity: 2,
        ));
        
        await tester.pumpWidget(
          MaterialApp(
            home: _TestCartScreen(
              cartService: mockCartService,
              onCheckout: () => navigatedToCheckout = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap checkout
        await tester.tap(find.byKey(const Key('checkout-button')));
        await tester.pumpAndSettle();

        expect(navigatedToCheckout, true);
      });

      testWidgets('should disable checkout for empty cart', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestCartScreen(cartService: mockCartService),
          ),
        );
        await tester.pumpAndSettle();

        // Checkout button should not exist or be disabled
        expect(find.byKey(const Key('checkout-button')), findsNothing);
      });
    });
  });
}

// ================================================================
// Mock Classes
// ================================================================

class MockProduct {
  final String id;
  final String name;
  final double price;
  final String unit;
  final String category;
  final String imageUrl;

  MockProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.category,
    required this.imageUrl,
  });
}

class MockCartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;

  MockCartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;
}

class MockCartService {
  final List<MockCartItem> items = [];

  void addItem(MockCartItem item) {
    final existingIndex = items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      items[existingIndex].quantity += item.quantity;
    } else {
      items.add(item);
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.productId == productId);
  }

  void updateQuantity(String productId, int quantity) {
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
    }
  }

  double get total => items.fold(0, (sum, item) => sum + item.total);

  void clear() => items.clear();
}

// ================================================================
// Test Widgets
// ================================================================

class _TestProductList extends StatelessWidget {
  final List<MockProduct> products;
  final void Function(String)? onProductTap;

  const _TestProductList({
    required this.products,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}/${product.unit}'),
            onTap: () => onProductTap?.call(product.id),
          );
        },
      ),
    );
  }
}

class _TestProductWithCart extends StatefulWidget {
  final MockProduct product;
  final MockCartService cartService;

  const _TestProductWithCart({
    required this.product,
    required this.cartService,
  });

  @override
  State<_TestProductWithCart> createState() => _TestProductWithCartState();
}

class _TestProductWithCartState extends State<_TestProductWithCart> {
  String? _message;

  void _addToCart() {
    widget.cartService.addItem(MockCartItem(
      productId: widget.product.id,
      productName: widget.product.name,
      price: widget.product.price,
      quantity: 1,
    ));
    setState(() => _message = 'Added to cart!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.product.name, style: const TextStyle(fontSize: 24)),
          Text('\$${widget.product.price.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('add-to-cart'),
            onPressed: _addToCart,
            child: const Text('Add to Cart'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!),
          ],
        ],
      ),
    );
  }
}

class _TestCartScreen extends StatefulWidget {
  final MockCartService cartService;
  final VoidCallback? onCheckout;

  const _TestCartScreen({
    required this.cartService,
    this.onCheckout,
  });

  @override
  State<_TestCartScreen> createState() => _TestCartScreenState();
}

class _TestCartScreenState extends State<_TestCartScreen> {
  @override
  Widget build(BuildContext context) {
    final items = widget.cartService.items;
    
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const Center(child: Text('Your cart is empty')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.productName),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('increment-${item.productId}'),
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            widget.cartService.updateQuantity(
                              item.productId,
                              item.quantity + 1,
                            );
                          });
                        },
                      ),
                      IconButton(
                        key: Key('remove-${item.productId}'),
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            widget.cartService.removeItem(item.productId);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total: \$${widget.cartService.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('checkout-button'),
                  onPressed: widget.onCheckout,
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

