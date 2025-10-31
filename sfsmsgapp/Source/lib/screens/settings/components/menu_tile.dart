import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  final VoidCallback onTab;
  final String title;
  final Widget icon;

  const MenuTile({
    required this.onTab,
    required this.title,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3a3b3b) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTab,
            child: Row(
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
