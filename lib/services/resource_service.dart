import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user's resources (without orderBy to avoid index requirement)
  Stream<QuerySnapshot> getUserResources() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Query without orderBy - we'll sort in memory to avoid index requirement
    return _firestore
        .collection('resources')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Get resources filtered by category (without orderBy to avoid index requirement)
  Stream<QuerySnapshot> getResourcesByCategory(String category) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (category == 'All') {
      return getUserResources();
    }

    // Query without orderBy - we'll sort in memory to avoid index requirement
    return _firestore
        .collection('resources')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .snapshots();
  }

  // Add a new resource
  Future<String> addResource({
    required String name,
    required String category,
    required String status,
    required DateTime purchaseDate,
    String? description,
    String? location,
    double? purchasePrice,
    String? imageUrl,
    File? imageFile,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    String? uploadedImageUrl = imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final storageRef = _storage.ref().child('resources/$userId/$fileName');
        final uploadTask = await storageRef.putFile(imageFile);
        uploadedImageUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
        // Continue without image if upload fails
      }
    }

    // Create resource document
    final resourceData = {
      'userId': userId,
      'name': name,
      'category': category,
      'status': status,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'description': description ?? '',
      'location': location ?? '',
      'purchasePrice': purchasePrice ?? 0.0,
      'imageUrl': uploadedImageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('resources').add(resourceData);
    return docRef.id;
  }

  // Update a resource
  Future<void> updateResource({
    required String resourceId,
    String? name,
    String? category,
    String? status,
    DateTime? purchaseDate,
    String? description,
    String? location,
    double? purchasePrice,
    File? imageFile,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name;
    if (category != null) updateData['category'] = category;
    if (status != null) updateData['status'] = status;
    if (purchaseDate != null) updateData['purchaseDate'] = Timestamp.fromDate(purchaseDate);
    if (description != null) updateData['description'] = description;
    if (location != null) updateData['location'] = location;
    if (purchasePrice != null) updateData['purchasePrice'] = purchasePrice;

    // Upload new image if provided
    if (imageFile != null) {
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final storageRef = _storage.ref().child('resources/$userId/$fileName');
        final uploadTask = await storageRef.putFile(imageFile);
        final imageUrl = await uploadTask.ref.getDownloadURL();
        updateData['imageUrl'] = imageUrl;
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    await _firestore.collection('resources').doc(resourceId).update(updateData);
  }

  // Delete a resource
  Future<void> deleteResource(String resourceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get the resource to delete its image
    final doc = await _firestore.collection('resources').doc(resourceId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data?['imageUrl'] != null && data!['imageUrl'].isNotEmpty) {
        try {
          final imageRef = _storage.refFromURL(data['imageUrl']);
          await imageRef.delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }
    }

    await _firestore.collection('resources').doc(resourceId).delete();
  }

  // Search resources by name
  Future<List<DocumentSnapshot>> searchResources(String query) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await _firestore
        .collection('resources')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.where((doc) {
      final data = doc.data();
      final name = data['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
  }
}

