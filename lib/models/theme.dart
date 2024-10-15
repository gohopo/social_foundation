import 'package:flutter/material.dart';

class SfTheme{
  SfTheme({this.name,Color? primary,this.primaryLight,this.pageBackground,this.navbarBackground,this.divider}):primary=primary??Colors.green;
  String? name;
  Color primary;
  Color? primaryLight;
  Color? pageBackground;
  Color? navbarBackground;
  Color? divider;
}

class SfColorSwatch{
  Map<int,Color> _swatch = {};
  SfColorSwatch(Color color){
    reset(color);
  }
  Color? operator [](int index) => _swatch[index];
  void reset(Color color){
    if(this[500]==color) return;
    _swatch[50] = Color.alphaBlend(Color.fromRGBO(255,255,255,0.95),color);
    _swatch[100] = Color.alphaBlend(Color.fromRGBO(255,255,255,0.90),color);
    _swatch[200] = Color.alphaBlend(Color.fromRGBO(255,255,255,0.75),color);
    _swatch[300] = Color.alphaBlend(Color.fromRGBO(255,255,255,0.60),color);
    _swatch[400] = Color.alphaBlend(Color.fromRGBO(255,255,255,0.30),color);
    _swatch[500] = color;
    _swatch[600] = Color.alphaBlend(Color.fromRGBO(0,0,0,0.10),color);
    _swatch[700] = Color.alphaBlend(Color.fromRGBO(0,0,0,0.25),color);
    _swatch[800] = Color.alphaBlend(Color.fromRGBO(0,0,0,0.40),color);
    _swatch[900] = Color.alphaBlend(Color.fromRGBO(0,0,0,0.51),color);
  }
  void clear() => _swatch.clear();
}