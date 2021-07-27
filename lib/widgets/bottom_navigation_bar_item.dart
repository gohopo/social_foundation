import 'package:flutter/material.dart';
import 'package:social_foundation/utils/contracts.dart';

class SfBottomNavigationBarItem extends BottomNavigationBarItem{
  SfBottomNavigationBarItem({
    @required WidgetWrapper iconWrapper,
    @required Widget icon,
    Widget activeIcon,
    String label,
    Color backgroundColor,
  }) : super(
    icon: iconWrapper(icon),
    label: label,
    activeIcon: iconWrapper(activeIcon??icon),
    backgroundColor: backgroundColor
  );
}