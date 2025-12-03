import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for Community Posts/Discussions
class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final String? imageUrl;
  final String category; // 'discussion', 'question', 'tip', 'announcement'
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLikedByCurrentUser;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar = '',
    required this.content,
    this.imageUrl,
    required this.category,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.isLikedByCurrentUser = false,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc, {bool isLiked = false}) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorAvatar: data['authorAvatar'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'discussion',
      tags: List<String>.from(data['tags'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLikedByCurrentUser: isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Model for Equipment Sharing/Rental
class SharedEquipment {
  final String id;
  final String ownerId;
  final String ownerName;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double pricePerDay;
  final String location;
  final bool isAvailable;
  final DateTime createdAt;

  SharedEquipment({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.name,
    required this.description,
    this.imageUrl = '',
    required this.category,
    required this.pricePerDay,
    required this.location,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory SharedEquipment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SharedEquipment(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? 'Unknown',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'equipment',
      pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'pricePerDay': pricePerDay,
      'location': location,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Model for Expert Consultation
class ExpertConsultant {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final double pricePerHour;
  final bool isAvailable;
  final List<String> languages;

  ExpertConsultant({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    this.imageUrl = '',
    this.rating = 0,
    this.reviewsCount = 0,
    required this.pricePerHour,
    this.isAvailable = true,
    this.languages = const ['English', 'Arabic'],
  });

  factory ExpertConsultant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpertConsultant(
      id: doc.id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      bio: data['bio'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      languages: List<String>.from(data['languages'] ?? ['English', 'Arabic']),
    );
  }
}

/// Model for Community Events
class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String organizer;
  final int attendeesCount;
  final bool isFree;
  final double price;
  final String category; // 'training', 'market', 'social', 'workshop'

  CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.organizer,
    this.attendeesCount = 0,
    this.isFree = true,
    this.price = 0,
    required this.category,
  });

  factory CommunityEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      location: data['location'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      organizer: data['organizer'] ?? '',
      attendeesCount: data['attendeesCount'] ?? 0,
      isFree: data['isFree'] ?? true,
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'social',
    );
  }
}

/// Community Service - Handles all community-related Firebase operations
class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName;

  // ========== POSTS/DISCUSSIONS ==========

  /// Get all community posts stream
  Stream<List<CommunityPost>> getPosts({String? category}) {
    Query query = _firestore
        .collection('community_posts')
        .orderBy('createdAt', descending: true);

    if (category != null && category != 'all') {
      query = query.where('category', isEqualTo: category);
    }

    return query.limit(50).snapshots().asyncMap((snapshot) async {
      final posts = <CommunityPost>[];
      for (final doc in snapshot.docs) {
        bool isLiked = false;
        if (currentUserId != null) {
          final likeDoc = await doc.reference
              .collection('likes')
              .doc(currentUserId)
              .get();
          isLiked = likeDoc.exists;
        }
        posts.add(CommunityPost.fromFirestore(doc, isLiked: isLiked));
      }
      return posts;
    });
  }

  /// Create a new post
  Future<void> createPost({
    required String content,
    required String category,
    String? imageUrl,
    List<String> tags = const [],
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore.collection('community_posts').add({
      'authorId': currentUserId,
      'authorName': currentUserName ?? 'Anonymous',
      'authorAvatar': _auth.currentUser?.photoURL ?? '',
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'tags': tags,
      'likesCount': 0,
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Like/unlike a post
  Future<void> toggleLike(String postId) async {
    if (currentUserId == null) return;

    final postRef = _firestore.collection('community_posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(currentUserId);

    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      await likeRef.delete();
      await postRef.update({'likesCount': FieldValue.increment(-1)});
    } else {
      await likeRef.set({'createdAt': FieldValue.serverTimestamp()});
      await postRef.update({'likesCount': FieldValue.increment(1)});
    }
  }

  // ========== EQUIPMENT SHARING ==========

  /// Get available shared equipment
  Stream<List<SharedEquipment>> getSharedEquipment({String? category}) {
    Query query = _firestore
        .collection('shared_equipment')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null && category != 'all') {
      query = _firestore
          .collection('shared_equipment')
          .where('isAvailable', isEqualTo: true)
          .where('category', isEqualTo: category);
    }

    return query.limit(50).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SharedEquipment.fromFirestore(doc))
          .toList();
    });
  }

  /// Share your equipment
  Future<void> shareEquipment({
    required String name,
    required String description,
    required String category,
    required double pricePerDay,
    required String location,
    String? imageUrl,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore.collection('shared_equipment').add({
      'ownerId': currentUserId,
      'ownerName': currentUserName ?? 'Anonymous',
      'name': name,
      'description': description,
      'category': category,
      'pricePerDay': pricePerDay,
      'location': location,
      'imageUrl': imageUrl ?? '',
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Request to rent equipment
  Future<void> requestEquipment({
    required String equipmentId,
    required DateTime startDate,
    required DateTime endDate,
    String? message,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore.collection('equipment_requests').add({
      'equipmentId': equipmentId,
      'requesterId': currentUserId,
      'requesterName': currentUserName ?? 'Anonymous',
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'message': message,
      'status': 'pending', // pending, approved, rejected
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== EXPERT CONSULTATIONS ==========

  /// Get available experts
  Stream<List<ExpertConsultant>> getExperts({String? specialty}) {
    Query query = _firestore
        .collection('experts')
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true);

    if (specialty != null && specialty != 'all') {
      query = _firestore
          .collection('experts')
          .where('isAvailable', isEqualTo: true)
          .where('specialty', isEqualTo: specialty);
    }

    return query.limit(20).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpertConsultant.fromFirestore(doc))
          .toList();
    });
  }

  /// Book a consultation
  Future<void> bookConsultation({
    required String expertId,
    required DateTime dateTime,
    required int durationMinutes,
    String? topic,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore.collection('consultations').add({
      'expertId': expertId,
      'clientId': currentUserId,
      'clientName': currentUserName ?? 'Anonymous',
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMinutes': durationMinutes,
      'topic': topic,
      'status': 'pending', // pending, confirmed, completed, cancelled
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== COMMUNITY EVENTS ==========

  /// Get upcoming events
  Stream<List<CommunityEvent>> getEvents({String? category}) {
    Query query = _firestore
        .collection('community_events')
        .where('endDate', isGreaterThan: Timestamp.now())
        .orderBy('endDate')
        .orderBy('startDate');

    return query.limit(20).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CommunityEvent.fromFirestore(doc))
          .toList();
    });
  }

  /// Register for an event
  Future<void> registerForEvent(String eventId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final eventRef = _firestore.collection('community_events').doc(eventId);
    final attendeeRef = eventRef.collection('attendees').doc(currentUserId);

    final attendeeDoc = await attendeeRef.get();

    if (!attendeeDoc.exists) {
      await attendeeRef.set({
        'userId': currentUserId,
        'userName': currentUserName ?? 'Anonymous',
        'registeredAt': FieldValue.serverTimestamp(),
      });
      await eventRef.update({'attendeesCount': FieldValue.increment(1)});
    }
  }

  // ========== COOPERATIVE GROUPS ==========

  /// Get cooperative groups
  Stream<QuerySnapshot> getCooperativeGroups() {
    return _firestore
        .collection('cooperative_groups')
        .orderBy('membersCount', descending: true)
        .limit(20)
        .snapshots();
  }

  /// Join a cooperative group
  Future<void> joinGroup(String groupId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final groupRef = _firestore.collection('cooperative_groups').doc(groupId);
    final memberRef = groupRef.collection('members').doc(currentUserId);

    final memberDoc = await memberRef.get();

    if (!memberDoc.exists) {
      await memberRef.set({
        'userId': currentUserId,
        'userName': currentUserName ?? 'Anonymous',
        'joinedAt': FieldValue.serverTimestamp(),
      });
      await groupRef.update({'membersCount': FieldValue.increment(1)});
    }
  }

  // ========== HELPER METHODS ==========

  /// Get sample/demo data for testing
  static List<CommunityPost> getDemoPosts() {
    return [
      CommunityPost(
        id: '1',
        authorId: 'demo1',
        authorName: 'Ahmed Hassan',
        content: 'Just harvested my first batch of organic tomatoes! 🍅 The drip irrigation system really made a difference this season. Happy to share tips with anyone interested!',
        category: 'tip',
        tags: ['organic', 'tomatoes', 'irrigation'],
        likesCount: 24,
        commentsCount: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        id: '2',
        authorId: 'demo2',
        authorName: 'Fatima Al-Said',
        content: 'Has anyone dealt with aphids on cucumber plants? Looking for organic solutions that actually work. My crop is at risk! 🥒',
        category: 'question',
        tags: ['pest-control', 'cucumber', 'organic'],
        likesCount: 12,
        commentsCount: 15,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        id: '3',
        authorId: 'demo3',
        authorName: 'Ministry of Agriculture',
        content: '📢 Important: New subsidies available for sustainable farming practices. Apply by end of month. Visit your local agricultural office for details.',
        category: 'announcement',
        tags: ['subsidy', 'government', 'sustainable'],
        likesCount: 156,
        commentsCount: 42,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<SharedEquipment> getDemoEquipment() {
    return [
      SharedEquipment(
        id: '1',
        ownerId: 'demo1',
        ownerName: 'Mohammed Farm',
        name: 'John Deere Tractor',
        description: 'Well-maintained 50HP tractor, perfect for medium-sized farms. Available on weekends.',
        category: 'machinery',
        pricePerDay: 150,
        location: 'Al-Riyadh District',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      SharedEquipment(
        id: '2',
        ownerId: 'demo2',
        ownerName: 'Green Valley Farm',
        name: 'Irrigation Pump System',
        description: 'Diesel-powered pump, suitable for large fields. Includes 100m hose.',
        category: 'irrigation',
        pricePerDay: 75,
        location: 'Eastern Province',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      SharedEquipment(
        id: '3',
        ownerId: 'demo3',
        ownerName: 'Ali Agricultural',
        name: 'Seed Spreader',
        description: 'Professional grade seed spreader, adjustable spread width.',
        category: 'equipment',
        pricePerDay: 40,
        location: 'Central District',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  static List<ExpertConsultant> getDemoExperts() {
    return [
      ExpertConsultant(
        id: '1',
        name: 'Dr. Abdullah Al-Farsi',
        specialty: 'Soil & Irrigation',
        bio: 'PhD in Agricultural Sciences with 15+ years experience in desert farming techniques.',
        rating: 4.9,
        reviewsCount: 127,
        pricePerHour: 50,
        languages: ['Arabic', 'English'],
      ),
      ExpertConsultant(
        id: '2',
        name: 'Eng. Sara Mohammed',
        specialty: 'Pest Management',
        bio: 'Integrated pest management specialist. Expert in organic and sustainable solutions.',
        rating: 4.7,
        reviewsCount: 89,
        pricePerHour: 40,
        languages: ['Arabic', 'English'],
      ),
      ExpertConsultant(
        id: '3',
        name: 'Dr. Khalid Ibrahim',
        specialty: 'Crop Science',
        bio: 'Former university professor specializing in vegetable crops and greenhouse cultivation.',
        rating: 4.8,
        reviewsCount: 156,
        pricePerHour: 60,
        languages: ['Arabic', 'English', 'French'],
      ),
    ];
  }

  static List<CommunityEvent> getDemoEvents() {
    return [
      CommunityEvent(
        id: '1',
        title: 'Modern Irrigation Workshop',
        description: 'Learn about drip irrigation, smart sensors, and water-saving techniques from industry experts.',
        location: 'Agricultural Training Center',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 4)),
        organizer: 'Ministry of Agriculture',
        attendeesCount: 45,
        isFree: true,
        category: 'workshop',
      ),
      CommunityEvent(
        id: '2',
        title: 'Weekly Farmers Market',
        description: 'Sell your fresh produce directly to consumers. No middleman fees!',
        location: 'Central Square',
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 3, hours: 6)),
        organizer: 'Farmers Cooperative',
        attendeesCount: 120,
        isFree: true,
        category: 'market',
      ),
      CommunityEvent(
        id: '3',
        title: 'Organic Certification Training',
        description: 'Get your farm certified organic. Learn about standards, documentation, and inspection process.',
        location: 'Online Webinar',
        startDate: DateTime.now().add(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 14, hours: 3)),
        organizer: 'Organic Farmers Association',
        attendeesCount: 78,
        isFree: false,
        price: 25,
        category: 'training',
      ),
    ];
  }
}

