import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'logger.dart';

/// Helper utilities for common operations
class Helpers {
  /// Shows a snackbar with the given message
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }
  
  /// Shows a success snackbar
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }
  
  /// Shows an error snackbar
  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }
  
  /// Shows a warning snackbar
  static void showWarning(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.orange);
  }
  
  /// Shows a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message ?? 'Loading...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Dismisses the loading dialog
  static void dismissLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  
  /// Shows a confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? TextButton.styleFrom(foregroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// Shows a delete confirmation dialog
  static Future<bool> showDeleteConfirmDialog(
    BuildContext context, {
    String title = 'Delete Item',
    String message = 'Are you sure you want to delete this item? This action cannot be undone.',
  }) async {
    return await showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );
  }
  
  /// Picks an image from camera or gallery
  static Future<File?> pickImage(
    BuildContext context, {
    required ImageSource source,
  }) async {
    try {
      // Check permission
      final permission = source == ImageSource.camera
          ? Permission.camera
          : Permission.photos;
      
      final status = await permission.request();
      
      if (!status.isGranted) {
        if (context.mounted) {
          showError(context, 'Permission denied');
        }
        return null;
      }
      
      // Pick image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        return null;
      }
      
      return File(pickedFile.path);
    } catch (e, stackTrace) {
      AppLogger.error('Error picking image', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        showError(context, 'Failed to pick image');
      }
      return null;
    }
  }
  
  /// Shows an image source selection dialog
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (source == null) return null;
    
    return await pickImage(context, source: source);
  }
  
  /// Unfocuses the current text field
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  
  /// Checks if the device is connected to the internet
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  
  /// Delays execution for the specified duration
  static Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }
  
  /// Executes a function with retry logic
  static Future<T> retry<T>(
    Future<T> Function() function, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    
    while (true) {
      try {
        attempts++;
        return await function();
      } catch (e) {
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
  }
  
  /// Debounces a function call
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Future.delayed(delay, callback);
  }
}



