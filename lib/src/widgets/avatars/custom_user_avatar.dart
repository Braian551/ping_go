import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class CustomUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  const CustomUserAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.borderWidth = 0,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.fallbackIcon = Icons.person,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = AppConfig.resolveImageUrl(imageUrl);
    final hasImage = effectiveUrl.isNotEmpty;

    Widget avatarContent = ClipOval(
      child: hasImage
          ? Image.network(
              effectiveUrl,
              key: ValueKey(effectiveUrl), // Critical for cache stability
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: radius,
                    height: radius,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: (borderColor ?? const Color(0xFFFFD700)).withOpacity(0.5),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // debugPrint('AvatarLoadError: $error for $effectiveUrl');
                return _buildFallback();
              },
            )
          : _buildFallback(),
    );

    if (onTap != null) {
      avatarContent = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatarContent,
      );
    }

    return Container(
      width: radius * 2 + (borderWidth * 2),
      height: radius * 2 + (borderWidth * 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[800],
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? Colors.transparent,
                width: borderWidth,
              )
            : null,
      ),
      child: Center(child: avatarContent), // Center to ensure border wraps correctly
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Icon(
        fallbackIcon,
        size: radius * 1.2, // Slightly larger than radius usually looks good for icons
        color: fallbackColor ?? Colors.white54,
      ),
    );
  }
}
