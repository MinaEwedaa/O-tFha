import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../services/language_service.dart';
import '../services/resource_service.dart';

class AddResourceScreen extends StatefulWidget {
  const AddResourceScreen({super.key});

  @override
  State<AddResourceScreen> createState() => _AddResourceScreenState();
}

class _AddResourceScreenState extends State<AddResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Equipment';
  String _selectedStatus = 'active';
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final ResourceService _resourceService = ResourceService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error selecting image',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveResource(LanguageService languageService) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageService.isArabic
                ? 'الرجاء إدخال اسم المورد'
                : 'Please enter resource name',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _resourceService.addResource(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        status: _selectedStatus,
        purchaseDate: _selectedDate,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        purchasePrice: _priceController.text.trim().isNotEmpty
            ? double.tryParse(_priceController.text.trim()) ?? 0.0
            : 0.0,
        imageFile: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageService.isArabic
                  ? 'تمت إضافة المورد بنجاح'
                  : 'Resource added successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageService.isArabic
                  ? 'حدث خطأ أثناء إضافة المورد'
                  : 'Error adding resource: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Directionality(
      textDirection: languageService.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            languageService.isArabic ? 'إضافة مورد جديد' : 'Add New Resource',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              languageService.isArabic ? Icons.arrow_forward : Icons.arrow_back,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image picker section
                    _buildImagePicker(languageService),
                    const SizedBox(height: 16),
                    
                    // Name field
                    _buildTextField(
                      controller: _nameController,
                      label: languageService.isArabic ? 'الاسم *' : 'Name *',
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Category dropdown
                    _buildDropdown(
                      label: languageService.isArabic ? 'الفئة *' : 'Category *',
                      value: _selectedCategory,
                      items: ['Equipment', 'Tools', 'Machinery', 'Irrigation', 'Transport'],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Status dropdown
                    _buildDropdown(
                      label: languageService.isArabic ? 'الحالة *' : 'Status *',
                      value: _selectedStatus,
                      items: ['active', 'maintenance', 'inactive'],
                      itemLabels: {
                        'active': languageService.isArabic ? 'نشط' : 'Active',
                        'maintenance': languageService.isArabic ? 'صيانة' : 'Maintenance',
                        'inactive': languageService.isArabic ? 'غير نشط' : 'Inactive',
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Purchase date
                    _buildDatePicker(languageService),
                    const SizedBox(height: 16),
                    
                    // Description field
                    _buildTextField(
                      controller: _descriptionController,
                      label: languageService.isArabic ? 'الوصف' : 'Description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Location field
                    _buildTextField(
                      controller: _locationController,
                      label: languageService.isArabic ? 'الموقع' : 'Location',
                    ),
                    const SizedBox(height: 16),
                    
                    // Price field
                    _buildTextField(
                      controller: _priceController,
                      label: languageService.isArabic ? 'سعر الشراء' : 'Purchase Price',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _saveResource(languageService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              languageService.isArabic ? 'حفظ المورد' : 'Save Resource',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(LanguageService languageService) {
    return Container(
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
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                _selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ListTile(
            leading: Icon(Icons.image, color: Colors.teal.shade600),
            title: Text(
              _selectedImage == null
                  ? (languageService.isArabic ? 'إضافة صورة' : 'Add Image')
                  : (languageService.isArabic ? 'تغيير الصورة' : 'Change Image'),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            trailing: Icon(Icons.add_photo_alternate, color: Colors.grey.shade600),
            onTap: _pickImage,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
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
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(itemLabels?[item] ?? item),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(LanguageService languageService) {
    return Container(
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
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.teal.shade600,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && picked != _selectedDate) {
            setState(() {
              _selectedDate = picked;
            });
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: languageService.isArabic ? 'تاريخ الشراء *' : 'Purchase Date *',
            labelStyle: GoogleFonts.poppins(fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd-MMM-yyyy').format(_selectedDate),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}

