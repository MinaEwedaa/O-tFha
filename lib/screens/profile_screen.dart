import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../core/theme/app_colors.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _loadUserData();
  }

  void _initControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final data = await _authService.getUserData(user.uid);
      setState(() {
        _userData = data;
        _isLoading = false;
        _populateFormFields();
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _populateFormFields() {
    if (_userData != null) {
      _firstNameController.text = _userData!['firstName'] ?? '';
      _lastNameController.text = _userData!['lastName'] ?? '';
      _phoneController.text = _userData!['phone'] ?? '';
      _addressController.text = _userData!['address'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Update display name
        final displayName =
            '${_firstNameController.text} ${_lastNameController.text}'.trim();
        if (displayName.isNotEmpty) {
          await _authService.updateProfile(displayName: displayName);
        }

        // Update Firestore document
        await _authService.updateUserData(user.uid, {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'displayName': displayName,
        });

        await _loadUserData();
        setState(() => _isEditing = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<LanguageService>(context, listen: false).isArabic
                    ? 'تم حفظ الملف الشخصي بنجاح'
                    : 'Profile saved successfully',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    HapticFeedback.mediumImpact();
    
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              languageService.isArabic ? 'تسجيل الخروج' : 'Sign Out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          languageService.isArabic
              ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
              : 'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              languageService.isArabic ? 'إلغاء' : 'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              languageService.isArabic ? 'خروج' : 'Sign Out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final user = _authService.currentUser;

    return Directionality(
      textDirection: languageService.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? _buildLoadingState()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(languageService, user),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildProfileCard(languageService, user),
                            const SizedBox(height: 20),
                            _buildInfoSection(languageService),
                            const SizedBox(height: 20),
                            _buildPreferencesSection(languageService),
                            const SizedBox(height: 20),
                            _buildSignOutButton(languageService),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [AppColors.cardShadow],
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(LanguageService languageService, user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                color: _isEditing ? AppColors.error : AppColors.primary,
                size: 20,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _populateFormFields();
                }
              });
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          languageService.isArabic ? 'الملف الشخصي' : 'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildProfileCard(LanguageService languageService, user) {
    final displayName = _userData?['displayName'] ??
        user?.displayName ??
        (languageService.isArabic ? 'مستخدم' : 'User');
    final email = _userData?['email'] ?? user?.email ?? '';
    final role = _userData?['role'] ?? 'Farmer';
    final photoUrl = _userData?['photoURL'] ?? user?.photoURL;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Icon(Icons.person_rounded,
                          size: 50, color: AppColors.primary)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            displayName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            email,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role == 'Farmer' ? Icons.agriculture_rounded : Icons.store_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _getRoleLabel(role, languageService),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role, LanguageService languageService) {
    if (languageService.isArabic) {
      switch (role) {
        case 'Farmer':
          return 'مزارع';
        case 'Supplier':
          return 'مورد';
        default:
          return role;
      }
    }
    return role;
  }

  Widget _buildInfoSection(LanguageService languageService) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  languageService.isArabic
                      ? 'المعلومات الشخصية'
                      : 'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoField(
              controller: _firstNameController,
              label: languageService.isArabic ? 'الاسم الأول' : 'First Name',
              icon: Icons.person_outline_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              controller: _lastNameController,
              label: languageService.isArabic ? 'الاسم الأخير' : 'Last Name',
              icon: Icons.person_outline_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              controller: _phoneController,
              label: languageService.isArabic ? 'رقم الهاتف' : 'Phone Number',
              icon: Icons.phone_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              controller: _addressController,
              label: languageService.isArabic ? 'العنوان' : 'Address',
              icon: Icons.location_on_outlined,
              enabled: _isEditing,
              maxLines: 2,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              languageService.isArabic
                                  ? 'حفظ التغييرات'
                                  : 'Save Changes',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true,
        fillColor: enabled ? AppColors.inputBackground : AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPreferencesSection(LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings_outlined,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                languageService.isArabic ? 'الإعدادات' : 'Settings',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.language_rounded,
            title: languageService.isArabic ? 'اللغة' : 'Language',
            subtitle: languageService.isArabic ? 'العربية' : 'English',
            onTap: () {
              HapticFeedback.lightImpact();
              languageService.toggleLanguage();
            },
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                languageService.languageSwitch,
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Divider(color: AppColors.border, height: 32),
          _buildSettingTile(
            icon: Icons.notifications_outlined,
            title: languageService.isArabic ? 'الإشعارات' : 'Notifications',
            subtitle: languageService.isArabic
                ? 'إدارة إعدادات الإشعارات'
                : 'Manage notification settings',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          Divider(color: AppColors.border, height: 32),
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: languageService.isArabic ? 'الأمان' : 'Security',
            subtitle: languageService.isArabic
                ? 'كلمة المرور والأمان'
                : 'Password & security',
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: Navigate to security settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(LanguageService languageService) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _signOut,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
              const SizedBox(width: 10),
              Text(
                languageService.isArabic ? 'تسجيل الخروج' : 'Sign Out',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

