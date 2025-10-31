import 'package:flutter/material.dart';

class IconLiveCounter extends StatelessWidget {
  final String counter;
  const IconLiveCounter(this.counter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -15,
      right: -5,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Color(0xFFE72424),
          shape: BoxShape.circle,
        ),
        child: Text(counter,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}
