import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_shop/features/wrapper/ui/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF328E6E),
        primaryColorDark: Color(0xFF328E6E),
      ),
      debugShowCheckedModeBanner: false,
      home: const Wrapper(),
    ),
  );
}
