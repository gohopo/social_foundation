import 'package:flutter/widgets.dart';
import 'package:social_foundation/utils/list.dart';

class SfWidgetHelper{
  static List<Widget> join(Iterable<Widget> list,Widget separator) => SfListHelper.join<Widget>(list,separator);
}