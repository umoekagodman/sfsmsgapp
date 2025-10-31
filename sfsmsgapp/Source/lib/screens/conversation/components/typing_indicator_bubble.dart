import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TypingIndicatorBubble extends StatelessWidget {
  const TypingIndicatorBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: IntrinsicWidth(
            child: SpinKitThreeBounce(
              color: Colors.grey,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
