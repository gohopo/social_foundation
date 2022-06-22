import 'dart:collection';

import 'package:flutter/foundation.dart';

class SfQueue<T>{
  SfQueue(this.onPop);
  AsyncValueSetter<T>? onPop;
  Queue<T> queue = Queue();
  void add(T item){
    queue.add(item);
    if(queue.length==1) _process();
  }
  void addAll(List<T>? items) => items?.forEach((item) => add(item));
  void clear() => queue.removeWhere((item) => item!=queue.first);
  Future pop(T item) async => onPop?.call(item);
  void _process() async {
    while(queue.isNotEmpty){
      await pop(queue.first);
      queue.removeFirst();
    }
  }
}

class SfMap<K,T>{
  Map<K,T> _map = {};
  void clear() => _map.clear();
  T? find(K key) => _map[key];
  List<K> get keys => _map.keys.toList();
  List<T> get values => _map.values.toList();
  void update(K key,T item){
    _map[key] = item;
  }
}