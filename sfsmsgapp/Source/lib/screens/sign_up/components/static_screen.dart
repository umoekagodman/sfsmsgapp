import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:easy_localization/easy_localization.dart';

class StaticScreen extends StatelessWidget {
  final String title;
  final String content;

  const StaticScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            // Directly show the HTML since content is already loaded
            (content.isNotEmpty)
                ? Html(data: content)
                : Center(
                    child: Text(
                      tr("No content available."),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
