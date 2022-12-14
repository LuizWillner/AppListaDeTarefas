import 'package:flutter/material.dart';

import 'pages/Home.dart';

const myApp = MaterialApp(
  title: "Shared Preferences",
  debugShowCheckedModeBanner: false,
  home: Home(),
);
void main() {
  runApp(myApp);
}