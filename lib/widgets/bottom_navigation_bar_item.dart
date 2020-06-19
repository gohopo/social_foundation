import 'package:flutter/material.dart';
import 'package:social_foundation/utils/contracts.dart';

class SfBottomNavigationBarItem extends BottomNavigationBarItem{
  SfBottomNavigationBarItem({
    @required WidgetWrapper iconWrapper,
    @required Widget icon,
    Widget activeIcon,
    Widget title,
    Color backgroundColor,
  }) : super(
    icon: iconWrapper(icon),
    title: title,
    activeIcon: iconWrapper(activeIcon),
    backgroundColor: backgroundColor
  );
}