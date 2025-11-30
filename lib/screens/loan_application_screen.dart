import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  int currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  // Land Information
  final TextEditingController landAreaController = TextEditingController();
  final TextEditingController landLocationController = TextEditingController();
  final TextEditingController landValueController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  
  // Loan Details
  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController monthlyIncomeController = TextEditingController();
  final TextEditingController existingLoansController = TextEditingController();
  final TextEditingController businessPlanController = TextEditingController();
  
  String selectedLoanPurpose = 'Seeds & Fertilizers';
  String selectedRepaymentPeriod = '12 months';
  String selectedLandType = 'Agricultural Land';
  String selectedCropType = 'Vegetables';
  
  // Document uploads
  File? landPaperDocument;
  File? nationalIdDocument;
  File? proofOfIncomeDocument;
  File? landPhotos;
  
  final List<String> loanPurposes = [
    'Seeds & Fertilizers',
    'Equipment Purchase',
    'Land Expansion',
    'Infrastructure Development',
    'Irrigation System',
    'Livestock Purchase',
    'Working Capital',
    'Other',
  ];

  final List<String> repaymentPeriods = [
    '6 months',
    '12 months',
    '18 months',
    '24 months',
    '36 months',
    '48 months',
    '60 months',
  ];

  final List<String> landTypes = [
    'Agricultural Land',
    'Orchard',
    'Greenhouse',
    'Livestock Farm',
    'Mixed Farm',
    'Other',
  ];

  final List<String> cropTypes = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Cotton',
    'Sugar Crops',
    'Herbs & Spices',
    'Mixed Crops',
  ];

  @override
  void dispose() {
    fullNameController.dispose();
    nationalIdController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    landAreaController.dispose();
    landLocationController.dispose();
    landValueController.dispose();
    registrationNumberController.dispose();
    loanAmountController.dispose();
    monthlyIncomeController.dispose();
    existingLoansController.dispose();
    businessPlanController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          switch (documentType) {
            case 'landPaper':
              landPaperDocument = File(image.path);
              break;
            case 'nationalId':
              nationalIdDocument = File(image.path);
              break;
            case 'income':
              proofOfIncomeDocument = File(image.path);
              break;
            case 'landPhotos':
              landPhotos = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking document: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
      ),
    );
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
              
              // Progress Indicator
              _buildProgressIndicator(),
              
              // Form Content
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.teal.shade600,
                    ),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    currentStep: currentStep,
                    onStepContinue: () {
                      if (currentStep < 3) {
                        setState(() {
                          currentStep += 1;
                        });
                      } else {
                        _submitLoanApplication();
                      }
                    },
                    onStepCancel: () {
                      if (currentStep > 0) {
                        setState(() {
                          currentStep -= 1;
                        });
                      }
                    },
                    controlsBuilder: (context, details) {
                      return Container(
                        margin: const EdgeInsets.only(top: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: details.onStepContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  currentStep == 3 ? 'Submit Application' : 'Continue',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            if (currentStep > 0) ...[
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.teal.shade600,
                                  side: BorderSide(color: Colors.teal.shade600),
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Back',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    steps: [
                      Step(
                        title: Text(
                          'Info',
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        isActive: currentStep >= 0,
                        state: currentStep > 0 ? StepState.complete : StepState.indexed,
                        content: _buildPersonalInfoStep(),
                      ),
                      Step(
                        title: Text(
                          'Land',
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        isActive: currentStep >= 1,
                        state: currentStep > 1 ? StepState.complete : StepState.indexed,
                        content: _buildLandInfoStep(),
                      ),
                      Step(
                        title: Text(
                          'Loan',
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        isActive: currentStep >= 2,
                        state: currentStep > 2 ? StepState.complete : StepState.indexed,
                        content: _buildLoanDetailsStep(),
                      ),
                      Step(
                        title: Text(
                          'Docs',
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        isActive: currentStep >= 3,
                        state: currentStep > 3 ? StepState.complete : StepState.indexed,
                        content: _buildDocumentsStep(),
                      ),
                    ],
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
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.teal.shade600, size: 24),
          ),
          const SizedBox(width: 16),
          Image.asset(
            'assets/images/logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan Application',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade700,
                  ),
                ),
                Text(
                  'Bank of Agriculture',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.account_balance, color: Colors.teal.shade600, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of 4',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '${((currentStep + 1) / 4 * 100).toStringAsFixed(0)}% Complete',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / 4,
              backgroundColor: Colors.grey.shade200,
              color: Colors.teal.shade600,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Information', Icons.person),
            const SizedBox(height: 20),
            
            _buildTextField(
              controller: fullNameController,
              label: 'Full Name',
              hint: 'Enter your full legal name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: nationalIdController,
              label: 'National ID Number',
              hint: 'Enter your 14-digit ID number',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your National ID';
                }
                if (value.length != 14) {
                  return 'ID must be 14 digits';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: phoneController,
              label: 'Phone Number',
              hint: 'Enter your mobile number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'your.email@example.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: addressController,
              label: 'Home Address',
              hint: 'Enter your complete address',
              icon: Icons.home,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandInfoStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Land Information', Icons.landscape),
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: landAreaController,
            label: 'Land Area (in Feddan)',
            hint: 'e.g., 5.5',
            icon: Icons.straighten,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter land area';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdown(
            label: 'Land Type',
            value: selectedLandType,
            items: landTypes,
            icon: Icons.terrain,
            onChanged: (value) {
              setState(() {
                selectedLandType = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdown(
            label: 'Main Crop Type',
            value: selectedCropType,
            items: cropTypes,
            icon: Icons.agriculture,
            onChanged: (value) {
              setState(() {
                selectedCropType = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: landLocationController,
            label: 'Land Location',
            hint: 'Village, District, Governorate',
            icon: Icons.location_on,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter land location';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: registrationNumberController,
            label: 'Land Registration Number',
            hint: 'Official registration/deed number',
            icon: Icons.numbers,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter registration number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: landValueController,
            label: 'Estimated Land Value (EGX)',
            hint: 'Current market value',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter estimated land value';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildInfoCard(
            'Land Ownership Requirement',
            'Your land will serve as collateral for the loan. Ensure all ownership documents are valid and up-to-date.',
            Icons.info_outline,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Loan Requirements', Icons.payment),
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: loanAmountController,
            label: 'Requested Loan Amount (EGX)',
            hint: 'Enter amount you need',
            icon: Icons.money,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter loan amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount < 5000) {
                return 'Minimum loan amount is 5,000 EGX';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdown(
            label: 'Loan Purpose',
            value: selectedLoanPurpose,
            items: loanPurposes,
            icon: Icons.category,
            onChanged: (value) {
              setState(() {
                selectedLoanPurpose = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdown(
            label: 'Preferred Repayment Period',
            value: selectedRepaymentPeriod,
            items: repaymentPeriods,
            icon: Icons.schedule,
            onChanged: (value) {
              setState(() {
                selectedRepaymentPeriod = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: monthlyIncomeController,
            label: 'Average Monthly Income (EGX)',
            hint: 'From farming activities',
            icon: Icons.trending_up,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your monthly income';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: existingLoansController,
            label: 'Existing Loan Obligations (EGX)',
            hint: 'Total monthly loan payments (0 if none)',
            icon: Icons.account_balance_wallet,
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: businessPlanController,
            label: 'Business Plan / Purpose Details',
            hint: 'Explain how you will use the loan and your repayment strategy',
            icon: Icons.description,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please provide details about loan usage';
              }
              if (value.length < 50) {
                return 'Please provide more details (minimum 50 characters)';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildLoanCalculator(),
        ],
      ),
    );
  }

  Widget _buildLoanCalculator() {
    final loanAmount = double.tryParse(loanAmountController.text) ?? 0;
    final months = int.tryParse(selectedRepaymentPeriod.split(' ').first) ?? 12;
    final interestRate = 0.065; // 6.5% annual rate
    final monthlyRate = interestRate / 12;
    final monthlyPayment = loanAmount > 0 
        ? (loanAmount * monthlyRate * pow(1 + monthlyRate, months)) / (pow(1 + monthlyRate, months) - 1)
        : 0;
    final totalPayment = monthlyPayment * months;
    final totalInterest = totalPayment - loanAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.teal.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Loan Calculation Estimate',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCalculationRow('Monthly Payment:', 'EGX ${monthlyPayment.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _buildCalculationRow('Total Interest:', 'EGX ${totalInterest.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _buildCalculationRow('Total Repayment:', 'EGX ${totalPayment.toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 8),
          Text(
            '* Interest rate: 6.5% annually',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 13 : 12,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Colors.teal.shade700 : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: isTotal ? Colors.teal.shade700 : Colors.black87,
          ),
        ),
      ],
    );
  }

  double pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  Widget _buildDocumentsStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Required Documents', Icons.upload_file),
          const SizedBox(height: 12),
          
          Text(
            'Please upload clear, readable copies of all required documents',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildDocumentUpload(
            title: 'Land Ownership Papers',
            description: 'Official land deed or registration certificate',
            icon: Icons.landscape,
            file: landPaperDocument,
            onTap: () => _pickDocument('landPaper'),
            isRequired: true,
          ),
          
          const SizedBox(height: 16),
          
          _buildDocumentUpload(
            title: 'National ID Card',
            description: 'Both front and back sides',
            icon: Icons.credit_card,
            file: nationalIdDocument,
            onTap: () => _pickDocument('nationalId'),
            isRequired: true,
          ),
          
          const SizedBox(height: 16),
          
          _buildDocumentUpload(
            title: 'Proof of Income',
            description: 'Bank statements or sales receipts (last 3 months)',
            icon: Icons.receipt_long,
            file: proofOfIncomeDocument,
            onTap: () => _pickDocument('income'),
            isRequired: true,
          ),
          
          const SizedBox(height: 16),
          
          _buildDocumentUpload(
            title: 'Land Photos',
            description: 'Recent photos of your agricultural land',
            icon: Icons.photo_camera,
            file: landPhotos,
            onTap: () => _pickDocument('landPhotos'),
            isRequired: false,
          ),
          
          const SizedBox(height: 20),
          
          _buildInfoCard(
            'Document Guidelines',
            '• All documents must be clear and legible\n• File size: Max 5MB per document\n• Formats: JPG, PNG, PDF\n• Documents will be verified by bank officials',
            Icons.info_outline,
            Colors.orange,
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your information is secure and encrypted. We comply with banking data protection standards.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.teal.shade600, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: Colors.teal.shade600, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: GoogleFonts.poppins(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.teal.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String description,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
    required bool isRequired,
  }) {
    final isUploaded = file != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? Colors.green.shade300 : Colors.grey.shade300,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : icon,
                color: isUploaded ? Colors.green.shade600 : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Required',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? 'Document uploaded successfully' : description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isUploaded ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isUploaded ? Icons.edit : Icons.upload_file,
              color: isUploaded ? Colors.green.shade600 : Colors.teal.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: color.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitLoanApplication() {
    // Validate all required fields
    if (!_validateApplication()) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.teal.shade600),
              const SizedBox(height: 16),
              Text(
                'Submitting Application...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      _showSuccessDialog();
    });
  }

  bool _validateApplication() {
    // Check all required documents
    if (landPaperDocument == null) {
      _showErrorSnackBar('Please upload Land Ownership Papers');
      return false;
    }
    if (nationalIdDocument == null) {
      _showErrorSnackBar('Please upload National ID Card');
      return false;
    }
    if (proofOfIncomeDocument == null) {
      _showErrorSnackBar('Please upload Proof of Income');
      return false;
    }

    // Check required fields
    if (fullNameController.text.isEmpty ||
        nationalIdController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        landAreaController.text.isEmpty ||
        landLocationController.text.isEmpty ||
        registrationNumberController.text.isEmpty ||
        landValueController.text.isEmpty ||
        loanAmountController.text.isEmpty ||
        monthlyIncomeController.text.isEmpty ||
        businessPlanController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all required fields');
      return false;
    }

    return true;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Application Submitted!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your loan application has been successfully submitted to the Bank of Agriculture.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.teal.shade600, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Processing Time',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '2-3 business days for initial review\n5-7 business days for final approval',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We will notify you via SMS and email about your application status.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to expenses screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

