import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_crop_screen.dart';
import 'crop_detail_screen.dart';
import 'cart_screen.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  String selectedFarm = 'Farm name';
  String selectedFilter = 'Field';

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
          );
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
          items: ['Farm name', 'Farm 1', 'Farm 2', 'Farm 3']
              .map((String value) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('Field'),
          const SizedBox(width: 8),
          _buildFilterChip('Category'),
          const SizedBox(width: 8),
          _buildFilterChip('Status'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCropsList() {
    // Sample crop data
    final crops = [
      {
        'category': 'category name',
        'name': 'Plant Name - Subname',
        'field': 'field name',
        'planted': 'XX Month',
        'harvest': 'XX Month',
        'progress': 0.65,
        'nextTask': 'Task name - date',
        'status': 'status',
        'statusColor': Colors.orange.shade100,
        'statusTextColor': Colors.orange.shade700,
      },
      {
        'category': 'category name',
        'name': 'Plant Name - Subname',
        'field': 'field name',
        'planted': 'XX Month',
        'harvest': 'XX Month',
        'progress': 0.65,
        'nextTask': 'Task name - date',
        'status': 'Harvested',
        'statusColor': Colors.blue.shade100,
        'statusTextColor': Colors.blue.shade700,
      },
      {
        'category': 'category name',
        'name': 'Plant Name - Subname',
        'field': 'field name',
        'planted': 'XX Month',
        'harvest': 'XX Month',
        'progress': 0.65,
        'nextTask': 'Task name - date',
        'status': 'Ongoing',
        'statusColor': Colors.green.shade100,
        'statusTextColor': Colors.green.shade700,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: crops.length,
      itemBuilder: (context, index) {
        return _buildCropCard(crops[index]);
      },
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropDetailScreen(crop: crop),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: crop['status'] == 'Harvested' 
                ? Colors.purple.shade300 
                : Colors.grey.shade200,
            width: crop['status'] == 'Harvested' ? 2 : 1,
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
              Text(
                crop['category'],
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.teal.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: crop['statusColor'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  crop['status'],
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: crop['statusTextColor'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Plant Name
          Text(
            crop['name'],
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
                crop['field'],
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
                'Planted: ${crop['planted']} - Harvest: ${crop['harvest']}',
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
                    '${(crop['progress'] * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: crop['progress'],
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    crop['status'] == 'Harvested' 
                        ? Colors.blue.shade400 
                        : crop['status'] == 'Ongoing'
                            ? Colors.green.shade400
                            : Colors.orange.shade400,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Next Task
          Text(
            'Next: ${crop['nextTask']}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.teal.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

