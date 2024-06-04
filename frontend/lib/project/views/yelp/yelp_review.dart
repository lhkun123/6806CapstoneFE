import 'package:flutter/cupertino.dart';
import 'package:frontend/project/constants/app_style.dart';

class YelpReview extends StatelessWidget {
  const YelpReview({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        Text(
          'Hello, Flutter!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppStyle.textColor,
          ),
        ),
      ],
    );
  }
}