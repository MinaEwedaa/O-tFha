import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for Expense Category
class ExpenseCategory {
  final String id;
  final String name;
  final String nameArabic;
  final String icon;
  final String colorHex;

  ExpenseCategory({
    required this.id,
    required this.name,
    this.nameArabic = '',
    this.icon = 'money',
    this.colorHex = '#4CAF50',
  });

  factory ExpenseCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseCategory(
      id: doc.id,
      name: data['name'] ?? '',
      nameArabic: data['nameArabic'] ?? '',
      icon: data['icon'] ?? 'money',
      colorHex: data['colorHex'] ?? '#4CAF50',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameArabic': nameArabic,
      'icon': icon,
      'colorHex': colorHex,
    };
  }

  // Default expense categories
  static List<ExpenseCategory> get defaults => [
    ExpenseCategory(id: 'seeds', name: 'Seeds & Fertilizers', nameArabic: 'بذور وأسمدة', icon: 'grass', colorHex: '#4CAF50'),
    ExpenseCategory(id: 'equipment', name: 'Equipment & Tools', nameArabic: 'معدات وأدوات', icon: 'construction', colorHex: '#FF9800'),
    ExpenseCategory(id: 'labor', name: 'Labor & Wages', nameArabic: 'عمالة وأجور', icon: 'people', colorHex: '#2196F3'),
    ExpenseCategory(id: 'irrigation', name: 'Irrigation & Water', nameArabic: 'ري ومياه', icon: 'water_drop', colorHex: '#00BCD4'),
    ExpenseCategory(id: 'pesticides', name: 'Pesticides', nameArabic: 'مبيدات', icon: 'science', colorHex: '#F44336'),
    ExpenseCategory(id: 'transport', name: 'Transport', nameArabic: 'نقل', icon: 'local_shipping', colorHex: '#9C27B0'),
    ExpenseCategory(id: 'maintenance', name: 'Maintenance', nameArabic: 'صيانة', icon: 'build', colorHex: '#795548'),
    ExpenseCategory(id: 'other', name: 'Other', nameArabic: 'أخرى', icon: 'category', colorHex: '#607D8B'),
  ];
}

/// Model for Transaction (Income/Expense)
class FinancialTransaction {
  final String id;
  final String userId;
  final String title;
  final String titleArabic;
  final double amount; // Positive = income, Negative = expense
  final String category;
  final String? description;
  final DateTime date;
  final String transactionType; // 'income' or 'expense'
  final String? farmId;
  final String? attachmentUrl;
  final DateTime createdAt;

  FinancialTransaction({
    required this.id,
    required this.userId,
    required this.title,
    this.titleArabic = '',
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.transactionType,
    this.farmId,
    this.attachmentUrl,
    required this.createdAt,
  });

  bool get isIncome => transactionType == 'income';
  bool get isExpense => transactionType == 'expense';

