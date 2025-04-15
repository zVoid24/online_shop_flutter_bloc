// lib/features/order_history/ui/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/features/order_history/bloc/order_history_bloc.dart';
import 'package:online_shop/features/order_history/ui/order_tile.dart';
import 'package:online_shop/models/order.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  late final OrderHistoryBloc _orderHistoryBloc;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user?.uid != null) {
      _orderHistoryBloc = OrderHistoryBloc(
        userDatabase: UserDatabase(uid: user!.uid),
      );
      _orderHistoryBloc.add(OrderHistoryFetchEvent());
    } else {
      throw Exception('User is not authenticated');
    }
  }

  @override 
  void dispose() {
    _orderHistoryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order History',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF328E6E),
      ),
      body: BlocConsumer<OrderHistoryBloc, OrderHistoryState>(
        bloc: _orderHistoryBloc,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case OrderHistoryLoading:
              return const Center(
                child: SpinKitSpinningLines(
                  color: Color(0xFF328E6E),
                  size: 50.0,
                ),
              );
            case OrderHistorySuccess:
              final successState = state as OrderHistorySuccess;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<OrderHistoryBloc>().add(
                    OrderHistoryFetchEvent(),
                  );
                },
                color: const Color(0xFF328E6E),
                backgroundColor: const Color(0xFFEAECCC),
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: successState.orders.length,
                  itemBuilder: (context, index) {
                    final order = successState.orders[index];
                    return OrderCard(order: order);
                  },
                ),
              );
            case OrderHistoryEmpty:
              return const Center(child: Text('No orders found'));
            case OrderHistoryFailure:
              final failureState = state as OrderHistoryFailure;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${failureState.error}'),
                    ElevatedButton(
                      onPressed:
                          () => context.read<OrderHistoryBloc>().add(
                            OrderHistoryFetchEvent(),
                          ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            default:
              return const Center(child: Text('Loading...'));
          }
        },
      ),
    );
  }
}
