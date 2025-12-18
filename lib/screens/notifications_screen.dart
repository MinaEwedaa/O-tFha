import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../services/language_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _notificationService.createSampleNotifications();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'weather':
        return Icons.cloud_rounded;
      case 'task':
        return Icons.task_alt_rounded;
      case 'market':
        return Icons.store_rounded;
      case 'community':
        return Icons.people_rounded;
      case 'system':
      default:
        return Icons.info_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'weather':
        return const Color(0xFF2196F3);
      case 'task':
        return const Color(0xFF4CAF50);
      case 'market':
        return const Color(0xFFFF9800);
      case 'community':
        return const Color(0xFF9C27B0);
      case 'system':
      default:
        return const Color(0xFF00897B);
    }
  }

  String _formatTime(DateTime dateTime, bool isArabic) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return isArabic ? 'الآن' : 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return isArabic ? 'منذ $mins دقيقة' : '${mins}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return isArabic ? 'منذ $hours ساعة' : '${hours}h ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return isArabic ? 'منذ $days يوم' : '${days}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Directionality(
      textDirection: languageService.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(languageService),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: StreamBuilder<List<AppNotification>>(
            stream: _notificationService.getNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }

              if (snapshot.hasError) {
                return _buildErrorState(languageService);
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return _buildEmptyState(languageService);
              }

              return _buildNotificationsList(notifications, languageService);
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(LanguageService languageService) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      title: Text(
        languageService.isArabic ? 'الإشعارات' : 'Notifications',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (value) async {
            HapticFeedback.lightImpact();
            if (value == 'read_all') {
              await _notificationService.markAllAsRead();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      languageService.isArabic
                          ? 'تم تحديد الكل كمقروء'
                          : 'All marked as read',
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            } else if (value == 'clear_all') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    languageService.isArabic
                        ? 'مسح جميع الإشعارات'
                        : 'Clear All Notifications',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    languageService.isArabic
                        ? 'هل أنت متأكد أنك تريد مسح جميع الإشعارات؟'
                        : 'Are you sure you want to clear all notifications?',
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        languageService.isArabic ? 'مسح' : 'Clear',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _notificationService.clearAllNotifications();
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'read_all',
              child: Row(
                children: [
                  Icon(Icons.done_all_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    languageService.isArabic
                        ? 'تحديد الكل كمقروء'
                        : 'Mark all as read',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    languageService.isArabic
                        ? 'مسح الكل'
                        : 'Clear all',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
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

  Widget _buildErrorState(LanguageService languageService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            languageService.isArabic
                ? 'خطأ في تحميل الإشعارات'
                : 'Error loading notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LanguageService languageService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            languageService.isArabic
                ? 'لا توجد إشعارات'
                : 'No notifications',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            languageService.isArabic
                ? 'ستظهر إشعاراتك هنا'
                : 'Your notifications will appear here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    List<AppNotification> notifications,
    LanguageService languageService,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification, languageService, index);
      },
    );
  }

  Widget _buildNotificationCard(
    AppNotification notification,
    LanguageService languageService,
    int index,
  ) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);
    final title = languageService.isArabic ? notification.titleAr : notification.title;
    final body = languageService.isArabic ? notification.bodyAr : notification.body;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (direction) {
          HapticFeedback.mediumImpact();
          _notificationService.deleteNotification(notification.id);
        },
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (!notification.isRead) {
              _notificationService.markAsRead(notification.id);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.white
                  : color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: notification.isRead
                    ? AppColors.border
                    : color.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                // Content
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
                                fontSize: 15,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt, languageService.isArabic),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
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
    );
  }
}
















