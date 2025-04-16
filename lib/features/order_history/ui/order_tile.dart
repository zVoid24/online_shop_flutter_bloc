import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_shop/models/order.dart';
class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy – hh:mm a').format(order.date.toDate());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF328E6E),
          child: Text(
            order.orderId.substring(0, 2),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('Order #${order.orderId.substring(0, 8)}'),
        subtitle: Text('$formattedDate  \$${order.amount.toStringAsFixed(2)}'),
        trailing: SizedBox(
          width: 80,
          child: Chip(
            label: Text(order.status=='completed'?'Done':order.status,style:TextStyle(fontSize: 15)),
            
            backgroundColor: order.status == 'completed' ? Color(0xFF328E6E).withOpacity(0.3) : Colors.grey[300],
          ),
        ),
        children: order.items.map((item) {
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Qty: ${item.quantity} • \$${item.price.toStringAsFixed(2)} each'),
            trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
          );
        }).toList(),
      ),
    );
  }
}