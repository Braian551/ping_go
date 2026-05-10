import 'package:flutter/material.dart';
import 'package:ping_go/src/core/config/app_config.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String? email;
  final String? imageUrl;
  final double? rating;
  final int? totalRatings;
  final VoidCallback? onEditTap;
  final Widget? customAvatarIcon;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    this.email,
    this.imageUrl,
    this.rating,
    this.totalRatings,
    this.onEditTap,
    this.customAvatarIcon,
  });

  String _resolveImageUrl(String path) {
    if (path.startsWith('http')) return path;
    String cleanPath = path;
    if (!cleanPath.startsWith('uploads/')) {
      cleanPath = 'uploads/$cleanPath';
    }
    final baseUrl = AppConfig.baseUrl;
    String rootUrl = baseUrl;
    if (baseUrl.endsWith('/backend-deploy')) {
      rootUrl = baseUrl.substring(0, baseUrl.length - '/backend-deploy'.length);
    } else if (baseUrl.endsWith('backend-deploy/')) {
       rootUrl = baseUrl.substring(0, baseUrl.length - 'backend-deploy/'.length); 
    }
    return '$rootUrl/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF222222),
                  image: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(_resolveImageUrl(imageUrl!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (imageUrl == null || imageUrl!.isEmpty)
                    ? (customAvatarIcon ?? Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                    : null,
              ),
              if (onEditTap != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFF00),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF151515), width: 4),
                      ),
                      child: const Icon(Icons.edit, color: Colors.black, size: 16),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (email != null && email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
          if (rating != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    rating!.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  if (totalRatings != null && totalRatings! > 0)
                    Text(
                      ' ($totalRatings)',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;
  final String? subtitle;
  final Color? customColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
    this.subtitle,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLogout 
                      ? Colors.red.withOpacity(0.1) 
                      : (customColor != null ? customColor!.withOpacity(0.15) : const Color(0xFF222222)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout 
                      ? Colors.redAccent 
                      : (customColor ?? Colors.white),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isLogout 
                            ? Colors.redAccent 
                            : (customColor ?? Colors.white),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isLogout ? Colors.transparent : Colors.white.withOpacity(0.2),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileLogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ProfileLogoutDialog({super.key, required this.onConfirm});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ProfileLogoutDialog(
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '¿Estás seguro de que deseas salir?',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF222222),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
