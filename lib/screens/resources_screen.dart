import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/language_service.dart';
import '../services/resource_service.dart';
import 'resource_detail_screen.dart';
import 'add_resource_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final ResourceService _resourceService = ResourceService();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                
                const SizedBox(height: 16),
                
                // Search Bar
                _buildSearchBar(languageService),
                
                const SizedBox(height: 16),
                
                // Category Tabs
                _buildCategoryTabs(languageService),
                
                const SizedBox(height: 16),
                
                // Resources List
                Expanded(
                  child: _buildResourcesList(languageService),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddResourceScreen(),
              ),
            );
          },
          backgroundColor: Colors.teal.shade600,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
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
          // O'tfha Logo
          Image.asset(
            'assets/images/logo.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          
          // Right side icons
          Row(
            children: [
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
              Icon(Icons.language, color: Colors.teal.shade600, size: 20),
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

  Widget _buildSearchBar(LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: languageService.isArabic ? 'بحث' : 'Search',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Icon(Icons.search, color: Colors.teal.shade600, size: 24),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey.shade300,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.tune, color: Colors.teal.shade600, size: 24),
            onPressed: () {
              // Show filter options
              _showFilterDialog(context, languageService);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(LanguageService languageService) {
    final categories = [
      'All',
      'Equipment',
      'Tools',
      'Machinery',
      'Irrigation',
      'Transport',
    ];
    
    return Container(
      height: 45,
      margin: EdgeInsets.only(
        left: languageService.isArabic ? 0 : 16,
        right: languageService.isArabic ? 16 : 0,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: languageService.isArabic ? 0 : 12,
                left: languageService.isArabic ? 12 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal.shade600 : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourcesList(LanguageService languageService) {
    return StreamBuilder<QuerySnapshot>(
      stream: selectedCategory == 'All'
          ? _resourceService.getUserResources()
          : _resourceService.getResourcesByCategory(selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.teal.shade600,
            ),
          );
        }

        if (snapshot.hasError) {
          print('Resources screen error: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageService.isArabic
                        ? 'حدث خطأ في تحميل الموارد'
                        : 'Error loading resources',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString().contains('index')
                        ? (languageService.isArabic
                            ? 'يرجى نشر فهارس Firestore'
                            : 'Please deploy Firestore indexes')
                        : (languageService.isArabic
                            ? 'تحقق من اتصالك بالإنترنت'
                            : 'Check your internet connection'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      languageService.isArabic ? 'إعادة المحاولة' : 'Retry',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.agriculture_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  languageService.isArabic
                      ? 'لا توجد موارد حتى الآن'
                      : 'No resources yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  languageService.isArabic
                      ? 'انقر فوق + لإضافة مورد جديد'
                      : 'Tap + to add a new resource',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        // Filter by search query
        List<DocumentSnapshot> filteredDocs = snapshot.data!.docs;
        
        // Sort by createdAt in memory (newest first)
        filteredDocs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;
          
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          
          return bTime.compareTo(aTime); // Descending order
        });
        
        if (_searchQuery.isNotEmpty) {
          filteredDocs = filteredDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  languageService.isArabic
                      ? 'لم يتم العثور على نتائج'
                      : 'No results found',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildResourceCard(doc.id, data, languageService);
          },
        );
      },
    );
  }

  Widget _buildResourceCard(String resourceId, Map<String, dynamic> data, LanguageService languageService) {
    final name = data['name'] ?? 'Unknown';
    final status = data['status'] ?? 'active';
    final imageUrl = data['imageUrl'] ?? '';
    
    // Format purchase date
    String purchaseDate = 'N/A';
    if (data['purchaseDate'] != null) {
      final timestamp = data['purchaseDate'] as Timestamp;
      purchaseDate = DateFormat('dd-MMM-yyyy').format(timestamp.toDate());
    }

    // Determine status color and text
    Color statusColor;
    String statusText;
    Color statusTextColor;
    
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green.shade100;
        statusText = languageService.isArabic ? 'نشط' : 'Active';
        statusTextColor = Colors.green.shade700;
        break;
      case 'maintenance':
        statusColor = Colors.blue.shade100;
        statusText = languageService.isArabic ? 'صيانة' : 'Maintenance';
        statusTextColor = Colors.blue.shade700;
        break;
      case 'inactive':
        statusColor = Colors.red.shade100;
        statusText = languageService.isArabic ? 'غير نشط' : 'Inactive';
        statusTextColor = Colors.red.shade700;
        break;
      default:
        statusColor = Colors.grey.shade100;
        statusText = status;
        statusTextColor = Colors.grey.shade700;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResourceDetailScreen(
              resource: {
                ...data,
                'id': resourceId,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Equipment Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: languageService.isArabic ? Radius.zero : const Radius.circular(14),
                bottomLeft: languageService.isArabic ? Radius.zero : const Radius.circular(14),
                topRight: languageService.isArabic ? const Radius.circular(14) : Radius.zero,
                bottomRight: languageService.isArabic ? const Radius.circular(14) : Radius.zero,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Show truck.png if network image fails to load
                          return Image.asset(
                            'assets/images/truck.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.agriculture,
                                size: 40,
                                color: Colors.grey.shade400,
                              );
                            },
                          );
                        },
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
                      )
                    : Image.asset(
                        'assets/images/truck.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.agriculture,
                            size: 40,
                            color: Colors.grey.shade400,
                          );
                        },
                      ),
              ),
            ),
            
            // Equipment Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: languageService.crossAxisAlignment,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${languageService.isArabic ? 'تم الشراء' : 'Purchased'}: $purchaseDate',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Status Badge
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageService.isArabic ? 'تصفية' : 'Filter',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageService.isArabic 
                  ? 'خيارات التصفية قيد التطوير' 
                  : 'Filter options coming soon',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
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
}

