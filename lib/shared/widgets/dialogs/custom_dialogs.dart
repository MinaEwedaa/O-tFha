import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Custom alert dialog
class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;
  final Color? iconColor;
  
  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Column(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(false),
            child: Text(
              cancelText!,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        if (confirmText != null)
          TextButton(
            onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? TextButton.styleFrom(foregroundColor: confirmColor)
                : null,
            child: Text(
              confirmText!,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Success dialog
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;
  
  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: title,
      message: message,
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      confirmText: buttonText ?? 'OK',
      onConfirm: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Error dialog
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;
  
  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: title,
      message: message,
      icon: Icons.error,
      iconColor: AppColors.error,
      confirmText: buttonText ?? 'OK',
      onConfirm: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Warning dialog
class WarningDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  
  const WarningDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: title,
      message: message,
      icon: Icons.warning,
      iconColor: AppColors.warning,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: AppColors.warning,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}

/// Delete confirmation dialog
class DeleteConfirmDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String? itemName;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  
  const DeleteConfirmDialog({
    super.key,
    this.title,
    this.message,
    this.itemName,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final defaultMessage = itemName != null
        ? 'Are you sure you want to delete "$itemName"? This action cannot be undone.'
        : 'Are you sure you want to delete this item? This action cannot be undone.';
        
    return CustomAlertDialog(
      title: title ?? 'Delete Item',
      message: message ?? defaultMessage,
      icon: Icons.delete,
      iconColor: AppColors.error,
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: AppColors.error,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}

/// Info dialog
class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;
  
  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: title,
      message: message,
      icon: Icons.info,
      iconColor: AppColors.info,
      confirmText: buttonText ?? 'OK',
      onConfirm: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Bottom sheet dialog
class CustomBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;
  
  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

