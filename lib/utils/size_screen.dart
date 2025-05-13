import 'package:flutter/material.dart';
class SizeScreen {

  bool isLargeScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 960.0;
  }

  bool isMediumScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 640.0;
  }

  bool isSmallScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width <= 640.0;
  }
}