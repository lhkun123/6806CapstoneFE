import 'package:flutter/material.dart';
import 'package:frontend/project/constants/app_style.dart';

class WeatherDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const WeatherDetailItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppStyle.sloganFont,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyle.bigBlackFont,
          ),
        ],
      ),
    );
  }
}
