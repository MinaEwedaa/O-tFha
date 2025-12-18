import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Crop status enum
enum CropStatus {
  planned,
  planted,
  growing,
  flowering,
  harvesting,
  harvested,
  failed,
}

/// Model for Farm Crop
class Crop {
  final String id;
  final String userId;
  final String name;
  final String nameArabic;
  final String variety;
  final String category; // vegetable, fruit, grain, etc.
  final String farmName;
  final String fieldLocation;
  final DateTime plantedDate;
  final DateTime expectedHarvestDate;
  final DateTime? actualHarvestDate;
  final double areaInFeddans; // Egyptian unit of land measurement
  final double progress; // 0.0 to 1.0
  final CropStatus status;
  final String? currentTask;
  final DateTime? nextTaskDate;
  final String? imageUrl;
  final String? notes;
  final double? expectedYield; // in kg
  final double? actualYield; // in kg
  final DateTime createdAt;
  final DateTime updatedAt;

  Crop({
    required this.id,
    required this.userId,
    required this.name,
    this.nameArabic = '',
    this.variety = '',
    required this.category,
    required this.farmName,
    this.fieldLocation = '',
    required this.plantedDate,
    required this.expectedHarvestDate,
    this.actualHarvestDate,
    this.areaInFeddans = 1.0,
    this.progress = 0.0,
    this.status = CropStatus.planted,
    this.currentTask,
    this.nextTaskDate,
    this.imageUrl,
    this.notes,
    this.expectedYield,
    this.actualYield,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate progress based on dates
  double get calculatedProgress {
    final now = DateTime.now();
    if (actualHarvestDate != null) return 1.0;
    if (now.isBefore(plantedDate)) return 0.0;
    if (now.isAfter(expectedHarvestDate)) return 0.95;
    
    final totalDays = expectedHarvestDate.difference(plantedDate).inDays;
    final elapsedDays = now.difference(plantedDate).inDays;
    
    if (totalDays <= 0) return 0.0;
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  /// Days until harvest
  int get daysUntilHarvest {
    if (actualHarvestDate != null) return 0;
    return expectedHarvestDate.difference(DateTime.now()).inDays;
  }

  /// Days since planted
  int get daysSincePlanted {
    return DateTime.now().difference(plantedDate).inDays;
  }

  /// Status label
  String get statusLabel {
    switch (status) {
      case CropStatus.planned:
        return 'Planned';
      case CropStatus.planted:
        return 'Planted';
      case CropStatus.growing:
        return 'Growing';
      case CropStatus.flowering:
        return 'Flowering';
      case CropStatus.harvesting:
        return 'Harvesting';
      case CropStatus.harvested:
        return 'Harvested';
      case CropStatus.failed:
        return 'Failed';
    }
  }

  /// Status label in Arabic
  String get statusLabelArabic {
    switch (status) {
      case CropStatus.planned:
        return 'مخطط';
      case CropStatus.planted:
        return 'مزروع';
      case CropStatus.growing:
        return 'ينمو';
      case CropStatus.flowering:
        return 'مزهر';
      case CropStatus.harvesting:
        return 'حصاد';
      case CropStatus.harvested:
        return 'محصود';
      case CropStatus.failed:
        return 'فاشل';
    }
  }

  factory Crop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Crop(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      nameArabic: data['nameArabic'] ?? '',
      variety: data['variety'] ?? '',
      category: data['category'] ?? 'vegetable',
      farmName: data['farmName'] ?? '',
      fieldLocation: data['fieldLocation'] ?? '',
      plantedDate: (data['plantedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expectedHarvestDate: (data['expectedHarvestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actualHarvestDate: (data['actualHarvestDate'] as Timestamp?)?.toDate(),
      areaInFeddans: (data['areaInFeddans'] ?? 1.0).toDouble(),
      progress: (data['progress'] ?? 0.0).toDouble(),
      status: CropStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => CropStatus.planted,
      ),
      currentTask: data['currentTask'],
      nextTaskDate: (data['nextTaskDate'] as Timestamp?)?.toDate(),
      imageUrl: data['imageUrl'],
      notes: data['notes'],
      expectedYield: data['expectedYield']?.toDouble(),
      actualYield: data['actualYield']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'nameArabic': nameArabic,
      'variety': variety,
      'category': category,
      'farmName': farmName,
      'fieldLocation': fieldLocation,
      'plantedDate': Timestamp.fromDate(plantedDate),
      'expectedHarvestDate': Timestamp.fromDate(expectedHarvestDate),
      'actualHarvestDate': actualHarvestDate != null ? Timestamp.fromDate(actualHarvestDate!) : null,
      'areaInFeddans': areaInFeddans,
      'progress': progress,
      'status': status.name,
      'currentTask': currentTask,
      'nextTaskDate': nextTaskDate != null ? Timestamp.fromDate(nextTaskDate!) : null,
      'imageUrl': imageUrl,
      'notes': notes,
      'expectedYield': expectedYield,
      'actualYield': actualYield,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Crop copyWith({
    String? id,
    String? userId,
    String? name,
    String? nameArabic,
    String? variety,
    String? category,
    String? farmName,
    String? fieldLocation,
    DateTime? plantedDate,
    DateTime? expectedHarvestDate,
    DateTime? actualHarvestDate,
    double? areaInFeddans,
    double? progress,
    CropStatus? status,
    String? currentTask,
    DateTime? nextTaskDate,
    String? imageUrl,
    String? notes,
    double? expectedYield,
    double? actualYield,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Crop(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      variety: variety ?? this.variety,
      category: category ?? this.category,
      farmName: farmName ?? this.farmName,
      fieldLocation: fieldLocation ?? this.fieldLocation,
      plantedDate: plantedDate ?? this.plantedDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      actualHarvestDate: actualHarvestDate ?? this.actualHarvestDate,
      areaInFeddans: areaInFeddans ?? this.areaInFeddans,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      currentTask: currentTask ?? this.currentTask,
      nextTaskDate: nextTaskDate ?? this.nextTaskDate,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      expectedYield: expectedYield ?? this.expectedYield,
      actualYield: actualYield ?? this.actualYield,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model for Farm
class Farm {
  final String id;
  final String userId;
  final String name;
  final String nameArabic;
  final String location;
  final double areaInFeddans;
  final String? description;
  final DateTime createdAt;

  Farm({
    required this.id,
    required this.userId,
    required this.name,
    this.nameArabic = '',
    required this.location,
    this.areaInFeddans = 1.0,
    this.description,
    required this.createdAt,
  });

  factory Farm.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Farm(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      nameArabic: data['nameArabic'] ?? '',
      location: data['location'] ?? '',
      areaInFeddans: (data['areaInFeddans'] ?? 1.0).toDouble(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'nameArabic': nameArabic,
      'location': location,
      'areaInFeddans': areaInFeddans,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Crop Statistics
class CropStatistics {
  final int totalCrops;
  final int activeCrops;
  final int harvestedCrops;
  final double totalAreaInFeddans;
  final Map<String, int> cropsByCategory;
  final Map<CropStatus, int> cropsByStatus;

  CropStatistics({
    required this.totalCrops,
    required this.activeCrops,
    required this.harvestedCrops,
    required this.totalAreaInFeddans,
    required this.cropsByCategory,
    required this.cropsByStatus,
  });

  factory CropStatistics.empty() {
    return CropStatistics(
      totalCrops: 0,
      activeCrops: 0,
      harvestedCrops: 0,
      totalAreaInFeddans: 0,
      cropsByCategory: {},
      cropsByStatus: {},
    );
  }

  factory CropStatistics.fromCrops(List<Crop> crops) {
    Map<String, int> byCategory = {};
    Map<CropStatus, int> byStatus = {};
    double totalArea = 0;
    int harvested = 0;
    int active = 0;

    for (var crop in crops) {
      totalArea += crop.areaInFeddans;
      byCategory[crop.category] = (byCategory[crop.category] ?? 0) + 1;
      byStatus[crop.status] = (byStatus[crop.status] ?? 0) + 1;

      if (crop.status == CropStatus.harvested) {
        harvested++;
      } else if (crop.status != CropStatus.failed && crop.status != CropStatus.planned) {
        active++;
      }
    }

    return CropStatistics(
      totalCrops: crops.length,
      activeCrops: active,
      harvestedCrops: harvested,
      totalAreaInFeddans: totalArea,
      cropsByCategory: byCategory,
      cropsByStatus: byStatus,
    );
  }
}

/// Crop categories
class CropCategories {
  static const List<Map<String, String>> all = [
    {'id': 'vegetable', 'name': 'Vegetables', 'nameAr': 'خضروات', 'icon': '🥬'},
    {'id': 'fruit', 'name': 'Fruits', 'nameAr': 'فواكه', 'icon': '🍎'},
    {'id': 'grain', 'name': 'Grains', 'nameAr': 'حبوب', 'icon': '🌾'},
    {'id': 'legume', 'name': 'Legumes', 'nameAr': 'بقوليات', 'icon': '🫘'},
    {'id': 'herb', 'name': 'Herbs', 'nameAr': 'أعشاب', 'icon': '🌿'},
    {'id': 'cash', 'name': 'Cash Crops', 'nameAr': 'محاصيل نقدية', 'icon': '🌱'},
    {'id': 'other', 'name': 'Other', 'nameAr': 'أخرى', 'icon': '🪴'},
  ];

  static String getIcon(String categoryId) {
    return all.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'icon': '🌱'},
    )['icon']!;
  }

  static String getName(String categoryId, {bool arabic = false}) {
    final category = all.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'name': 'Other', 'nameAr': 'أخرى'},
    );
    return arabic ? category['nameAr']! : category['name']!;
  }
}

/// Crop Service - Firebase Integration for Crop Management
class CropService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _cropsCollection => _firestore.collection('crops');
  CollectionReference get _farmsCollection => _firestore.collection('farms');

  // ========== CROPS CRUD ==========

  /// Get all crops stream (real-time)
  Stream<List<Crop>> getCropsStream({
    String? farmName,
    String? category,
    CropStatus? status,
  }) {
    if (_userId == null) return Stream.value([]);

    // NOTE:
    // Using both `where` and `orderBy` on different fields in Firestore
    // often requires a composite index. On some setups this was causing
    // a "failed to load crops" error in the UI.
    //
    // To make the crops list work out‑of‑the‑box without requiring a
    // manual index configuration, we keep the `where` filter and sort
    // results in memory instead of using `orderBy` in the query.

    return _cropsCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      var crops = snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList();

      // Sort by plantedDate (newest first) in memory
      crops.sort(
        (a, b) => b.plantedDate.compareTo(a.plantedDate),
      );

      // Apply filters in-memory
      if (farmName != null && farmName.isNotEmpty) {
        crops = crops.where((c) => c.farmName == farmName).toList();
      }
      if (category != null && category != 'all') {
        crops = crops.where((c) => c.category == category).toList();
      }
      if (status != null) {
        crops = crops.where((c) => c.status == status).toList();
      }

      return crops;
    });
  }

  /// Get single crop by ID
  Future<Crop?> getCropById(String cropId) async {
    try {
      final doc = await _cropsCollection.doc(cropId).get();
      if (doc.exists) {
        return Crop.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting crop: $e');
      return null;
    }
  }

  /// Add new crop
  Future<String?> addCrop(Crop crop, {File? imageFile}) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadCropImage(imageFile);
      }

      final docRef = await _cropsCollection.add(
        crop.copyWith(
          userId: _userId,
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ).toMap(),
      );
      return docRef.id;
    } catch (e) {
      print('Error adding crop: $e');
      rethrow;
    }
  }

  /// Update crop
  Future<void> updateCrop(Crop crop, {File? imageFile}) async {
    try {
      String? imageUrl = crop.imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadCropImage(imageFile);
      }

      await _cropsCollection.doc(crop.id).update(
        crop.copyWith(
          imageUrl: imageUrl,
          updatedAt: DateTime.now(),
        ).toMap(),
      );
    } catch (e) {
      print('Error updating crop: $e');
      rethrow;
    }
  }

  /// Update crop status
  Future<void> updateCropStatus(String cropId, CropStatus newStatus) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If harvested, set actual harvest date
      if (newStatus == CropStatus.harvested) {
        updates['actualHarvestDate'] = Timestamp.fromDate(DateTime.now());
        updates['progress'] = 1.0;
      }

      await _cropsCollection.doc(cropId).update(updates);
    } catch (e) {
      print('Error updating crop status: $e');
      rethrow;
    }
  }

