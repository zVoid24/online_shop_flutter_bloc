import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_shop/features/wrapper/ui/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      // theme: ThemeData(
      //   primaryColor: const Color(0xFF328E6E),
      //   scaffoldBackgroundColor: const Color(0xFFEAECCC),
      //   canvasColor: const Color(0xFFEAECCC),
      // ),
      debugShowCheckedModeBanner: false,
      home: Wrapper(),
    ),
  );
}
