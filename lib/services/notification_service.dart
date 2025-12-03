import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _notificationsRef {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId).collection('notifications');
  }

  // Get all notifications stream
  Stream<List<AppNotification>> getNotifications() {
    if (_userId == null) return Stream.value([]);
    
    try {
      return _notificationsRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromFirestore(doc))
              .toList())
          .handleError((error) {
            print('Error fetching notifications: $error');
            return <AppNotification>[];
          });
    } catch (e) {
      print('Exception in getNotifications: $e');
      return Stream.value([]);
    }
  }

  // Get unread notifications count
  Stream<int> getUnreadCount() {
    if (_userId == null) return Stream.value(0);
    
    try {
      return _notificationsRef
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length)
          .handleError((error) {
            print('Error fetching unread count: $error');
            return 0;
          });
    } catch (e) {
      print('Exception in getUnreadCount: $e');
      return Stream.value(0);
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) return;
    
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    
    final batch = _firestore.batch();
    final unreadDocs = await _notificationsRef
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (_userId == null) return;
    
    await _notificationsRef.doc(notificationId).delete();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    if (_userId == null) return;
    
    final batch = _firestore.batch();
    final allDocs = await _notificationsRef.get();
    
    for (var doc in allDocs.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // Add a notification (for testing or system use)
  Future<void> addNotification({
    required String title,
    required String titleAr,
    required String body,
    required String bodyAr,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    if (_userId == null) return;
    
    await _notificationsRef.add({
      'title': title,
      'titleAr': titleAr,
      'body': body,
      'bodyAr': bodyAr,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'data': data,
    });
  }

  // Create sample notifications for demo
  Future<void> createSampleNotifications() async {
    if (_userId == null) return;
    
    try {
      final existing = await _notificationsRef.limit(1).get();
      if (existing.docs.isNotEmpty) return; // Already has notifications
      
      final samples = [
        {
          'title': 'Weather Alert',
          'titleAr': 'تنبيه الطقس',
          'body': 'Rain expected tomorrow. Consider adjusting your irrigation schedule.',
          'bodyAr': 'من المتوقع هطول أمطار غداً. فكر في تعديل جدول الري الخاص بك.',
          'type': 'weather',
        },
        {
          'title': 'Task Reminder',
          'titleAr': 'تذكير بالمهمة',
          'body': 'You have 3 tasks scheduled for today.',
          'bodyAr': 'لديك 3 مهام مجدولة لهذا اليوم.',
          'type': 'task',
        },
        {
          'title': 'Market Update',
          'titleAr': 'تحديث السوق',
          'body': 'Tomato prices have increased by 15% this week.',
          'bodyAr': 'ارتفعت أسعار الطماطم بنسبة 15٪ هذا الأسبوع.',
          'type': 'market',
        },
        {
          'title': 'Community Post',
          'titleAr': 'منشور المجتمع',
          'body': 'Ahmed shared new tips about wheat cultivation.',
          'bodyAr': 'شارك أحمد نصائح جديدة حول زراعة القمح.',
          'type': 'community',
        },
        {
          'title': 'Welcome to O-TFha!',
          'titleAr': 'مرحباً بك في عطفها!',
          'body': 'Start by adding your first crop to track your farm.',
          'bodyAr': 'ابدأ بإضافة أول محصول لتتبع مزرعتك.',
          'type': 'system',
        },
      ];

      for (var i = 0; i < samples.length; i++) {
        await _notificationsRef.add({
          ...samples[i],
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(hours: i * 2)),
          ),
          'isRead': i > 2, // First 3 are unread
        });
      }
    } catch (e) {
      print('Error creating sample notifications: $e');
    }
  }
}