  factory FinancialTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      titleArabic: data['titleArabic'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'other',
      description: data['description'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionType: data['transactionType'] ?? 'expense',
      farmId: data['farmId'],
      attachmentUrl: data['attachmentUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'titleArabic': titleArabic,
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      'transactionType': transactionType,
      'farmId': farmId,
      'attachmentUrl': attachmentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FinancialTransaction copyWith({
    String? id,
    String? userId,
    String? title,
    String? titleArabic,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? transactionType,
    String? farmId,
    String? attachmentUrl,
    DateTime? createdAt,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      titleArabic: titleArabic ?? this.titleArabic,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      transactionType: transactionType ?? this.transactionType,
      farmId: farmId ?? this.farmId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Financial Summary
class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> expensesByCategory;
  final int transactionCount;
  final DateTime periodStart;
  final DateTime periodEnd;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.transactionCount,
    required this.periodStart,
    required this.periodEnd,
  });

  double get balance => totalIncome - totalExpenses;
  double get profitMargin => totalIncome > 0 ? (balance / totalIncome) * 100 : 0;

  factory FinancialSummary.empty() {
    final now = DateTime.now();
    return FinancialSummary(
      totalIncome: 0,
      totalExpenses: 0,
      expensesByCategory: {},
      transactionCount: 0,
      periodStart: DateTime(now.year, now.month, 1),
      periodEnd: now,
    );
  }

  factory FinancialSummary.fromTransactions(
    List<FinancialTransaction> transactions,
    DateTime start,
    DateTime end,
  ) {
    double income = 0;
    double expenses = 0;
    Map<String, double> byCategory = {};

    for (var t in transactions) {
      if (t.isIncome) {
        income += t.amount.abs();
      } else {
        expenses += t.amount.abs();
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount.abs();
      }
    }

    return FinancialSummary(
      totalIncome: income,
      totalExpenses: expenses,
      expensesByCategory: byCategory,
      transactionCount: transactions.length,
      periodStart: start,
      periodEnd: end,
    );
  }
}

/// Expense Service - Firebase Integration for Financial Management
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _transactionsCollection => _firestore.collection('transactions');
  CollectionReference get _categoriesCollection => _firestore.collection('expense_categories');

  // ========== TRANSACTIONS ==========

  /// Get all transactions stream (real-time updates)
  Stream<List<FinancialTransaction>> getTransactionsStream({
    String? category,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (_userId == null) return Stream.value([]);

    return _transactionsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      var transactions = snapshot.docs
          .map((doc) => FinancialTransaction.fromFirestore(doc))
          .toList();

      // Apply filters in-memory for flexibility
      if (category != null && category != 'all') {
        transactions = transactions.where((t) => t.category == category).toList();
      }
      if (type != null) {
        transactions = transactions.where((t) => t.transactionType == type).toList();
      }
      if (startDate != null) {
        transactions = transactions.where((t) => t.date.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
      }
      if (endDate != null) {
        transactions = transactions.where((t) => t.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
      }

      return transactions;
    });
  }

  /// Get recent transactions
  Stream<List<FinancialTransaction>> getRecentTransactions({int limit = 10}) {
    if (_userId == null) return Stream.value([]);

    return _transactionsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FinancialTransaction.fromFirestore(doc))
          .toList();
    });
  }

  /// Add a new transaction
  Future<String?> addTransaction(FinancialTransaction transaction) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final docRef = await _transactionsCollection.add(
        transaction.copyWith(
          userId: _userId,
          createdAt: DateTime.now(),
        ).toMap(),
      );
      return docRef.id;
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  /// Update transaction
  Future<void> updateTransaction(FinancialTransaction transaction) async {
    try {
      await _transactionsCollection.doc(transaction.id).update(transaction.toMap());
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // ========== FINANCIAL SUMMARY ==========

  /// Get financial summary for a period
  Future<FinancialSummary> getFinancialSummary({
    String period = 'month', // 'week', 'month', 'year', 'all'
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    if (_userId == null) return FinancialSummary.empty();

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (period) {
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'custom':
        startDate = customStart ?? DateTime(now.year, now.month, 1);
        endDate = customEnd ?? now;
        break;
      default:
        startDate = DateTime(2000, 1, 1); // All time
    }

    try {
      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: _userId)
          .get();

      final transactions = snapshot.docs
          .map((doc) => FinancialTransaction.fromFirestore(doc))
          .where((t) => 
            t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            t.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();

      return FinancialSummary.fromTransactions(transactions, startDate, endDate);
    } catch (e) {
      print('Error getting financial summary: $e');
      return FinancialSummary.empty();
    }
  }

  /// Get monthly expenses breakdown
  Future<Map<String, double>> getMonthlyExpensesByCategory() async {
    if (_userId == null) return {};

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    try {
      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: _userId)
          .where('transactionType', isEqualTo: 'expense')
          .get();

      final Map<String, double> byCategory = {};
      
      for (var doc in snapshot.docs) {
        final transaction = FinancialTransaction.fromFirestore(doc);
        if (transaction.date.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
          byCategory[transaction.category] = 
            (byCategory[transaction.category] ?? 0) + transaction.amount.abs();
        }
      }

      return byCategory;
    } catch (e) {
      print('Error getting expenses by category: $e');
      return {};
    }
  }

  /// Get average daily expense
  Future<double> getAverageDailyExpense({int days = 30}) async {
    if (_userId == null) return 0;

    final startDate = DateTime.now().subtract(Duration(days: days));

    try {
      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: _userId)
          .where('transactionType', isEqualTo: 'expense')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final transaction = FinancialTransaction.fromFirestore(doc);
        if (transaction.date.isAfter(startDate)) {
          total += transaction.amount.abs();
        }
      }

      return total / days;
    } catch (e) {
      print('Error getting average daily expense: $e');
      return 0;
    }
  }

