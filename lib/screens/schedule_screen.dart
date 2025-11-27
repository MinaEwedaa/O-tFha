import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'new_schedule_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  final List<String> timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '01:00',
    '02:00',
    '03:00',
    '04:00',
    '05:00',
    '06:00',
    '07:00',
    '08:00',
    '09:00',
  ];

  // Get dates for the week
  List<DateTime> getWeekDates() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: currentWeekday % 7));
    
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Week Days
            _buildWeekDays(),
            
            // Date Header
            _buildDateHeader(),
            
            // Time Slots
            Expanded(
              child: _buildTimeSlots(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewScheduleScreen(),
            ),
          );
        },
        backgroundColor: Colors.teal.shade400,
        child: const Icon(Icons.add, color: Colors.white),
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
              Icon(Icons.settings_outlined, color: Colors.teal.shade600, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    List<DateTime> weekDates = getWeekDates();
    List<String> dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          DateTime date = weekDates[index];
          bool isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Container(
              width: 45,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal.shade400 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNames[index],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateHeader() {
    String formattedDate = DateFormat('d MMMM EEEE').format(selectedDate).toLowerCase();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Text(
        formattedDate,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Container(
      color: Colors.grey.shade50,
      child: ListView.builder(
        itemCount: timeSlots.length,
        itemBuilder: (context, index) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // Time label
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    timeSlots[index],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Schedule area (empty for now, can be filled with events)
                Expanded(
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

