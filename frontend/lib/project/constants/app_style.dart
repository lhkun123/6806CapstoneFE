import 'package:flutter/material.dart';

class AppStyle {
  // Fonts
  static const bigheadingFont = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Colors.black,
  );
  // Fonts
  static const headingFont = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    fontSize: 17,
    color: Colors.black,
  );

  static const subheadingFont = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Colors.black,
  );

  static const bodyTextFont = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: Colors.black,
  );

  static const tinyTextFont = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.normal,
    fontSize: 8,
    color: Colors.black,
  );

  // Colors
  static const primaryColor = Color(0xFF7EBDC2);
  static const cardBackgroundColor = Color(0xFFFFFFFF);
  static const largeBackgroundColor = Color(0xFFF5F5F5); // 也用作小按钮颜色
  static const textColor = Color(0xFF262F34);
}
