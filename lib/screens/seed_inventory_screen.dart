import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../models/seed_inventory_model.dart';
import '../services/seed_inventory_service.dart';
import '../services/report_service.dart';

class SeedInventoryScreen extends StatefulWidget {
  const SeedInventoryScreen({super.key});

  @override
  State<SeedInventoryScreen> createState() => _SeedInventoryScreenState();
}

class _SeedInventoryScreenState extends State<SeedInventoryScreen> with SingleTickerProviderStateMixin {
  final SeedInventoryService _inventoryService = SeedInventoryService();
  final ReportService _reportService = ReportService();
  
  late TabController _tabController;
  String _selectedCategory = 'all';
  bool _isExporting = false;
  
  // Demo mode for testing
  final bool _useDemoData = true;
  List<SeedInventory> _demoSeeds = [];
  
  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'All', 'nameAr': 'الكل', 'icon': Icons.grid_view_rounded},
    {'id': 'vegetable', 'name': 'Vegetables', 'nameAr': 'خضروات', 'icon': Icons.eco},
    {'id': 'fruit', 'name': 'Fruits', 'nameAr': 'فواكه', 'icon': Icons.apple},
    {'id': 'grain', 'name': 'Grains', 'nameAr': 'حبوب', 'icon': Icons.grass},
    {'id': 'herb', 'name': 'Herbs', 'nameAr': 'أعشاب', 'icon': Icons.spa},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _demoSeeds = SeedInventoryService.getDemoSeeds();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildStatsCards(),
              _buildCategoryFilter(),
              _buildTabBar(),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.defaultShadow],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مخزون البذور',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Seed Inventory',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Export button
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
            ),
            onSelected: _handleExport,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    const Text('Export as PDF'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    const Text('Export as Excel'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final seeds = _getFilteredSeeds();
    final stats = SeedInventoryStats.fromSeeds(seeds);
    
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildStatCard(
            'Total Items',
            'إجمالي الأصناف',
            stats.totalItems.toString(),
            Icons.inventory_2_outlined,
            AppColors.primary,
          ),
          _buildStatCard(
            'Total Value',
            'القيمة الإجمالية',
            'ج.م ${stats.totalValue.toStringAsFixed(0)}',
            Icons.attach_money,
            AppColors.secondary,
          ),
          _buildStatCard(
            'Low Stock',
            'مخزون منخفض',
            stats.lowStockCount.toString(),
            Icons.warning_amber_rounded,
            Colors.orange,
          ),
          _buildStatCard(
            'Expiring Soon',
            'ينتهي قريباً',
            stats.expiringSoonCount.toString(),
            Icons.timer_outlined,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String titleAr, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                titleAr,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['id'];
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedCategory = category['id']);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'],
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category['nameAr'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'All Seeds'),
          Tab(text: 'Low Stock'),
          Tab(text: 'Expiring'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSeedsList(_getFilteredSeeds()),
        _buildSeedsList(_getFilteredSeeds().where((s) => s.isLowStock).toList()),
        _buildSeedsList(_getFilteredSeeds().where((s) => s.isExpiringSoon || s.isExpired).toList()),
      ],
    );
  }

  Widget _buildSeedsList(List<SeedInventory> seeds) {
    if (seeds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا توجد بذور',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'No seeds found',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: seeds.length,
      itemBuilder: (context, index) {
        return _buildSeedCard(seeds[index], index);
      },
    );
  }

  Widget _buildSeedCard(SeedInventory seed, int index) {
    final categoryIcon = SeedCategories.getIcon(seed.category);
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (seed.isExpired) {
      statusColor = Colors.red;
      statusText = 'منتهي الصلاحية';
      statusIcon = Icons.error_outline;
    } else if (seed.isExpiringSoon) {
      statusColor = Colors.orange;
      statusText = 'ينتهي قريباً (${seed.daysUntilExpiry} يوم)';
      statusIcon = Icons.timer_outlined;
    } else if (seed.isLowStock) {
      statusColor = Colors.amber;
      statusText = 'مخزون منخفض';
      statusIcon = Icons.warning_amber;
    } else {
      statusColor = AppColors.success;
      statusText = 'متاح';
      statusIcon = Icons.check_circle_outline;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
          border: seed.isExpired
              ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showSeedDetails(seed),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Category icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(categoryIcon, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Seed info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seed.nameArabic.isNotEmpty ? seed.nameArabic : seed.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${seed.variety} • ${seed.name}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${seed.quantity.toStringAsFixed(1)} ${seed.unit}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bottom row
                  Row(
                    children: [
                      // Status
                      Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Value
                      Text(
                        'ج.م ${seed.totalValue.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  // Expiry date if applicable
                  if (seed.expiryDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Expires: ${DateFormat('dd/MM/yyyy').format(seed.expiryDate!)}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddSeedDialog(),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'إضافة بذور',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<SeedInventory> _getFilteredSeeds() {
    List<SeedInventory> seeds = _useDemoData ? _demoSeeds : [];
    
    if (_selectedCategory != 'all') {
      seeds = seeds.where((s) => s.category == _selectedCategory).toList();
    }
    
    return seeds;
  }

  void _showSeedDetails(SeedInventory seed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SeedDetailsSheet(seed: seed),
    );
  }

  void _showAddSeedDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddSeedSheet(),
    );
  }

  Future<void> _handleExport(String type) async {
    setState(() => _isExporting = true);
    
    try {
      final seeds = _getFilteredSeeds();
      
      if (type == 'pdf') {
        final file = await _reportService.exportSeedInventoryPdf(
          seeds: seeds,
          farmName: 'مزرعتي',
        );
        
        _showExportSuccess(file, 'PDF');
      } else if (type == 'excel') {
        final file = await _reportService.exportSeedInventoryExcel(
          seeds: seeds,
          farmName: 'مزرعتي',
        );
        
        _showExportSuccess(file, 'Excel');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showExportSuccess(dynamic file, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.check_circle, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            const Text('تم التصدير بنجاح'),
          ],
        ),
        content: Text('تم إنشاء تقرير $type بنجاح.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _reportService.shareFile(file);
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('مشاركة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== SEED DETAILS SHEET ==========

class _SeedDetailsSheet extends StatelessWidget {
  final SeedInventory seed;

  const _SeedDetailsSheet({required this.seed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Header
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          SeedCategories.getIcon(seed.category),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seed.nameArabic.isNotEmpty ? seed.nameArabic : seed.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${seed.variety} • ${seed.name}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Info grid
                _buildInfoGrid(),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('تعديل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text('استخدام'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.accent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildInfoTile('الكمية', '${seed.quantity} ${seed.unit}', Icons.inventory_2),
        _buildInfoTile('السعر/الوحدة', 'ج.م ${seed.pricePerUnit}', Icons.attach_money),
        _buildInfoTile('القيمة الإجمالية', 'ج.م ${seed.totalValue.toStringAsFixed(0)}', Icons.account_balance_wallet),
        _buildInfoTile('تاريخ الشراء', DateFormat('dd/MM/yyyy').format(seed.purchaseDate), Icons.calendar_today),
        if (seed.expiryDate != null)
          _buildInfoTile('تاريخ الانتهاء', DateFormat('dd/MM/yyyy').format(seed.expiryDate!), Icons.event),
        if (seed.supplier != null)
          _buildInfoTile('المورد', seed.supplier!, Icons.store),
        if (seed.storageLocation != null)
          _buildInfoTile('مكان التخزين', seed.storageLocation!, Icons.warehouse),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== ADD SEED SHEET ==========

class _AddSeedSheet extends StatefulWidget {
  const _AddSeedSheet();

  @override
  State<_AddSeedSheet> createState() => _AddSeedSheetState();
}

class _AddSeedSheetState extends State<_AddSeedSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameArabicController = TextEditingController();
  final _varietyController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _supplierController = TextEditingController();
  
  String _selectedCategory = 'vegetable';
  String _selectedUnit = 'kg';
  final DateTime _purchaseDate = DateTime.now();
  DateTime? _expiryDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'إضافة بذور جديدة',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Form fields
                  _buildTextField(_nameController, 'Seed Name', 'اسم البذور (إنجليزي)'),
                  _buildTextField(_nameArabicController, 'اسم البذور', 'اسم البذور (عربي)'),
                  _buildTextField(_varietyController, 'Variety', 'الصنف'),
                  
                  // Category dropdown
                  _buildDropdown(
                    'Category',
                    _selectedCategory,
                    SeedCategories.all.map((c) => c['id']!).toList(),
                    (value) => setState(() => _selectedCategory = value!),
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(_quantityController, 'Quantity', 'الكمية', isNumber: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          'Unit',
                          _selectedUnit,
                          SeedUnits.all.map((u) => u['id']!).toList(),
                          (value) => setState(() => _selectedUnit = value!),
                        ),
                      ),
                    ],
                  ),
                  
                  _buildTextField(_priceController, 'Price per unit', 'السعر/الوحدة', isNumber: true),
                  _buildTextField(_supplierController, 'Supplier', 'المورد'),
                  
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'إضافة البذور',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to Firebase
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تمت إضافة البذور بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
















