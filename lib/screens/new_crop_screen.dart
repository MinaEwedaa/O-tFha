import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/crop_service.dart';
import 'cart_screen.dart';

class NewCropScreen extends StatefulWidget {
  const NewCropScreen({super.key});

  @override
  State<NewCropScreen> createState() => _NewCropScreenState();
}

class _NewCropScreenState extends State<NewCropScreen> {
  final CropService _cropService = CropService();
  final _formKey = GlobalKey<FormState>();
  
  final _cropNameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _farmController = TextEditingController();
  final _fieldController = TextEditingController();
  final _yieldEstimateController = TextEditingController();
  final _areaController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCategory = 'vegetable';
  DateTime? _plantedDate;
  DateTime? _expectedHarvestDate;
  bool _isAdvancedExpanded = false;
  bool _isSaving = false;
  File? _selectedImage;
  List<String> _farmNames = [];

  @override
  void initState() {
    super.initState();
    _loadFarmNames();
  }

  Future<void> _loadFarmNames() async {
    final names = await _cropService.getFarmNames();
    setState(() {
      _farmNames = names;
    });
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _varietyController.dispose();
    _farmController.dispose();
    _fieldController.dispose();
    _yieldEstimateController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPlantedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPlantedDate 
          ? (_plantedDate ?? DateTime.now())
          : (_expectedHarvestDate ?? DateTime.now().add(const Duration(days: 90))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isPlantedDate) {
          _plantedDate = picked;
        } else {
          _expectedHarvestDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveCrop() async {
    if (_cropNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter crop name')),
      );
      return;
    }

    if (_farmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter farm name')),
      );
      return;
    }

    if (_plantedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select planted date')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final crop = Crop(
        id: '',
        userId: '',
        name: _cropNameController.text.trim(),
        variety: _varietyController.text.trim(),
        category: _selectedCategory,
        farmName: _farmController.text.trim(),
        fieldLocation: _fieldController.text.trim(),
        plantedDate: _plantedDate!,
        expectedHarvestDate: _expectedHarvestDate ?? _plantedDate!.add(const Duration(days: 90)),
        areaInFeddans: double.tryParse(_areaController.text) ?? 1.0,
        expectedYield: double.tryParse(_yieldEstimateController.text),
        notes: _notesController.text.trim(),
        status: CropStatus.planted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _cropService.addCrop(crop, imageFile: _selectedImage);

      HapticFeedback.mediumImpact();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Crop "${crop.name}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
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
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Center(
                          child: Text(
                            'New Crop',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Crop Name
                        _buildLabel('Crop name *'),
                        const SizedBox(height: 8),
                        _buildTextField(_cropNameController, 'e.g., Tomatoes'),
                        
                        const SizedBox(height: 16),
                        
                        // Variety
                        _buildLabel('Variety'),
                        const SizedBox(height: 8),
                        _buildTextField(_varietyController, 'e.g., Roma, Cherry'),
                        
                        const SizedBox(height: 16),
                        
                        // Category
                        _buildLabel('Category'),
                        const SizedBox(height: 8),
                        _buildCategoryDropdown(),
                        
                        const SizedBox(height: 16),
                        
                        // Farm and Field
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Farm *'),
                                  const SizedBox(height: 8),
                                  _buildFarmField(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Field'),
                                  const SizedBox(height: 8),
                                  _buildTextField(_fieldController, 'e.g., Field A'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Planting Date and Expected Harvest
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Planted Date *'),
                                  const SizedBox(height: 8),
                                  _buildDatePickerButton(_plantedDate, true),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Expected Harvest'),
                                  const SizedBox(height: 8),
                                  _buildDatePickerButton(_expectedHarvestDate, false),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Area and Yield Estimate
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Area (Feddans)'),
                                  const SizedBox(height: 8),
                                  _buildTextField(_areaController, '1.0', keyboardType: TextInputType.number),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Expected Yield (Kg)'),
                                  const SizedBox(height: 8),
                                  _buildTextField(_yieldEstimateController, 'Yield Estimate', keyboardType: TextInputType.number),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Advanced Details
                        _buildAdvancedDetails(),
                        
                        if (_isAdvancedExpanded) ...[
                          const SizedBox(height: 16),
                          // Notes
                          _buildLabel('Notes'),
                          const SizedBox(height: 8),
                          _buildNotesField(),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Attach Plant Photo
                        _buildAttachPhotoSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Cancel and Save Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildCancelButton(context),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: _buildSaveButton(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.teal.shade700,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal.shade600),
          items: CropCategories.all.map((cat) {
            return DropdownMenuItem<String>(
              value: cat['id'],
              child: Row(
                children: [
                  Text(cat['icon']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(cat['name']!, style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFarmField() {
    if (_farmNames.isEmpty) {
      return _buildTextField(_farmController, 'Farm name');
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _farmNames.contains(_farmController.text) ? _farmController.text : null,
          hint: Text('Select or type farm', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal.shade600),
          items: [
            ..._farmNames.map((name) => DropdownMenuItem<String>(
              value: name,
              child: Text(name, style: GoogleFonts.poppins(fontSize: 14)),
            )),
            DropdownMenuItem<String>(
              value: '__new__',
              child: Row(
                children: [
                  Icon(Icons.add, size: 16, color: Colors.teal.shade600),
                  const SizedBox(width: 8),
                  Text('Add new farm', style: GoogleFonts.poppins(fontSize: 14, color: Colors.teal.shade600)),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value == '__new__') {
              _showAddFarmDialog();
            } else if (value != null) {
              setState(() => _farmController.text = value);
            }
          },
        ),
      ),
    );
  }

  void _showAddFarmDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Farm', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Farm Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final farm = Farm(
                  id: '',
                  userId: '',
                  name: nameController.text.trim(),
                  location: '',
                  createdAt: DateTime.now(),
                );
                await _cropService.addFarm(farm);
                await _loadFarmNames();
                setState(() => _farmController.text = nameController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade600),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton(DateTime? date, bool isPlantedDate) {
    return GestureDetector(
      onTap: () => _selectDate(context, isPlantedDate),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: date != null ? Colors.teal.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: date != null ? Colors.teal.shade600 : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            date != null 
                ? DateFormat('MMM dd, yyyy').format(date)
                : 'Pick a date',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: date != null ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedDetails() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAdvancedExpanded = !_isAdvancedExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.teal.shade600,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Advanced Details',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isAdvancedExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Add any notes about this crop...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildAttachPhotoSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: _selectedImage != null ? Colors.grey.shade200 : Colors.teal.shade600,
          borderRadius: BorderRadius.circular(16),
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to change photo',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.attach_file,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Attach Plant photo',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '( .png   .jpeg   .jpg)',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _saveCrop,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _isSaving ? Colors.grey : Colors.teal.shade600,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
