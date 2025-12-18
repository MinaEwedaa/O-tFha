import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/seed_inventory_model.dart';

/// Service for managing seed inventory in Firebase
class SeedInventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Collection reference
  CollectionReference get _seedsCollection => _firestore.collection('seed_inventory');
  CollectionReference get _usageLogsCollection => _firestore.collection('seed_usage_logs');

  // ========== CRUD OPERATIONS ==========

  /// Get all seeds for current user (stream)
  Stream<List<SeedInventory>> getSeedsStream({String? category, String? status}) {
    if (_userId == null) return Stream.value([]);

    Query query = _seedsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('updatedAt', descending: true);

    if (category != null && category != 'all') {
      query = _seedsCollection
          .where('userId', isEqualTo: _userId)
          .where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SeedInventory.fromFirestore(doc)).toList();
    });
  }

  /// Get single seed by ID
  Future<SeedInventory?> getSeedById(String seedId) async {
    try {
      final doc = await _seedsCollection.doc(seedId).get();
      if (doc.exists) {
        return SeedInventory.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting seed: $e');
      return null;
    }
  }

  /// Add new seed to inventory
  Future<String?> addSeed(SeedInventory seed) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final docRef = await _seedsCollection.add(seed.copyWith(
        userId: _userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding seed: $e');
      rethrow;
    }
  }

  /// Update existing seed
  Future<void> updateSeed(SeedInventory seed) async {
    try {
      await _seedsCollection.doc(seed.id).update(
        seed.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      print('Error updating seed: $e');
      rethrow;
    }
  }

  /// Delete seed
  Future<void> deleteSeed(String seedId) async {
    try {
      await _seedsCollection.doc(seedId).delete();
      // Also delete usage logs for this seed
      final logsSnapshot = await _usageLogsCollection
          .where('seedId', isEqualTo: seedId)
          .get();
      for (var doc in logsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting seed: $e');
      rethrow;
    }
  }

  // ========== QUANTITY MANAGEMENT ==========

  /// Use seeds (reduce quantity)
  Future<void> useSeeds({
    required String seedId,
    required double quantityUsed,
    required String purpose,
    String? fieldLocation,
    String? notes,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      // Get current seed
      final seed = await getSeedById(seedId);
      if (seed == null) throw Exception('Seed not found');

      if (quantityUsed > seed.quantity) {
        throw Exception('Not enough seeds in stock');
      }

      // Update seed quantity
      final newQuantity = seed.quantity - quantityUsed;
      SeedStatus newStatus = seed.status;
      
      if (newQuantity <= 0) {
        newStatus = SeedStatus.outOfStock;
      } else if (newQuantity <= 0.5) {
        newStatus = SeedStatus.lowStock;
      }

      await _seedsCollection.doc(seedId).update({
        'quantity': newQuantity,
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log the usage
      await _usageLogsCollection.add(SeedUsageLog(
        id: '',
        seedId: seedId,
        quantityUsed: quantityUsed,
        purpose: purpose,
        fieldLocation: fieldLocation,
        notes: notes,
        usedAt: DateTime.now(),
      ).toMap());
    } catch (e) {
      print('Error using seeds: $e');
      rethrow;
    }
  }

  /// Restock seeds (increase quantity)
  Future<void> restockSeeds({
    required String seedId,
    required double quantityAdded,
    double? newPricePerUnit,
    DateTime? newExpiryDate,
  }) async {
    try {
      final seed = await getSeedById(seedId);
      if (seed == null) throw Exception('Seed not found');

      final updates = <String, dynamic>{
        'quantity': seed.quantity + quantityAdded,
        'status': SeedStatus.available.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newPricePerUnit != null) {
        updates['pricePerUnit'] = newPricePerUnit;
      }

      if (newExpiryDate != null) {
        updates['expiryDate'] = Timestamp.fromDate(newExpiryDate);
      }

      await _seedsCollection.doc(seedId).update(updates);
    } catch (e) {
      print('Error restocking seeds: $e');
      rethrow;
    }
  }

  // ========== STATISTICS & REPORTS ==========

  /// Get inventory statistics
  Future<SeedInventoryStats> getInventoryStats() async {
    if (_userId == null) return SeedInventoryStats.empty();

    try {
      final snapshot = await _seedsCollection
          .where('userId', isEqualTo: _userId)
          .get();

      final seeds = snapshot.docs
          .map((doc) => SeedInventory.fromFirestore(doc))
          .toList();

      return SeedInventoryStats.fromSeeds(seeds);
    } catch (e) {
      print('Error getting stats: $e');
      return SeedInventoryStats.empty();
    }
  }

  /// Get expiring seeds (within days)
  Future<List<SeedInventory>> getExpiringSeeds({int withinDays = 30}) async {
    if (_userId == null) return [];

    try {
      final snapshot = await _seedsCollection
          .where('userId', isEqualTo: _userId)
          .get();

      final seeds = snapshot.docs
          .map((doc) => SeedInventory.fromFirestore(doc))
          .where((seed) {
            if (seed.expiryDate == null) return false;
            final daysUntilExpiry = seed.expiryDate!.difference(DateTime.now()).inDays;
            return daysUntilExpiry >= 0 && daysUntilExpiry <= withinDays;
          })
          .toList();

      // Sort by expiry date
      seeds.sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
      return seeds;
    } catch (e) {
      print('Error getting expiring seeds: $e');
      return [];
    }
  }

  /// Get low stock seeds
  Future<List<SeedInventory>> getLowStockSeeds() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _seedsCollection
          .where('userId', isEqualTo: _userId)
          .where('status', isEqualTo: SeedStatus.lowStock.name)
          .get();

      return snapshot.docs
          .map((doc) => SeedInventory.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting low stock seeds: $e');
      return [];
    }
  }

  /// Get usage logs for a seed
  Stream<List<SeedUsageLog>> getUsageLogsStream(String seedId) {
    return _usageLogsCollection
        .where('seedId', isEqualTo: seedId)
        .orderBy('usedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SeedUsageLog.fromFirestore(doc)).toList();
    });
  }

  /// Get all seeds for report export
  Future<List<SeedInventory>> getAllSeedsForExport() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _seedsCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('category')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => SeedInventory.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting seeds for export: $e');
      return [];
    }
  }

  // ========== DEMO DATA ==========

  /// Get demo seeds for testing
  static List<SeedInventory> getDemoSeeds() {
    final now = DateTime.now();
    return [
      SeedInventory(
        id: '1',
        userId: 'demo',
        name: 'Tomato Seeds',
        nameArabic: 'بذور طماطم',
        variety: 'Roma',
        category: 'vegetable',
        quantity: 2.5,
        unit: 'kg',
        pricePerUnit: 150,
        purchaseDate: now.subtract(const Duration(days: 30)),
        expiryDate: now.add(const Duration(days: 180)),
        supplier: 'مزرعة الخير',
        storageLocation: 'مخزن رقم 1',
        status: SeedStatus.available,
        createdAt: now,
        updatedAt: now,
      ),
      SeedInventory(
        id: '2',
        userId: 'demo',
        name: 'Cucumber Seeds',
        nameArabic: 'بذور خيار',
        variety: 'Armenian',
        category: 'vegetable',
        quantity: 0.3,
        unit: 'kg',
        pricePerUnit: 200,
        purchaseDate: now.subtract(const Duration(days: 60)),
        expiryDate: now.add(const Duration(days: 15)),
        supplier: 'شركة البذور',
        storageLocation: 'مخزن رقم 1',
        status: SeedStatus.lowStock,
        createdAt: now,
        updatedAt: now,
      ),
      SeedInventory(
        id: '3',
        userId: 'demo',
        name: 'Wheat Seeds',
        nameArabic: 'بذور قمح',
        variety: 'Giza 171',
        category: 'grain',
        quantity: 50,
        unit: 'kg',
        pricePerUnit: 25,
        purchaseDate: now.subtract(const Duration(days: 15)),
        expiryDate: now.add(const Duration(days: 365)),
        supplier: 'وزارة الزراعة',
        storageLocation: 'صومعة الحبوب',
        status: SeedStatus.available,
        createdAt: now,
        updatedAt: now,
      ),
      SeedInventory(
        id: '4',
        userId: 'demo',
        name: 'Basil Seeds',
        nameArabic: 'بذور ريحان',
        variety: 'Sweet Basil',
        category: 'herb',
        quantity: 100,
        unit: 'g',
        pricePerUnit: 5,
        purchaseDate: now.subtract(const Duration(days: 45)),
        expiryDate: now.subtract(const Duration(days: 5)),
        supplier: 'محل البذور',
        storageLocation: 'مخزن رقم 2',
        status: SeedStatus.expired,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

/// Seed Inventory Statistics
class SeedInventoryStats {
  final int totalItems;
  final double totalValue;
  final int expiredCount;
  final int expiringSoonCount;
  final int lowStockCount;
  final Map<String, int> byCategory;

  SeedInventoryStats({
    required this.totalItems,
    required this.totalValue,
    required this.expiredCount,
    required this.expiringSoonCount,
    required this.lowStockCount,
    required this.byCategory,
  });

  factory SeedInventoryStats.empty() {
    return SeedInventoryStats(
      totalItems: 0,
      totalValue: 0,
      expiredCount: 0,
      expiringSoonCount: 0,
      lowStockCount: 0,
      byCategory: {},
    );
  }

  factory SeedInventoryStats.fromSeeds(List<SeedInventory> seeds) {
    double totalValue = 0;
    int expiredCount = 0;
    int expiringSoonCount = 0;
    int lowStockCount = 0;
    Map<String, int> byCategory = {};

    for (var seed in seeds) {
      totalValue += seed.totalValue;
      
      if (seed.isExpired) {
        expiredCount++;
      } else if (seed.isExpiringSoon) {
        expiringSoonCount++;
      }
      
      if (seed.isLowStock) {
        lowStockCount++;
      }

      byCategory[seed.category] = (byCategory[seed.category] ?? 0) + 1;
    }

    return SeedInventoryStats(
      totalItems: seeds.length,
      totalValue: totalValue,
      expiredCount: expiredCount,
      expiringSoonCount: expiringSoonCount,
      lowStockCount: lowStockCount,
      byCategory: byCategory,
    );
  }
}
















