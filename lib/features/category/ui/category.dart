import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  final String title;
  const Category({super.key, required this.title});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