  // ========== CATEGORIES ==========

  /// Get expense categories
  Stream<List<ExpenseCategory>> getCategoriesStream() {
    return _categoriesCollection.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return ExpenseCategory.defaults;
      }
      return snapshot.docs
          .map((doc) => ExpenseCategory.fromFirestore(doc))
          .toList();
    });
  }

  /// Initialize default categories for user
  Future<void> initializeDefaultCategories() async {
    if (_userId == null) return;

    try {
      final snapshot = await _categoriesCollection.get();
      if (snapshot.docs.isEmpty) {
        for (var category in ExpenseCategory.defaults) {
          await _categoriesCollection.doc(category.id).set(category.toMap());
        }
      }
    } catch (e) {
      print('Error initializing categories: $e');
    }
  }

  // ========== DEMO DATA ==========

  /// Get demo transactions for display
  static List<FinancialTransaction> getDemoTransactions() {
    final now = DateTime.now();
    return [
      FinancialTransaction(
        id: '1',
        userId: 'demo',
        title: 'Fertilizer Purchase',
        titleArabic: 'شراء أسمدة',
        amount: -1250.00,
        category: 'seeds',
        date: now.subtract(const Duration(hours: 5)),
        transactionType: 'expense',
        createdAt: now,
      ),
      FinancialTransaction(
        id: '2',
        userId: 'demo',
        title: 'Crop Sale - Tomatoes',
        titleArabic: 'بيع محصول - طماطم',
        amount: 8500.00,
        category: 'income',
        date: now.subtract(const Duration(days: 1)),
        transactionType: 'income',
        createdAt: now,
      ),
      FinancialTransaction(
        id: '3',
        userId: 'demo',
        title: 'Labor Payment',
        titleArabic: 'دفع أجور',
        amount: -2100.00,
        category: 'labor',
        date: now.subtract(const Duration(days: 2)),
        transactionType: 'expense',
        createdAt: now,
      ),
      FinancialTransaction(
        id: '4',
        userId: 'demo',
        title: 'Tractor Maintenance',
        titleArabic: 'صيانة جرار',
        amount: -450.00,
        category: 'equipment',
        date: now.subtract(const Duration(days: 3)),
        transactionType: 'expense',
        createdAt: now,
      ),
      FinancialTransaction(
        id: '5',
        userId: 'demo',
        title: 'Crop Sale - Wheat',
        titleArabic: 'بيع محصول - قمح',
        amount: 15000.00,
        category: 'income',
        date: now.subtract(const Duration(days: 4)),
        transactionType: 'income',
        createdAt: now,
      ),
      FinancialTransaction(
        id: '6',
        userId: 'demo',
        title: 'Water Bill',
        titleArabic: 'فاتورة مياه',
        amount: -850.50,
        category: 'irrigation',
        date: now.subtract(const Duration(days: 5)),
        transactionType: 'expense',
        createdAt: now,
      ),
    ];
  }
}
















