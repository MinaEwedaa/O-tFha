import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Product categories
class ProductCategory {
  static const List<Map<String, String>> buyCategories = [
    {'id': 'all', 'name': 'All', 'nameAr': 'الكل'},
    {'id': 'equipment', 'name': 'Equipment', 'nameAr': 'معدات'},
    {'id': 'seeds', 'name': 'Seeds', 'nameAr': 'بذور'},
    {'id': 'fertilizers', 'name': 'Fertilizers', 'nameAr': 'أسمدة'},
    {'id': 'pesticides', 'name': 'Pesticides', 'nameAr': 'مبيدات'},
    {'id': 'tools', 'name': 'Tools', 'nameAr': 'أدوات'},
    {'id': 'irrigation', 'name': 'Irrigation', 'nameAr': 'ري'},
  ];

  static const List<Map<String, String>> sellCategories = [
    {'id': 'all', 'name': 'All', 'nameAr': 'الكل'},
    {'id': 'fruits', 'name': 'Fruits', 'nameAr': 'فواكه'},
    {'id': 'vegetables', 'name': 'Vegetables', 'nameAr': 'خضروات'},
    {'id': 'grains', 'name': 'Grains', 'nameAr': 'حبوب'},
    {'id': 'dairy', 'name': 'Dairy', 'nameAr': 'ألبان'},
    {'id': 'livestock', 'name': 'Livestock', 'nameAr': 'ماشية'},
    {'id': 'produce', 'name': 'Produce', 'nameAr': 'منتجات'},
  ];
}

/// Model for Market Product
class MarketProduct {
  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final String nameArabic;
  final String description;
  final String descriptionArabic;
  final double price;
  final String priceUnit; // per kg, per unit, per piece
  final String category;
  final List<String> imageUrls;
  final double rating;
  final int reviewsCount;
  final int stock;
  final String stockUnit;
  final bool isActive;
  final bool inStock;
  final String? discount;
  final String? location;
  final int views;
  final int interestedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketProduct({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    this.nameArabic = '',
    required this.description,
    this.descriptionArabic = '',
    required this.price,
    this.priceUnit = 'per unit',
    required this.category,
    this.imageUrls = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.stock = 0,
    this.stockUnit = 'units',
    this.isActive = true,
    this.inStock = true,
    this.discount,
    this.location,
    this.views = 0,
    this.interestedCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  String get priceFormatted => 'EGX ${price.toStringAsFixed(2)}';
  String get stockFormatted => '$stock $stockUnit';
  String? get mainImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory MarketProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketProduct(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? 'Unknown Seller',
      name: data['name'] ?? '',
      nameArabic: data['nameArabic'] ?? '',
      description: data['description'] ?? '',
      descriptionArabic: data['descriptionArabic'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      priceUnit: data['priceUnit'] ?? 'per unit',
      category: data['category'] ?? 'other',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      stock: data['stock'] ?? 0,
      stockUnit: data['stockUnit'] ?? 'units',
      isActive: data['isActive'] ?? true,
      inStock: data['inStock'] ?? (data['stock'] ?? 0) > 0,
      discount: data['discount'],
      location: data['location'],
      views: data['views'] ?? 0,
      interestedCount: data['interestedCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'name': name,
      'nameArabic': nameArabic,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'price': price,
      'priceUnit': priceUnit,
      'category': category,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'stock': stock,
      'stockUnit': stockUnit,
      'isActive': isActive,
      'inStock': inStock,
      'discount': discount,
      'location': location,
      'views': views,
      'interestedCount': interestedCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MarketProduct copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? name,
    String? nameArabic,
    String? description,
    String? descriptionArabic,
    double? price,
    String? priceUnit,
    String? category,
    List<String>? imageUrls,
    double? rating,
    int? reviewsCount,
    int? stock,
    String? stockUnit,
    bool? isActive,
    bool? inStock,
    String? discount,
    String? location,
    int? views,
    int? interestedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarketProduct(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      stock: stock ?? this.stock,
      stockUnit: stockUnit ?? this.stockUnit,
      isActive: isActive ?? this.isActive,
      inStock: inStock ?? this.inStock,
      discount: discount ?? this.discount,
      location: location ?? this.location,
      views: views ?? this.views,
      interestedCount: interestedCount ?? this.interestedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model for Cart Item
class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String sellerId;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.sellerId,
  });

  double get totalPrice => price * quantity;

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'],
      sellerId: map['sellerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
    };
  }
}

/// Model for Order
class MarketOrder {
  final String id;
  final String buyerId;
  final String buyerName;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final String deliveryAddress;
  final String? buyerPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  MarketOrder({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0,
    required this.total,
    this.status = 'pending',
    required this.deliveryAddress,
    this.buyerPhone,
    this.notes,
    required this.createdAt,
    this.deliveredAt,
  });

  factory MarketOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketOrder(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      deliveryAddress: data['deliveryAddress'] ?? '',
      buyerPhone: data['buyerPhone'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'buyerName': buyerName,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'buyerPhone': buyerPhone,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }
}

/// Seller Statistics
class SellerStats {
  final int activeListings;
  final int totalSales;
  final double totalRevenue;
  final int totalViews;

  SellerStats({
    required this.activeListings,
    required this.totalSales,
    required this.totalRevenue,
    required this.totalViews,
  });

  factory SellerStats.empty() {
    return SellerStats(
      activeListings: 0,
      totalSales: 0,
      totalRevenue: 0,
      totalViews: 0,
    );
  }
}

/// Product Service - Firebase Integration for Marketplace
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _userId => _auth.currentUser?.uid;
  String? get _userName => _auth.currentUser?.displayName;

  CollectionReference get _productsCollection => _firestore.collection('products');
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _cartsCollection => _firestore.collection('carts');
  CollectionReference get _favoritesCollection => _firestore.collection('favorites');

  // ========== BROWSE PRODUCTS ==========

  /// Get all active products stream
  Stream<List<MarketProduct>> getProductsStream({
    String? category,
    String? searchQuery,
    bool? inStockOnly,
    String sortBy = 'newest',
  }) {
    return _productsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      var products = snapshot.docs
          .map((doc) => MarketProduct.fromFirestore(doc))
          .toList();

      // Apply filters in-memory
      if (category != null && category != 'all') {
        products = products.where((p) => p.category == category).toList();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        products = products.where((p) =>
          p.name.toLowerCase().contains(query) ||
          p.sellerName.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query)
        ).toList();
      }
      if (inStockOnly == true) {
        products = products.where((p) => p.inStock).toList();
      }

      // Sort
      switch (sortBy) {
        case 'price_low':
          products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          products.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'popular':
          products.sort((a, b) => b.views.compareTo(a.views));
          break;
        case 'rating':
          products.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        default:
          // Already sorted by newest
          break;
      }

      return products;
    });
  }

