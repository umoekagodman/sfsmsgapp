import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_svg/svg.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String image;
  final VoidCallback onTap;

  const SocialLoginButton({
    required this.text,
    required this.image,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        side: const BorderSide(color: Color(0xFFCDCDCD)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            image,
            width: 24,
          ),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
