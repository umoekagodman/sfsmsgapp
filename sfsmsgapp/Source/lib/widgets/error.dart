import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';

class Error extends StatelessWidget {
  final VoidCallback callback;
  const Error({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            SizedBox(height: 10),
            Text(
              tr("There is something that went wrong!"),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: callback,
              child: Text(tr("Try Again")),
            ),
          ],
        ),
      ),
    );
  }
}
