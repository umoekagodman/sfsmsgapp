import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_html/flutter_html.dart';

class StaticScreen extends StatelessWidget {
  final String title;
  final Future<String> content;

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
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            FutureBuilder<String>(
              future: content,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Html(data: snapshot.data);
                } else if (snapshot.hasError) {
                  return Text(tr("Something went wrong!"));
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
