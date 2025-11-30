import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_task.dart';
import 'auth_service.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Collection reference
  CollectionReference get _schedulesCollection => _firestore.collection('schedules');

  // Get current user ID
  String? get _currentUserId => _authService.currentUser?.uid;

  // Create a new schedule task
  Future<String?> createTask({
    required String title,
    required String description,
    required String farmName,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final task = ScheduleTask(
        id: '', // Will be set by Firestore
        userId: _currentUserId!,
        title: title,
        description: description,
        farmName: farmName,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        createdAt: DateTime.now(),
      );

      final docRef = await _schedulesCollection.add(task.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating task: $e');
      return null;
    }
  }

  // Get all tasks for current user
  Stream<List<ScheduleTask>> getUserTasks() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _schedulesCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScheduleTask.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    }).handleError((error) {
      print('Error getting user tasks: $error');
      return <ScheduleTask>[];
    });
  }

  // Get tasks for a specific date
  Stream<List<ScheduleTask>> getTasksForDate(DateTime date) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    // Simplified query to avoid composite index requirement
    // Filter by userId and orderBy startDateTime, then filter in-memory for date range
    return _schedulesCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ScheduleTask.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .where((task) {
            // Filter tasks that fall within the specified date
            final taskDate = DateTime(
              task.startDateTime.year,
              task.startDateTime.month,
              task.startDateTime.day,
            );
            final targetDate = DateTime(date.year, date.month, date.day);
            return taskDate.isAtSameMomentAs(targetDate);
          })
          .toList();
    }).handleError((error) {
      print('Error getting tasks for date: $error');
      return <ScheduleTask>[];
    });
  }

  // Get today's tasks
  Stream<List<ScheduleTask>> getTodaysTasks() {
    return getTasksForDate(DateTime.now());
  }

  // Get upcoming tasks (next 7 days)
  Stream<List<ScheduleTask>> getUpcomingTasks({int days = 7}) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endDate = startOfToday.add(Duration(days: days));

    // Simplified query - filter by userId and orderBy, then filter in-memory
    return _schedulesCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('startDateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ScheduleTask.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .where((task) {
            return task.startDateTime.isAfter(startOfToday) &&
                   task.startDateTime.isBefore(endDate);
          })
          .toList();
    }).handleError((error) {
      print('Error getting upcoming tasks: $error');
      return <ScheduleTask>[];
    });
  }

  // Update task completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _schedulesCollection.doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  // Update task
  Future<void> updateTask(ScheduleTask task) async {
    try {
      await _schedulesCollection.doc(task.id).update(task.toMap());
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _schedulesCollection.doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // Get task by ID
  Future<ScheduleTask?> getTaskById(String taskId) async {
    try {
      final doc = await _schedulesCollection.doc(taskId).get();
      if (doc.exists) {
        return ScheduleTask.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }
}

