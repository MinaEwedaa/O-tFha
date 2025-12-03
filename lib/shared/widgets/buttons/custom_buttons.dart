import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Custom primary button widget
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
    
    if (height != null) {
      button = SizedBox(height: height, child: button);
    }
    
    return button;
  }
}

/// Custom outline button widget
class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  
  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.borderColor,
    this.textColor,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        side: BorderSide(
          color: borderColor ?? AppColors.primary,
          width: 1.5,
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor ?? AppColors.primary,
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
    
    if (height != null) {
      button = SizedBox(height: height, child: button);
    }
    
    return button;
  }
}

/// Custom text button widget
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;
  
  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom icon button with styling
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  
  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: color ?? AppColors.primary,
        iconSize: size * 0.5,
        padding: EdgeInsets.zero,
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}

