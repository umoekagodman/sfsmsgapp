import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_svg/flutter_svg.dart';

class ErrorScreen extends StatelessWidget {
  final String title, message;
  const ErrorScreen({
    super.key,
    this.title = "Oops!",
    this.message = "Something went wrong!",
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            const Spacer(flex: 1),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SvgPicture.asset('assets/images/error.svg'),
              ),
            ),
            const SizedBox(height: 60),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
