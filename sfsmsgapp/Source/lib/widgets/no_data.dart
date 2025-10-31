import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';

class NoData extends StatelessWidget {
  final String? text;
  const NoData({
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SvgPicture.asset("assets/images/empty.svg", width: 100, height: 100),
        const SizedBox(height: 20),
        Text(
          text ?? tr("No data to show"),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
