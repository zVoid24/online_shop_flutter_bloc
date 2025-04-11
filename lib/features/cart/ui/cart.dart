import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:online_shop/features/cart/bloc/cart_bloc.dart';
import 'package:online_shop/features/cart/ui/product_tile.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final CartBloc _cartBloc = CartBloc();

  @override
  void initState() {
    _cartBloc.add(CartInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      bloc: _cartBloc,
      listenWhen: (previous, current) => current is CartActionState,
      buildWhen: (previous, current) => current is! CartActionState,
      listener: (context, state) {
        if (state is CartProductRemovedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product removed from cart!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
        } else if (state is OneProductDecreasedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.name} quantity decreased!'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        switch (state) {
          case CartLoading _:
            return const Center(
              child: SpinKitSpinningLines(color: Color(0xFF328E6E), size: 50.0),
            );
          case CartSuccess(:final products):
            return RefreshIndicator(
              onRefresh: () async {
                _cartBloc.add(CartInitialEvent());
              },
              color: const Color(0xFF328E6E),
              backgroundColor: const Color(0xFFEAECCC),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductTile(
                      cartBloc: _cartBloc,
                      product: products[index],
                    );
                  },
                ),
              ),
            );
          case EmptyCartState _:
            return const Center(child: Text('Your cart is empty'));
          case CartFailure(:final error):
            return Center(child: Text(error));
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
