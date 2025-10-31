import 'package:flutter/material.dart';

class DividerText extends StatelessWidget {
  final String text;

  const DividerText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 25),
        Row(
          children: [
            const Expanded(
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(text),
            ),
            const Expanded(
              child: Divider(),
            ),
          ],
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
