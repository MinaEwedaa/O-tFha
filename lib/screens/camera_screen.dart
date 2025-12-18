import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ml_service.dart';
import '../services/huggingface_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final HuggingFaceService _huggingFaceService = HuggingFaceService();
  File? _selectedImage;
  bool _isLoading = false;
  bool _multipleMode = false;
  String _selectedCategory = 'Plant';
  File? _lastPickedImage;

  @override
  void initState() {
    super.initState();
    // Set status bar to transparent for full screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // Initialize ML service
    _initializeML();
  }

  Future<void> _initializeML() async {
    try {
      await _huggingFaceService.initialize();
      print('✅ HuggingFace ML initialized');
    } catch (e) {
      print('⚠️ Failed to initialize HuggingFace ML: $e');
      _showErrorSnackBar('Failed to initialize AI service. Please check your internet connection.');
    }
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _huggingFaceService.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _lastPickedImage = File(photo.path);
        });
        _analyzeImage(File(photo.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take picture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _lastPickedImage = File(image.path);
        });
        _analyzeImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _selectedImage = imageFile;
    });

    try {
      // Use HuggingFace Inference API (crop_leaf_diseases_vit model)
      final result = await _huggingFaceService.classifyImage(imageFile);

      if (mounted) {
        // Navigate to results screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              result: result,
              imageFile: imageFile,
            ),
          ),
        ).then((_) {
          // Clear the image when returning
          setState(() {
            _selectedImage = null;
            _isLoading = false;
          });
        });
      }
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      setState(() {
        _selectedImage = null;
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content area
          Center(
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.contain,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Camera viewfinder frame
                      CustomPaint(
                        painter: ViewfinderPainter(),
                        size: const Size(300, 300),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Position plant within frame',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analyzing crop disease...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'AI-powered disease detection',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top bar with close button and AI indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    // AI indicator badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI Powered',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Identify / Multiple toggle buttons
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeButton('Identify', !_multipleMode, () {
                          setState(() {
                            _multipleMode = false;
                          });
                        }),
                        const SizedBox(width: 16),
                        _buildModeButton('Multiple', _multipleMode, () {
                          setState(() {
                            _multipleMode = true;
                          });
                        }),
                      ],
                    ),
                  ),

                  // Category selection
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildCategoryButton('Plant', Icons.local_florist),
                        _buildCategoryButton('Mushroom', Icons.park),
                        _buildCategoryButton('Weed', Icons.grass),
                        _buildCategoryButton('Disease', Icons.bug_report),
                      ],
                    ),
                  ),

                  // Bottom action bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Gallery preview button
                        GestureDetector(
                          onTap: _isLoading ? null : _pickFromGallery,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: _lastPickedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _lastPickedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                          ),
                        ),

                        // Camera shutter button
                        GestureDetector(
                          onTap: _isLoading ? null : _takePicture,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Info button
                        GestureDetector(
                          onTap: _showInfoDialog,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade700 : Colors.white24,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'How to use',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '🌿 Crop Disease Detection\n\n'
          '1. Select plant category\n'
          '2. Take a photo or choose from gallery\n'
          '3. Make sure the plant leaf is clearly visible\n'
          '4. Wait for AI analysis results\n\n'
          '💡 Tip: For best results, take a close-up photo of the affected leaf with good lighting.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the viewfinder frame
class ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 40.0;
    const cornerRadius = 16.0;

    // Top-left corner
    final topLeftPath = Path()
      ..moveTo(cornerRadius, 0)
      ..lineTo(cornerLength, 0)
      ..moveTo(0, cornerRadius)
      ..lineTo(0, cornerLength);
    canvas.drawPath(topLeftPath, paint);

    // Top-right corner
    final topRightPath = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - cornerRadius, 0)
      ..moveTo(size.width, cornerRadius)
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(topRightPath, paint);

    // Bottom-left corner
    final bottomLeftPath = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - cornerRadius)
      ..moveTo(cornerRadius, size.height)
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(bottomLeftPath, paint);

    // Bottom-right corner
    final bottomRightPath = Path()
      ..moveTo(size.width, size.height - cornerLength)
      ..lineTo(size.width, size.height - cornerRadius)
      ..moveTo(size.width - cornerRadius, size.height)
      ..lineTo(size.width - cornerLength, size.height);
    canvas.drawPath(bottomRightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Result Screen with updated design
class ResultScreen extends StatelessWidget {
  final PredictionResult result;
  final File imageFile;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
  });

  Color _getSeverityColor() {
    if (result.isHealthy) return Colors.green;
    if (result.confidence > 0.9) return Colors.red;
    if (result.confidence > 0.7) return Colors.orange;
    return Colors.yellow.shade700;
  }

  IconData _getSeverityIcon() {
    if (result.isHealthy) return Icons.check_circle;
    if (result.confidence > 0.9) return Icons.warning;
    if (result.confidence > 0.7) return Icons.info;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();
    final severityIcon = _getSeverityIcon();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image with overlay
          Positioned.fill(
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.5, 0.8],
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () {
                        // Share functionality could be added here
                      },
                      icon: const Icon(Icons.share, color: Colors.white, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Result content at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status indicator
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: severityColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                severityIcon,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                result.isHealthy ? 'Healthy' : 'Disease Detected',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Disease name
                    Text(
                      result.disease,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Confidence
                    Text(
                      'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Scan Again',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _showDetailsDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'View Details',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    final severityColor = _getSeverityColor();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Detailed Analysis',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Confidence meter
                    Text(
                      'Confidence Level',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: result.confidence,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(severityColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.severityLevel,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: severityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Top predictions
                    if (result.topPredictions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Alternative Predictions',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...result.topPredictions
                          .take(5)
                          .map((prediction) => _buildPredictionItem(prediction))
                          ,
                    ],

                    // Recommendations
                    if (!result.isHealthy) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recommendations',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '• Consult with a plant pathologist\n'
                              '• Remove affected leaves if possible\n'
                              '• Apply appropriate fungicide or treatment\n'
                              '• Improve air circulation around plants\n'
                              '• Monitor surrounding plants for symptoms',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(TopPrediction prediction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              prediction.className,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(prediction.confidence * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: prediction.confidence,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