  /// Get product by ID
  Future<MarketProduct?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        return MarketProduct.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  /// Increment product views
  Future<void> incrementProductViews(String productId) async {
    try {
      await _productsCollection.doc(productId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  // ========== SELLER OPERATIONS ==========

  /// Get seller's products stream
  Stream<List<MarketProduct>> getMyProductsStream({String? status}) {
    if (_userId == null) return Stream.value([]);

    return _productsCollection
        .where('sellerId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      var products = snapshot.docs
          .map((doc) => MarketProduct.fromFirestore(doc))
          .toList();

      // Filter by status
      if (status == 'active') {
        products = products.where((p) => p.isActive && p.inStock).toList();
      } else if (status == 'sold') {
        products = products.where((p) => !p.inStock).toList();
      } else if (status == 'draft') {
        products = products.where((p) => !p.isActive).toList();
      }

      return products;
    });
  }

  /// Add new product
  Future<String?> addProduct(MarketProduct product, {List<File>? imageFiles}) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      List<String> imageUrls = [];
      if (imageFiles != null) {
        for (var file in imageFiles) {
          final url = await _uploadProductImage(file);
          imageUrls.add(url);
        }
      }

      final docRef = await _productsCollection.add(
        product.copyWith(
          sellerId: _userId,
          sellerName: _userName ?? 'Unknown Seller',
          imageUrls: imageUrls.isNotEmpty ? imageUrls : product.imageUrls,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ).toMap(),
      );
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  /// Update product
  Future<void> updateProduct(MarketProduct product, {List<File>? newImageFiles}) async {
    try {
      List<String> imageUrls = product.imageUrls;
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        for (var file in newImageFiles) {
          final url = await _uploadProductImage(file);
          imageUrls.add(url);
        }
      }

      await _productsCollection.doc(product.id).update(
        product.copyWith(
          imageUrls: imageUrls,
          updatedAt: DateTime.now(),
        ).toMap(),
      );
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  /// Update product stock
  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _productsCollection.doc(productId).update({
        'stock': newStock,
        'inStock': newStock > 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating stock: $e');
      rethrow;
    }
  }

  /// Toggle product active status
  Future<void> toggleProductStatus(String productId, bool isActive) async {
    try {
      await _productsCollection.doc(productId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error toggling status: $e');
      rethrow;
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      // Delete images
      final product = await getProductById(productId);
      if (product != null) {
        for (var url in product.imageUrls) {
          try {
            final ref = _storage.refFromURL(url);
            await ref.delete();
          } catch (e) {
            print('Error deleting image: $e');
          }
        }
      }

      await _productsCollection.doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  /// Get seller statistics
  Future<SellerStats> getSellerStats() async {
    if (_userId == null) return SellerStats.empty();

    try {
      final productsSnapshot = await _productsCollection
          .where('sellerId', isEqualTo: _userId)
          .get();

      final products = productsSnapshot.docs
          .map((doc) => MarketProduct.fromFirestore(doc))
          .toList();

      int activeListings = products.where((p) => p.isActive && p.inStock).length;
      int totalViews = products.fold(0, (sum, p) => sum + p.views);

      // Get orders for this seller
      final ordersSnapshot = await _ordersCollection.get();
      int totalSales = 0;
      double totalRevenue = 0;

      for (var doc in ordersSnapshot.docs) {
        final order = MarketOrder.fromFirestore(doc);
        for (var item in order.items) {
          if (item.sellerId == _userId) {
            totalSales++;
            totalRevenue += item.totalPrice;
          }
        }
      }

      return SellerStats(
        activeListings: activeListings,
        totalSales: totalSales,
        totalRevenue: totalRevenue,
        totalViews: totalViews,
      );
    } catch (e) {
      print('Error getting seller stats: $e');
      return SellerStats.empty();
    }
  }

  // ========== CART OPERATIONS ==========

  /// Get cart items stream
  Stream<List<CartItem>> getCartStream() {
    if (_userId == null) return Stream.value([]);

    return _cartsCollection.doc(_userId).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return [];
      
      return (data['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [];
    });
  }

  /// Add item to cart
  Future<void> addToCart(MarketProduct product, {int quantity = 1}) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final cartRef = _cartsCollection.doc(_userId);
      final cartDoc = await cartRef.get();

      final newItem = CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: quantity,
        imageUrl: product.mainImageUrl,
        sellerId: product.sellerId,
      );

      if (!cartDoc.exists) {
        await cartRef.set({
          'items': [newItem.toMap()],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = cartDoc.data() as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>?)
            ?.map((i) => CartItem.fromMap(i as Map<String, dynamic>))
            .toList() ?? [];

        // Check if item already exists
        final existingIndex = items.indexWhere((i) => i.productId == product.id);
        if (existingIndex >= 0) {
          items[existingIndex] = CartItem(
            productId: items[existingIndex].productId,
            productName: items[existingIndex].productName,
            price: items[existingIndex].price,
            quantity: items[existingIndex].quantity + quantity,
            imageUrl: items[existingIndex].imageUrl,
            sellerId: items[existingIndex].sellerId,
          );
        } else {
          items.add(newItem);
        }

        await cartRef.update({
          'items': items.map((i) => i.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    if (_userId == null) return;

    try {
      final cartRef = _cartsCollection.doc(_userId);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) return;

      final data = cartDoc.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>?)
          ?.map((i) => CartItem.fromMap(i as Map<String, dynamic>))
          .toList() ?? [];

      if (quantity <= 0) {
        items.removeWhere((i) => i.productId == productId);
      } else {
        final index = items.indexWhere((i) => i.productId == productId);
        if (index >= 0) {
          items[index] = CartItem(
            productId: items[index].productId,
            productName: items[index].productName,
            price: items[index].price,
            quantity: quantity,
            imageUrl: items[index].imageUrl,
            sellerId: items[index].sellerId,
          );
        }
      }

      await cartRef.update({
        'items': items.map((i) => i.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating cart: $e');
      rethrow;
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String productId) async {
    await updateCartItemQuantity(productId, 0);
  }

  /// Clear cart
  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      await _cartsCollection.doc(_userId).delete();
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }

  // ========== ORDER OPERATIONS ==========

  /// Place order
  Future<String?> placeOrder({
    required List<CartItem> items,
    required String deliveryAddress,
    String? phone,
    String? notes,
    double deliveryFee = 0,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);

      final order = MarketOrder(
        id: '',
        buyerId: _userId!,
        buyerName: _userName ?? 'Customer',
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: subtotal + deliveryFee,
        deliveryAddress: deliveryAddress,
        buyerPhone: phone,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final docRef = await _ordersCollection.add(order.toMap());

      // Update product stock
      for (var item in items) {
        final product = await getProductById(item.productId);
        if (product != null) {
          final newStock = (product.stock - item.quantity).clamp(0, product.stock);
          await updateProductStock(item.productId, newStock);
        }
      }

      // Clear cart
      await clearCart();

      return docRef.id;
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  /// Get buyer's orders
  Stream<List<MarketOrder>> getMyOrdersStream() {
    if (_userId == null) return Stream.value([]);

    return _ordersCollection
        .where('buyerId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarketOrder.fromFirestore(doc))
          .toList();
    });
  }

  /// Get seller's orders (orders containing their products)
  Stream<List<MarketOrder>> getSellerOrdersStream() {
    if (_userId == null) return Stream.value([]);

    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final orders = <MarketOrder>[];
      
      for (var doc in snapshot.docs) {
        final order = MarketOrder.fromFirestore(doc);
        // Check if any item belongs to this seller
        if (order.items.any((item) => item.sellerId == _userId)) {
          orders.add(order);
        }
      }
      
      return orders;
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };

      if (status == 'delivered') {
        updates['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await _ordersCollection.doc(orderId).update(updates);
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // ========== FAVORITES ==========

  /// Toggle favorite
  Future<void> toggleFavorite(String productId) async {
    if (_userId == null) return;

    try {
      final favRef = _favoritesCollection.doc(_userId);
      final favDoc = await favRef.get();

      if (!favDoc.exists) {
        await favRef.set({
          'productIds': [productId],
        });
      } else {
        final data = favDoc.data() as Map<String, dynamic>;
        final favorites = List<String>.from(data['productIds'] ?? []);

        if (favorites.contains(productId)) {
          favorites.remove(productId);
        } else {
          favorites.add(productId);
        }

        await favRef.update({'productIds': favorites});
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  /// Get favorites stream
  Stream<List<String>> getFavoritesStream() {
    if (_userId == null) return Stream.value([]);

    return _favoritesCollection.doc(_userId).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>?;
      return List<String>.from(data?['productIds'] ?? []);
    });
  }

  // ========== HELPERS ==========

  /// Upload product image
  Future<String> _uploadProductImage(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final storageRef = _storage.ref().child('products/$_userId/$fileName');
    final uploadTask = await storageRef.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  // ========== DEMO DATA ==========

  /// Get demo products for display
  static List<Map<String, dynamic>> getDemoProducts() {
    return [
      {
        'image': 'assets/images/equip1.jpg',
        'seller': 'AgriTech Store',
        'name': 'Modern Irrigation System',
        'price': 'EGX 8,500',
        'rating': 4.5,
        'reviews': 120,
        'category': 'equipment',
        'inStock': true,
        'discount': '15% OFF',
      },
      {
        'image': 'assets/images/Equip1.avif',
        'seller': 'Farm Solutions',
        'name': 'Drip Irrigation Kit',
        'price': 'EGX 4,200',
        'rating': 4.7,
        'reviews': 85,
        'category': 'irrigation',
        'inStock': true,
      },
      {
        'image': 'assets/images/truck.png',
        'seller': 'Heavy Machinery Co.',
        'name': 'Agricultural Truck',
        'price': 'EGX 150,000',
        'rating': 4.3,
        'reviews': 42,
        'category': 'equipment',
        'inStock': true,
      },
      {
        'image': 'assets/images/eq3.jpg',
        'seller': 'Tractor World',
        'name': 'Heavy Duty Tractor',
        'price': 'EGX 95,000',
        'rating': 4.8,
        'reviews': 156,
        'category': 'equipment',
        'inStock': false,
        'discount': '10% OFF',
      },
    ];
  }

  static List<Map<String, dynamic>> getDemoListings() {
    return [
      {
        'image': 'assets/images/Tomato.jpg',
        'name': 'Fresh Organic Tomatoes',
        'price': 'EGX 25/kg',
        'category': 'vegetables',
        'status': 'Active',
        'views': 142,
        'interested': 23,
        'stock': '150 kg',
      },
      {
        'image': 'assets/images/wheat.jpg',
        'name': 'Premium Wheat Grain',
        'price': 'EGX 8/kg',
        'category': 'grains',
        'status': 'Active',
        'views': 98,
        'interested': 15,
        'stock': '500 kg',
      },
    ];
  }
}

