import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/language_service.dart';
import '../services/resource_service.dart';

class ResourceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> resource;

  const ResourceDetailScreen({
    super.key,
    required this.resource,
  });

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  String selectedTab = 'Overview';
  final ResourceService _resourceService = ResourceService();

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Directionality(
      textDirection: languageService.textDirection,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(context, languageService),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        
                        // Equipment Details Title
                        _buildTitle(languageService),
                        
                        const SizedBox(height: 16),
                        
                        // Equipment Image
                        _buildEquipmentImage(),
                        
                        const SizedBox(height: 16),
                        
                        // Product Info
                        _buildProductInfo(languageService),
                        
                        const SizedBox(height: 16),
                        
                        // Action Buttons
                        _buildActionButtons(languageService),
                        
                        const SizedBox(height: 16),
                        
                        // Tab Navigation
                        _buildTabNavigation(languageService),
                        
                        const SizedBox(height: 16),
                        
                        // Tab Content
                        _buildTabContent(languageService),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // O'tfha Logo / Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              'assets/images/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          
          // Right side icons
          Row(
            children: [
              // Delete button
              IconButton(
                onPressed: () => _showDeleteConfirmation(context, languageService),
                icon: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 24),
                tooltip: languageService.isArabic ? 'حذف' : 'Delete',
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  languageService.toggleLanguage();
                },
                child: Text(
                  languageService.languageSwitch,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.teal.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.shopping_cart_outlined, color: Colors.teal.shade600, size: 24),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal.shade100,
                child: Icon(
                  Icons.person,
                  color: Colors.teal.shade700,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(LanguageService languageService) {
    return Text(
      languageService.isArabic ? 'تفاصيل المعدات' : 'Equipment Details',
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.teal.shade700,
      ),
    );
  }

  Widget _buildEquipmentImage() {
    final imageUrl = widget.resource['imageUrl'] ?? '';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade600, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.teal.shade600,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No image',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey.shade200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No image',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProductInfo(LanguageService languageService) {
    final name = widget.resource['name'] ?? 'Unknown Resource';
    final category = widget.resource['category'] ?? 'N/A';
    final status = widget.resource['status'] ?? 'active';
    
    // Format purchase date
    String purchaseDate = 'N/A';
    if (widget.resource['purchaseDate'] != null) {
      try {
        final timestamp = widget.resource['purchaseDate'] as Timestamp;
        purchaseDate = DateFormat('dd-MMM-yyyy').format(timestamp.toDate());
      } catch (e) {
        purchaseDate = widget.resource['purchaseDate'].toString();
      }
    }
    
    // Determine status text
    String statusText;
    switch (status.toLowerCase()) {
      case 'active':
        statusText = languageService.isArabic ? 'نشط' : 'Active';
        break;
      case 'maintenance':
        statusText = languageService.isArabic ? 'صيانة' : 'Maintenance';
        break;
      case 'inactive':
        statusText = languageService.isArabic ? 'غير نشط' : 'Inactive';
        break;
      default:
        statusText = status;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          // Name and Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusTextColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Category and Purchase Date
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${languageService.isArabic ? 'تم الشراء' : 'Purchased'}: $purchaseDate',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green.shade100;
      case 'maintenance':
        return Colors.blue.shade100;
      case 'inactive':
        return Colors.red.shade100;
      default:
        return Colors.green.shade100;
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green.shade700;
      case 'maintenance':
        return Colors.blue.shade700;
      case 'inactive':
        return Colors.red.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  Widget _buildActionButtons(LanguageService languageService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.update,
              label: languageService.isArabic ? 'تحديث' : 'Update',
              onTap: () {
                _showUpdateDialog(context, languageService);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit,
              label: languageService.isArabic ? 'تعديل' : 'Edit',
              onTap: () {
                _showEditDialog(context, languageService);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.add_circle_outline,
              label: languageService.isArabic ? 'إضافة صيانة' : 'Add Maintenance',
              onTap: () {
                _showMaintenanceDialog(context, languageService);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigation(LanguageService languageService) {
    final tabs = [
      languageService.isArabic ? 'نظرة عامة' : 'Overview',
      languageService.isArabic ? 'الصيانة' : 'Maintenance',
      languageService.isArabic ? 'الجدول' : 'Schedule',
      languageService.isArabic ? 'التاريخ' : 'History',
    ];

    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = selectedTab == tabs[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = tab;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: languageService.isArabic ? 0 : 8,
                left: languageService.isArabic ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isSelected ? Colors.teal.shade600 : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(LanguageService languageService) {
    if (selectedTab == 'Overview' || selectedTab == 'نظرة عامة') {
      return _buildOverviewTab(languageService);
    } else if (selectedTab == 'Maintenance' || selectedTab == 'الصيانة') {
      return _buildMaintenanceTab(languageService);
    }
    
    // Placeholder for other tabs
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          languageService.isArabic 
              ? 'المحتوى قيد التطوير' 
              : 'Content coming soon',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(LanguageService languageService) {
    return Column(
      children: [
        // Details Section
        _buildDetailsSection(languageService),
        
        const SizedBox(height: 16),
        
        // Quick Stats Section
        _buildQuickStatsSection(languageService),
        
        const SizedBox(height: 16),
        
        // Attachments Section
        _buildAttachmentsSection(languageService),
      ],
    );
  }

  Widget _buildDetailsSection(LanguageService languageService) {
    final description = widget.resource['description'] ?? '';
    final location = widget.resource['location'] ?? 'N/A';
    final price = widget.resource['purchasePrice'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          Text(
            languageService.isArabic ? 'التفاصيل' : 'Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 12),
          if (description.isNotEmpty) ...[
            _buildDetailRow(
              languageService.isArabic ? 'الوصف:' : 'Description:',
              description,
              languageService,
            ),
            const SizedBox(height: 8),
          ],
          _buildDetailRow(
            languageService.isArabic ? 'الموقع:' : 'Location:',
            location,
            languageService,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            languageService.isArabic ? 'سعر الشراء:' : 'Purchase Price:',
            price > 0 ? '\$${price.toStringAsFixed(2)}' : 'N/A',
            languageService,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, LanguageService languageService) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: languageService.isArabic ? TextAlign.right : TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection(LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          Text(
            languageService.isArabic ? 'إحصائيات سريعة' : 'Quick Stats',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            languageService.isArabic ? 'إجمالي الصيانة:' : 'Total Maintenance:',
            'XX',
            languageService,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            languageService.isArabic ? 'آخر صيانة:' : 'Last Maintenance:',
            'DD-MM-YYYY',
            languageService,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            languageService.isArabic ? 'الصيانة التالية:' : 'Next Maintenance:',
            'DD-MM-YYYY',
            languageService,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          Text(
            languageService.isArabic ? 'المرفقات' : 'Attachments',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAttachmentPlaceholder(),
              const SizedBox(width: 12),
              _buildAttachmentPlaceholder(),
              const SizedBox(width: 12),
              _buildAttachmentPlaceholder(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPlaceholder() {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab(LanguageService languageService) {
    // Sample maintenance records
    final maintenanceRecords = [
      {
        'title': languageService.isArabic ? 'عنوان الصيانة' : 'Maintenance title',
        'status': 'completed',
        'statusText': languageService.isArabic ? 'مكتمل' : 'Completed',
        'statusColor': Colors.green.shade100,
        'statusTextColor': Colors.green.shade700,
        'description': 'Maintenance description and procedures. Lorem ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
      },
      {
        'title': languageService.isArabic ? 'عنوان الصيانة' : 'Maintenance title',
        'status': 'important',
        'statusText': languageService.isArabic ? 'مهم' : 'Important',
        'statusColor': Colors.orange.shade100,
        'statusTextColor': Colors.orange.shade700,
        'description': 'Maintenance description and procedures. Lorem ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
      },
      {
        'title': languageService.isArabic ? 'عنوان الصيانة' : 'Maintenance title',
        'status': 'cancelled',
        'statusText': languageService.isArabic ? 'ملغي' : 'Cancelled',
        'statusColor': Colors.red.shade100,
        'statusTextColor': Colors.red.shade700,
        'description': 'Maintenance description and procedures. Lorem ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
      },
      {
        'title': languageService.isArabic ? 'عنوان الصيانة' : 'Maintenance title',
        'status': 'completed',
        'statusText': languageService.isArabic ? 'مكتمل' : 'Completed',
        'statusColor': Colors.green.shade100,
        'statusTextColor': Colors.green.shade700,
        'description': 'Maintenance description and procedures. Lorem ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
      },
    ];

    return Column(
      children: maintenanceRecords.map((record) {
        return _buildMaintenanceCard(record, languageService);
      }).toList(),
    );
  }

  Widget _buildMaintenanceCard(Map<String, dynamic> record, LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: languageService.crossAxisAlignment,
        children: [
          // Header with title and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  record['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: record['statusColor'],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record['statusText'],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: record['statusTextColor'],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            record['description'],
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: languageService.textAlign,
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageService.isArabic ? 'تحديث المعدات' : 'Update Equipment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          languageService.isArabic 
              ? 'ستتمكن قريبًا من تحديث معلومات المعدات' 
              : 'You will soon be able to update equipment information',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageService.isArabic ? 'إغلاق' : 'Close',
              style: GoogleFonts.poppins(color: Colors.teal.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageService.isArabic ? 'تعديل المعدات' : 'Edit Equipment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          languageService.isArabic 
              ? 'ستتمكن قريبًا من تعديل معلومات المعدات' 
              : 'You will soon be able to edit equipment information',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageService.isArabic ? 'إغلاق' : 'Close',
              style: GoogleFonts.poppins(color: Colors.teal.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageService.isArabic ? 'إضافة صيانة' : 'Add Maintenance',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          languageService.isArabic 
              ? 'ستتمكن قريبًا من إضافة سجلات الصيانة' 
              : 'You will soon be able to add maintenance records',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageService.isArabic ? 'إغلاق' : 'Close',
              style: GoogleFonts.poppins(color: Colors.teal.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          languageService.isArabic ? 'تأكيد الحذف' : 'Confirm Delete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          languageService.isArabic
              ? 'هل أنت متأكد من حذف هذا المورد؟ لا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to delete this resource? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              languageService.isArabic ? 'إلغاء' : 'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    color: Colors.teal.shade600,
                  ),
                ),
              );

              try {
                final resourceId = widget.resource['id'];
                await _resourceService.deleteResource(resourceId);

                // Close loading
                if (mounted) Navigator.pop(context);

                // Close detail screen
                if (mounted) Navigator.pop(context);

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        languageService.isArabic
                            ? 'تم حذف المورد بنجاح'
                            : 'Resource deleted successfully',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Close loading
                if (mounted) Navigator.pop(context);

                // Show error
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        languageService.isArabic
                            ? 'حدث خطأ أثناء الحذف'
                            : 'Error deleting resource: $e',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(
              languageService.isArabic ? 'حذف' : 'Delete',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}

