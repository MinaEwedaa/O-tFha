import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  
  const LoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading indicator with optional message
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  
  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              color: color ?? AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading effect for list items
class ShimmerLoading extends StatefulWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  
  const ShimmerLoading({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height ?? 100,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                AppColors.border,
                AppColors.borderLight,
                AppColors.border,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// List shimmer loading
class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  
  const ListShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoading(
            height: itemHeight,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

/// Grid shimmer loading
class GridShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final int crossAxisCount;
  final EdgeInsetsGeometry? padding;
  
  const GridShimmer({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 150,
    this.crossAxisCount = 2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          height: itemHeight,
          borderRadius: BorderRadius.circular(12),
        );
      },
    );
  }
}