  /// Update crop progress
  Future<void> updateCropProgress(String cropId, double progress) async {
    try {
      await _cropsCollection.doc(cropId).update({
        'progress': progress.clamp(0.0, 1.0),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating crop progress: $e');
      rethrow;
    }
  }

  /// Delete crop
  Future<void> deleteCrop(String cropId) async {
    try {
      // Delete image if exists
      final crop = await getCropById(cropId);
      if (crop?.imageUrl != null && crop!.imageUrl!.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(crop.imageUrl!);
          await ref.delete();
        } catch (e) {
          print('Error deleting crop image: $e');
        }
      }

      await _cropsCollection.doc(cropId).delete();
    } catch (e) {
      print('Error deleting crop: $e');
      rethrow;
    }
  }

  // ========== FARMS ==========

  /// Get farms stream
  Stream<List<Farm>> getFarmsStream() {
    if (_userId == null) return Stream.value([]);

    return _farmsCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Farm.fromFirestore(doc)).toList();
    });
  }

  /// Add new farm
  Future<String?> addFarm(Farm farm) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final docRef = await _farmsCollection.add({
        ...farm.toMap(),
        'userId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding farm: $e');
      rethrow;
    }
  }

  /// Get farm names for dropdown
  Future<List<String>> getFarmNames() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _farmsCollection
          .where('userId', isEqualTo: _userId)
          .get();

      return snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
          .toList();
    } catch (e) {
      print('Error getting farm names: $e');
      return [];
    }
  }

  // ========== STATISTICS ==========

  /// Get crop statistics
  Future<CropStatistics> getCropStatistics() async {
    if (_userId == null) return CropStatistics.empty();

    try {
      final snapshot = await _cropsCollection
          .where('userId', isEqualTo: _userId)
          .get();

      final crops = snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList();
      return CropStatistics.fromCrops(crops);
    } catch (e) {
      print('Error getting statistics: $e');
      return CropStatistics.empty();
    }
  }

  /// Get upcoming harvests
  Future<List<Crop>> getUpcomingHarvests({int days = 30}) async {
    if (_userId == null) return [];

    final endDate = DateTime.now().add(Duration(days: days));

    try {
      final snapshot = await _cropsCollection
          .where('userId', isEqualTo: _userId)
          .get();

      return snapshot.docs
          .map((doc) => Crop.fromFirestore(doc))
          .where((crop) =>
              crop.status != CropStatus.harvested &&
              crop.status != CropStatus.failed &&
              crop.expectedHarvestDate.isAfter(DateTime.now()) &&
              crop.expectedHarvestDate.isBefore(endDate))
          .toList()
        ..sort((a, b) => a.expectedHarvestDate.compareTo(b.expectedHarvestDate));
    } catch (e) {
      print('Error getting upcoming harvests: $e');
      return [];
    }
  }

  // ========== HELPERS ==========

  /// Upload crop image
  Future<String> _uploadCropImage(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final storageRef = _storage.ref().child('crops/$_userId/$fileName');
    final uploadTask = await storageRef.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  // ========== DEMO DATA ==========

  /// Get demo crops
  static List<Crop> getDemoCrops() {
    final now = DateTime.now();
    return [
      Crop(
        id: '1',
        userId: 'demo',
        name: 'Tomatoes',
        nameArabic: 'طماطم',
        variety: 'Roma',
        category: 'vegetable',
        farmName: 'Main Farm',
        fieldLocation: 'Field A',
        plantedDate: now.subtract(const Duration(days: 60)),
        expectedHarvestDate: now.add(const Duration(days: 30)),
        progress: 0.65,
        status: CropStatus.growing,
        currentTask: 'Irrigation',
        nextTaskDate: now.add(const Duration(days: 2)),
        areaInFeddans: 2.5,
        expectedYield: 5000,
        createdAt: now,
        updatedAt: now,
      ),
      Crop(
        id: '2',
        userId: 'demo',
        name: 'Wheat',
        nameArabic: 'قمح',
        variety: 'Giza 171',
        category: 'grain',
        farmName: 'Main Farm',
        fieldLocation: 'Field B',
        plantedDate: now.subtract(const Duration(days: 120)),
        expectedHarvestDate: now.subtract(const Duration(days: 5)),
        actualHarvestDate: now.subtract(const Duration(days: 5)),
        progress: 1.0,
        status: CropStatus.harvested,
        areaInFeddans: 10.0,
        expectedYield: 20000,
        actualYield: 21500,
        createdAt: now,
        updatedAt: now,
      ),
      Crop(
        id: '3',
        userId: 'demo',
        name: 'Cucumber',
        nameArabic: 'خيار',
        variety: 'Armenian',
        category: 'vegetable',
        farmName: 'Greenhouse',
        fieldLocation: 'House 1',
        plantedDate: now.subtract(const Duration(days: 30)),
        expectedHarvestDate: now.add(const Duration(days: 15)),
        progress: 0.7,
        status: CropStatus.flowering,
        currentTask: 'Pest Control',
        nextTaskDate: now.add(const Duration(days: 1)),
        areaInFeddans: 0.5,
        expectedYield: 2000,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
















