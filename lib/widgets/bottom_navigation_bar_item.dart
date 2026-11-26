import 'package:flutter/material.dart';
import 'package:social_foundation/utils/contracts.dart';

class SfBottomNavigationBarItem extends BottomNavigationBarItem{
  SfBottomNavigationBarItem({
    required WidgetWrapper iconWrapper,
    required Widget icon,
    Widget? activeIcon,
    super.label,
    super.backgroundColor,
  }) : super(
    icon: iconWrapper(icon),
    activeIcon: iconWrapper(activeIcon??icon)
  );
}