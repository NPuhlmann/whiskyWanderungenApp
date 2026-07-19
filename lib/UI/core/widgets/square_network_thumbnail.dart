import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Square, rounded-corner network image used for list/card thumbnails.
///
/// Shows a grey box while loading; falls back to a grey box with [icon]
/// when [imageUrl] is null or the image fails to load.
class SquareNetworkThumbnail extends StatelessWidget {
  const SquareNetworkThumbnail({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.icon,
    this.borderRadius = 8,
    this.iconSize = 24,
  });

  final String? imageUrl;
  final double size;
  final double borderRadius;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url == null
          ? _fallback()
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(width: size, height: size, color: Colors.grey[300]),
              errorWidget: (context, url, error) => _fallback(),
            ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Icon(icon, size: iconSize, color: Colors.grey),
    );
  }
}
