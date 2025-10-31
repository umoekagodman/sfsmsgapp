import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import App Files
import '../common/themes.dart';

class OverlappingProfileAvatars extends StatelessWidget {
  final String leftImageUrl;
  final String rightImageUrl;
  final double radius;

  const OverlappingProfileAvatars({
    required this.leftImageUrl,
    required this.rightImageUrl,
    this.radius = 20.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSize = radius * 2;
    final double miniRadius = radius * 0.75;
    final double miniSize = miniRadius * 2;

    Widget buildAvatar(String imageUrl, {bool addBorder = false}) {
      return Container(
        width: miniSize,
        height: miniSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: addBorder
              ? Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? xBackgroundColorDark : xBackgroundColor,
                  width: 3,
                )
              : null,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(xPrimaryColor),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      );
    }

    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: Stack(
        children: [
          // Back (top-right)
          Positioned(
            right: 0,
            top: 0,
            child: buildAvatar(rightImageUrl),
          ),
          // Front (bottom-left) with white border
          Positioned(
            left: 0,
            bottom: 0,
            child: buildAvatar(leftImageUrl, addBorder: true),
          ),
        ],
      ),
    );
  }
}
