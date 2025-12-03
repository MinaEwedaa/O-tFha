import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/crop_service.dart';
import 'new_crop_screen.dart';
import 'crop_detail_screen.dart';
import 'cart_screen.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  final CropService _cropService = CropService();
  String selectedFarm = 'All Farms';
  String selectedFilter = 'all';
  String searchQuery = '';
  List<String> _farmNames = ['All Farms'];

  @override
  void initState() {
    super.initState();
    _loadFarmNames();
  }

  Future<void> _loadFarmNames() async {
    final names = await _cropService.getFarmNames();
    setState(() {
      _farmNames = ['All Farms', ...names];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _buildAppBar(context),
              
              // Farm Dropdown
              _buildFarmDropdown(),
              
              const SizedBox(height: 16),
              
              // Search Bar
              _buildSearchBar(),
              
              const SizedBox(height: 16),
              
              // Filter Chips
              _buildFilterChips(),
              
              const SizedBox(height: 16),
              
              // Crops Statistics
              _buildStatisticsRow(),
              
              const SizedBox(height: 16),
              
              // Crops List
              Expanded(
                child: _buildCropsList(),
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
              builder: (context) => const NewCropScreen(),
            ),
          ).then((_) => _loadFarmNames());
        },
        backgroundColor: Colors.teal.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: Colors.teal.shade600, size: 24),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ],
          ),
          
          // Right side icons
          Row(
            children: [
              Text(
                'العربية',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.teal.shade600,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
                child: Icon(Icons.shopping_cart_outlined, color: Colors.teal.shade600, size: 24),
              ),
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

  Widget _buildFarmDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFarm,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal.shade600),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
          items: _farmNames.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedFarm = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search crop or field',
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
          Icon(Icons.tune, color: Colors.teal.shade600, size: 24),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'id': 'all', 'label': 'All'},
      {'id': 'growing', 'label': 'Growing'},
      {'id': 'harvested', 'label': 'Harvested'},
      {'id': 'planned', 'label': 'Planned'},
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['id'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter['id']!;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal.shade600 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
                ),
              ),
              child: Text(
                filter['label']!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsRow() {
    return FutureBuilder<CropStatistics>(
      future: _cropService.getCropStatistics(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? CropStatistics.empty();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Crops',
                  '${stats.totalCrops}',
                  Icons.eco,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  '${stats.activeCrops}',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Area (Feddans)',
                  stats.totalAreaInFeddans.toStringAsFixed(1),
                  Icons.landscape,
                  Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCropsList() {
    // Determine status filter
    CropStatus? statusFilter;
    if (selectedFilter == 'growing') {
      statusFilter = CropStatus.growing;
    } else if (selectedFilter == 'harvested') {
      statusFilter = CropStatus.harvested;
    } else if (selectedFilter == 'planned') {
      statusFilter = CropStatus.planned;
    }

    return StreamBuilder<List<Crop>>(
      stream: _cropService.getCropsStream(
        farmName: selectedFarm == 'All Farms' ? null : selectedFarm,
        status: statusFilter,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error loading crops',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        var crops = snapshot.data ?? [];

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          crops = crops.where((crop) {
            final query = searchQuery.toLowerCase();
            return crop.name.toLowerCase().contains(query) ||
                   crop.farmName.toLowerCase().contains(query) ||
                   crop.fieldLocation.toLowerCase().contains(query) ||
                   crop.variety.toLowerCase().contains(query);
          }).toList();
        }

        // If empty, show demo data or empty state
        if (crops.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadFarmNames();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: crops.length,
            itemBuilder: (context, index) {
              return _buildCropCard(crops[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No crops found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first crop!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewCropScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Crop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(Crop crop) {
    final progress = crop.calculatedProgress;
    final daysUntilHarvest = crop.daysUntilHarvest;
    
    Color statusColor;
    Color statusBgColor;
    switch (crop.status) {
      case CropStatus.harvested:
        statusColor = Colors.blue.shade700;
        statusBgColor = Colors.blue.shade100;
        break;
      case CropStatus.growing:
      case CropStatus.flowering:
        statusColor = Colors.green.shade700;
        statusBgColor = Colors.green.shade100;
        break;
      case CropStatus.planned:
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.shade200;
        break;
      case CropStatus.failed:
        statusColor = Colors.red.shade700;
        statusBgColor = Colors.red.shade100;
        break;
      default:
        statusColor = Colors.orange.shade700;
        statusBgColor = Colors.orange.shade100;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropDetailScreen(crop: _cropToMap(crop)),
          ),
        );
      },
      child: Dismissible(
        key: Key(crop.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Crop'),
              content: Text('Are you sure you want to delete "${crop.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          await _cropService.deleteCrop(crop.id);
          HapticFeedback.mediumImpact();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: crop.status == CropStatus.harvested 
                  ? Colors.purple.shade300 
                  : Colors.grey.shade200,
              width: crop.status == CropStatus.harvested ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        CropCategories.getIcon(crop.category),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        CropCategories.getName(crop.category),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.teal.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      crop.statusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Plant Name
              Text(
                '${crop.name}${crop.variety.isNotEmpty ? ' - ${crop.variety}' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Field name
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${crop.farmName}${crop.fieldLocation.isNotEmpty ? ' - ${crop.fieldLocation}' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Dates
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Planted: ${DateFormat('MMM d').format(crop.plantedDate)} - Harvest: ${DateFormat('MMM d').format(crop.expectedHarvestDate)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress to Harvest',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        crop.status == CropStatus.harvested 
                            ? Colors.blue.shade400 
                            : crop.status == CropStatus.growing || crop.status == CropStatus.flowering
                                ? Colors.green.shade400
                                : Colors.orange.shade400,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Next Task or Days Until Harvest
              if (crop.status != CropStatus.harvested && crop.status != CropStatus.failed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (crop.currentTask != null)
                      Text(
                        'Next: ${crop.currentTask}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: daysUntilHarvest <= 7 
                            ? Colors.orange.shade100 
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        daysUntilHarvest > 0 
                            ? '$daysUntilHarvest days left'
                            : 'Ready to harvest!',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: daysUntilHarvest <= 7 
                              ? Colors.orange.shade700 
                              : Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              
              // Harvest info for harvested crops
              if (crop.status == CropStatus.harvested && crop.actualYield != null)
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Harvested: ${crop.actualYield!.toStringAsFixed(0)} kg',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _cropToMap(Crop crop) {
    return {
      'id': crop.id,
      'category': CropCategories.getName(crop.category),
      'name': '${crop.name}${crop.variety.isNotEmpty ? ' - ${crop.variety}' : ''}',
      'field': crop.farmName,
      'planted': DateFormat('MMM').format(crop.plantedDate),
      'harvest': DateFormat('MMM').format(crop.expectedHarvestDate),
      'progress': crop.calculatedProgress,
      'nextTask': crop.currentTask ?? 'No task scheduled',
      'status': crop.statusLabel,
      'statusColor': _getStatusBgColor(crop.status),
      'statusTextColor': _getStatusColor(crop.status),
    };
  }

  Color _getStatusBgColor(CropStatus status) {
    switch (status) {
      case CropStatus.harvested:
        return Colors.blue.shade100;
      case CropStatus.growing:
      case CropStatus.flowering:
        return Colors.green.shade100;
      case CropStatus.planned:
        return Colors.grey.shade200;
      case CropStatus.failed:
        return Colors.red.shade100;
      default:
        return Colors.orange.shade100;
    }
  }

  Color _getStatusColor(CropStatus status) {
    switch (status) {
      case CropStatus.harvested:
        return Colors.blue.shade700;
      case CropStatus.growing:
      case CropStatus.flowering:
        return Colors.green.shade700;
      case CropStatus.planned:
        return Colors.grey.shade700;
      case CropStatus.failed:
        return Colors.red.shade700;
      default:
        return Colors.orange.shade700;
    }
  }
}
