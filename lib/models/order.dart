import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_shop/models/product.dart';

class Order {
  final Timestamp date;
  final List<Product> items;
  final String orderId;
  final String status;
  final double amount;
  Order({
    required this.date,
    required this.items,
    required this.orderId,
    required this.status,
    required this.amount,
  });
}
