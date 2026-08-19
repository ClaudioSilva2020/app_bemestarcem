import 'package:flutter/material.dart';

const Color yellow = Color(0xff2196F3);
const Color mediumYellow = Color(0xff1E88E5);
const Color darkYellow = Color(0xff1565C0);
const Color transparentYellow = Color.fromRGBO(33, 150, 243, 0.7);
const Color darkGrey = Color(0xff202020);

const LinearGradient mainButton = LinearGradient(colors: [
  Color.fromRGBO(21, 101, 192, 1),
  Color.fromRGBO(30, 136, 229, 1),
  Color.fromRGBO(66, 165, 245, 1),
], begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter);

const List<BoxShadow> shadow = [
  BoxShadow(color: Colors.black12, offset: Offset(0, 3), blurRadius: 6)
];

screenAwareSize(int size, BuildContext context) {
  double baseHeight = 640.0;
  return size * MediaQuery.of(context).size.height / baseHeight;
}