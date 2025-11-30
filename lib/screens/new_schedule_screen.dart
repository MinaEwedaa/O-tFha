import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/schedule_service.dart';

class NewScheduleScreen extends StatefulWidget {
  const NewScheduleScreen({super.key});

  @override
  State<NewScheduleScreen> createState() => _NewScheduleScreenState();
}

class _NewScheduleScreenState extends State<NewScheduleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScheduleService _scheduleService = ScheduleService();
  bool _isSaving = false;
  
  String? selectedFarm;
  DateTime? startDateTime;
  DateTime? endDateTime;
  
  // Sample farm list - you can replace with actual data from your backend
  final List<String> farms = [
    'North Field Farm',
    'South Valley Farm',
    'Green Acres Farm',
    'Wheat Field Farm',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        _buildLabel('Title'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleController,
                          hintText: '',
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Farm dropdown
                        _buildLabel('Farm'),
                        const SizedBox(height: 8),
                        _buildFarmDropdown(),
                        
                        const SizedBox(height: 20),
                        
                        // Description field
                        _buildLabel('Description'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descriptionController,
                          hintText: '',
                          maxLines: 5,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Start date/time
                        _buildLabel('Start'),
                        const SizedBox(height: 8),
                        _buildDateTimePicker(
                          value: startDateTime,
                          onTap: () => _selectDateTime(true),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // End date/time
                        _buildLabel('End'),
                        const SizedBox(height: 8),
                        _buildDateTimePicker(
                          value: endDateTime,
                          onTap: () => _selectDateTime(false),
                        ),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSaving ? null : _saveSchedule,
        backgroundColor: _isSaving ? Colors.grey : Colors.teal.shade400,
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button and Logo
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ],
          ),
          
          // Title
          Text(
            'New Schedule',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
              Icon(Icons.notifications_outlined, color: Colors.teal.shade600, size: 24),
              const SizedBox(width: 8),
              Icon(Icons.settings_outlined, color: Colors.teal.shade600, size: 24),
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
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.teal.shade700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFarmDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedFarm,
        hint: Text(
          'farm name',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
        ),
        icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        items: farms.map((String farm) {
          return DropdownMenuItem<String>(
            value: farm,
            child: Text(farm),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedFarm = newValue;
          });
        },
      ),
    );
  }

  Widget _buildDateTimePicker({
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.shade400, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null
                  ? DateFormat('MMM dd, yyyy - hh:mm a').format(value)
                  : 'Select date and time',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: value != null ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.teal.shade600,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(bool isStart) async {
    // Select date first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal.shade400,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      // Select time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.teal.shade400,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) {
            startDateTime = selectedDateTime;
          } else {
            endDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveSchedule() async {
    // Validate inputs
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter a title');
      return;
    }

    if (selectedFarm == null) {
      _showErrorSnackbar('Please select a farm');
      return;
    }

    if (startDateTime == null) {
      _showErrorSnackbar('Please select a start date and time');
      return;
    }

    if (endDateTime == null) {
      _showErrorSnackbar('Please select an end date and time');
      return;
    }

    if (endDateTime!.isBefore(startDateTime!)) {
      _showErrorSnackbar('End time must be after start time');
      return;
    }

    // Save schedule to database
    setState(() {
      _isSaving = true;
    });

    try {
      final taskId = await _scheduleService.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        farmName: selectedFarm!,
        startDateTime: startDateTime!,
        endDateTime: endDateTime!,
      );

      if (mounted) {
        if (taskId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Schedule created successfully',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.teal.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else {
          _showErrorSnackbar('Failed to create schedule');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

