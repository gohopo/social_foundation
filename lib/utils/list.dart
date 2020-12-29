import 'dart:collection';

import 'package:flutter/foundation.dart';

class SfQueue<T>{
  SfQueue(this.onPop);
  AsyncValueSetter<T> onPop;
  Queue<T> queue = Queue();
  void add(T item){
    queue.add(item);
    if(queue.length==1) _process();
  }
  void addAll(List<T> items) => items?.forEach((item) => add(item));
  void clear() => queue.removeWhere((item) => item!=queue.first);
  Future pop(T item) => onPop?.call(item);
  void _process() async {
    while(queue.isNotEmpty){
      await pop(queue.first);
      queue.removeFirst();
    }
  }
}