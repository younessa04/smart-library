import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double wp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }

  static double hp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.2;
    } else {
      return baseFontSize * 1.4;
    }
  }

  static int getGridColumnCount(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  static EdgeInsets getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static double getCardWidth(BuildContext context) {
    final screenWidth = getWidth(context);
    if (isMobile(context)) {
      return (screenWidth - 48) / 2; // 2 cards with 16px padding and 16px spacing
    } else if (isTablet(context)) {
      return (screenWidth - 80) / 3; // 3 cards
    } else {
      return (screenWidth - 128) / 4; // 4 cards
    }
  }
}
