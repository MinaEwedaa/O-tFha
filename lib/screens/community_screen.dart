import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/language_service.dart';
import '../services/community_service.dart';
import '../core/theme/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // ignore: unused_field - Will be used for Firebase integration
  final CommunityService _communityService = CommunityService();
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Directionality(
      textDirection: languageService.textDirection,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE8F5E9),
                const Color(0xFFE0F2F1),
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, languageService),
                _buildTabBar(languageService),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDiscussionsTab(languageService),
                      _buildEquipmentTab(languageService),
                      _buildExpertsTab(languageService),
                      _buildEventsTab(languageService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildFAB(languageService),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                languageService.isArabic
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: languageService.crossAxisAlignment,
              children: [
                Text(
                  languageService.isArabic ? 'خدمات المجتمع' : 'Community',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  languageService.isArabic
                      ? 'تواصل مع المزارعين الآخرين'
                      : 'Connect with fellow farmers',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.forum_rounded, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    languageService.isArabic ? 'نقاشات' : 'Forum',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.handshake_rounded, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    languageService.isArabic ? 'مشاركة' : 'Share',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_rounded, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    languageService.isArabic ? 'خبراء' : 'Experts',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_rounded, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    languageService.isArabic ? 'فعاليات' : 'Events',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DISCUSSIONS TAB ====================
  Widget _buildDiscussionsTab(LanguageService languageService) {
    final demoPosts = CommunityService.getDemoPosts();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Category chips
        SliverToBoxAdapter(
          child: _buildCategoryChips(languageService),
        ),

        // Posts list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildPostCard(demoPosts[index], languageService);
              },
              childCount: demoPosts.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(LanguageService languageService) {
    final categories = [
      {'key': 'all', 'en': 'All', 'ar': 'الكل', 'icon': Icons.grid_view_rounded},
      {'key': 'discussion', 'en': 'Discussions', 'ar': 'نقاشات', 'icon': Icons.chat_bubble_outline},
      {'key': 'question', 'en': 'Questions', 'ar': 'أسئلة', 'icon': Icons.help_outline},
      {'key': 'tip', 'en': 'Tips', 'ar': 'نصائح', 'icon': Icons.lightbulb_outline},
      {'key': 'announcement', 'en': 'News', 'ar': 'أخبار', 'icon': Icons.campaign_outlined},
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['key'];

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedCategory = cat['key'] as String);
            },
            child: Container(
              margin: EdgeInsets.only(right: languageService.isArabic ? 0 : 10, left: languageService.isArabic ? 10 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    languageService.isArabic ? cat['ar'] as String : cat['en'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post, LanguageService languageService) {
    final timeAgo = _getTimeAgo(post.createdAt, languageService);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(post.category),
                        _getCategoryColor(post.category).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      post.authorName.isNotEmpty 
                          ? post.authorName[0].toUpperCase()
                          : 'A',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: languageService.crossAxisAlignment,
                    children: [
                      Text(
                        post.authorName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(post.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getCategoryLabel(post.category, languageService),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getCategoryColor(post.category),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // Tags
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: post.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionButton(
                  icon: post.isLikedByCurrentUser
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  label: '${post.likesCount}',
                  color: post.isLikedByCurrentUser
                      ? Colors.red
                      : AppColors.textSecondary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Toggle like
                  },
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.commentsCount}',
                  color: AppColors.textSecondary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Open comments
                  },
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: languageService.isArabic ? 'مشاركة' : 'Share',
                  color: AppColors.textSecondary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Share post
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EQUIPMENT SHARING TAB ====================
  Widget _buildEquipmentTab(LanguageService languageService) {
    final demoEquipment = CommunityService.getDemoEquipment();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: languageService.crossAxisAlignment,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7B1FA2),
                        const Color(0xFF9C27B0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.agriculture_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: languageService.crossAxisAlignment,
                          children: [
                            Text(
                              languageService.isArabic
                                  ? 'شارك معداتك الزراعية'
                                  : 'Share Your Equipment',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              languageService.isArabic
                                  ? 'اكسب دخلاً إضافياً وساعد مزارعين آخرين'
                                  : 'Earn extra income & help fellow farmers',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Equipment list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildEquipmentCard(demoEquipment[index], languageService);
              },
              childCount: demoEquipment.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildEquipmentCard(SharedEquipment equipment, LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade200,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Icon(
                Icons.agriculture_rounded,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: languageService.crossAxisAlignment,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        equipment.name,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        languageService.isArabic ? 'متاح' : 'Available',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  equipment.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      equipment.location,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${equipment.pricePerDay.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      languageService.isArabic ? '/يوم' : '/day',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // TODO: Contact owner
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          languageService.isArabic ? 'تواصل' : 'Contact',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          // TODO: Request rental
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          languageService.isArabic ? 'احجز الآن' : 'Book Now',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EXPERTS TAB ====================
  Widget _buildExpertsTab(LanguageService languageService) {
    final demoExperts = CommunityService.getDemoExperts();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00897B),
                    const Color(0xFF00695C),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: languageService.crossAxisAlignment,
                      children: [
                        Text(
                          languageService.isArabic
                              ? 'استشارات زراعية'
                              : 'Expert Consultations',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          languageService.isArabic
                              ? 'احصل على نصائح من خبراء معتمدين'
                              : 'Get advice from certified professionals',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
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

        // Experts list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildExpertCard(demoExperts[index], languageService);
              },
              childCount: demoExperts.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildExpertCard(ExpertConsultant expert, LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                expert.name.isNotEmpty ? expert.name[0] : 'E',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: languageService.crossAxisAlignment,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        expert.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (expert.isAvailable)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    expert.specialty,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  expert.bio,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${expert.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' (${expert.reviewsCount})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price
                    Text(
                      '\$${expert.pricePerHour.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      languageService.isArabic ? '/ساعة' : '/hr',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // TODO: Book consultation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      languageService.isArabic ? 'احجز استشارة' : 'Book Consultation',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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

  // ==================== EVENTS TAB ====================
  Widget _buildEventsTab(LanguageService languageService) {
    final demoEvents = CommunityService.getDemoEvents();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Upcoming events header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  languageService.isArabic ? 'الفعاليات القادمة' : 'Upcoming Events',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${demoEvents.length} ${languageService.isArabic ? 'فعاليات' : 'events'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Events list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildEventCard(demoEvents[index], languageService);
              },
              childCount: demoEvents.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildEventCard(CommunityEvent event, LanguageService languageService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getEventCategoryColor(event.category),
                  _getEventCategoryColor(event.category).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd').format(event.startDate),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(event.startDate).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: languageService.crossAxisAlignment,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('hh:mm a').format(event.startDate),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.isFree 
                        ? (languageService.isArabic ? 'مجاني' : 'Free')
                        : '\$${event.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getEventCategoryColor(event.category),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: languageService.crossAxisAlignment,
              children: [
                Text(
                  event.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppColors.textTertiary, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.people_outline_rounded, color: AppColors.textTertiary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${event.attendeesCount} ${languageService.isArabic ? 'مشارك' : 'attending'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // TODO: Register for event
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getEventCategoryColor(event.category),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      languageService.isArabic ? 'سجل الآن' : 'Register Now',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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

  Widget _buildFAB(LanguageService languageService) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _showCreatePostDialog(languageService);
      },
      backgroundColor: AppColors.secondary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        languageService.isArabic ? 'نشر' : 'Post',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showCreatePostDialog(LanguageService languageService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    languageService.isArabic ? 'إنشاء منشور' : 'Create Post',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: languageService.isArabic
                            ? 'شارك أفكارك مع المجتمع...'
                            : 'Share your thoughts with the community...',
                        hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category selection
                    Text(
                      languageService.isArabic ? 'اختر الفئة' : 'Select Category',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildCategoryOption('discussion', languageService.isArabic ? 'نقاش' : 'Discussion', Icons.chat),
                        _buildCategoryOption('question', languageService.isArabic ? 'سؤال' : 'Question', Icons.help),
                        _buildCategoryOption('tip', languageService.isArabic ? 'نصيحة' : 'Tip', Icons.lightbulb),
                      ],
                    ),
                    const Spacer(),
                    // Post button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Create post
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          languageService.isArabic ? 'نشر' : 'Post',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String category, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getCategoryColor(category).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _getCategoryColor(category)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _getCategoryColor(category),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  
  String _getTimeAgo(DateTime dateTime, LanguageService languageService) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return languageService.isArabic
          ? 'منذ ${difference.inDays} يوم'
          : '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return languageService.isArabic
          ? 'منذ ${difference.inHours} ساعة'
          : '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return languageService.isArabic
          ? 'منذ ${difference.inMinutes} دقيقة'
          : '${difference.inMinutes}m ago';
    } else {
      return languageService.isArabic ? 'الآن' : 'Just now';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'discussion':
        return AppColors.info;
      case 'question':
        return Colors.orange;
      case 'tip':
        return AppColors.success;
      case 'announcement':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _getCategoryLabel(String category, LanguageService languageService) {
    final labels = {
      'discussion': languageService.isArabic ? 'نقاش' : 'Discussion',
      'question': languageService.isArabic ? 'سؤال' : 'Question',
      'tip': languageService.isArabic ? 'نصيحة' : 'Tip',
      'announcement': languageService.isArabic ? 'إعلان' : 'Announcement',
    };
    return labels[category] ?? category;
  }

  Color _getEventCategoryColor(String category) {
    switch (category) {
      case 'workshop':
        return const Color(0xFF5C6BC0);
      case 'market':
        return const Color(0xFFFF7043);
      case 'training':
        return const Color(0xFF26A69A);
      case 'social':
        return const Color(0xFFAB47BC);
      default:
        return AppColors.primary;
    }
  }
}

