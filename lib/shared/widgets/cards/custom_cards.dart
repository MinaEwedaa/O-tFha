import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Custom card widget with consistent styling
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final double? elevation;
  final BorderRadius? borderRadius;
  
  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      elevation: elevation ?? 2,
      margin: margin ?? const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// Info card with icon and text
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: backgroundColor ?? Colors.white,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );
  }
}

/// Stat card for displaying statistics
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;
  
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color ?? AppColors.primary,
                size: 24,
              ),
            ),
          if (icon != null) const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Image card with optional overlay
class ImageCard extends StatelessWidget {
  final String? imageUrl;
  final Widget? placeholder;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? overlay;
  final VoidCallback? onTap;
  
  const ImageCard({
    super.key,
    this.imageUrl,
    this.placeholder,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.overlay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [AppColors.cardShadow],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Image.network(
                  imageUrl!,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) =>
                      placeholder ??
                      Container(
                        color: AppColors.border,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.textTertiary,
                          size: 48,
                        ),
                      ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
              else
                placeholder ??
                    Container(
                      color: AppColors.border,
                      child: Icon(
                        Icons.image,
                        color: AppColors.textTertiary,
                        size: 48,
                      ),
                    ),
              if (overlay != null) overlay!,
            ],
          ),
        ),
      ),
    );
  }
}

