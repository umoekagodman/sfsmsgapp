import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import App Files
import '../common/themes.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  final bool hasBorder;
  final double radius;
  const ProfileAvatar({
    required this.imageUrl,
    this.isOnline = false,
    this.hasBorder = false,
    this.radius = 20.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: (hasBorder) ? radius + 3 : radius,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3D3D3D) : const Color(0xFFCCCCCC),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3D3D3D) : const Color(0xFFCCCCCC),
              backgroundImage: NetworkImage(imageUrl),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(xPrimaryColor),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        (isOnline)
            ? Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
