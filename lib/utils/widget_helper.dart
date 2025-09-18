import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class SfWidgetHelper{
  static List<Widget> join(Iterable<Widget> list,Widget separator) => list.foldIndexed<List<Widget>>([],(index,t,x){
    if(index!=0) t.add(separator);
    return t..add(x);
  });
}