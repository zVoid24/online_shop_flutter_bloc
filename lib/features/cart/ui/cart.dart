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
  double _amount = 0;

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
        } else if (state is CheckOutSuccess) {
          _cartBloc.add(CartInitialEvent());
        } else if (state is CheckOutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Checkout Failed'),
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
              child: Column(
                children: [
                  // Wrap ListView in Expanded to leave space for the button
                  Expanded(
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
                  ),
                  // Add Checkout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity, // Full-width button
                      child: ElevatedButton(
                        onPressed:
                            products.isEmpty
                                ? null // Disable button if cart is empty
                                : () async {
                                  // Add checkout logic here
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Proceeding to checkout...',
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  _cartBloc.add(
                                    CheckOutButtonClicked(amount: state.amount),
                                  );
                                  // Example: Navigate to a checkout screen
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen()));
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF328E6E,
                          ), // Button color
                          foregroundColor: Colors.white, // Text/icon color
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Checkout :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                '\$${state.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
