import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      drawer: buildDrawer(context),
      body: BlocConsumer<CartBloc, CartState>(
        bloc: _cartBloc,
        listenWhen: (previous, current) => current is CartActionState,
        buildWhen: (previous, current) => current is! CartActionState,
        listener: (context, state) {
          if (state is CartNavigateToHomeState) {
            Navigator.pop(context);
          } else if (state is CartProductRemovedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product removed from cart!'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CartLogoutState) {
            Navigator.pop(context); // Navigate back or to login screen
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case CartLoading:
              return const Center(child: CircularProgressIndicator());
            case CartSuccess:
              final products = (state as CartSuccess).products;
              return RefreshIndicator(
                onRefresh: () async {
                  _cartBloc.add(CartInitialEvent());
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
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
            case EmptyCartState:
              return const Center(child: Text('Your cart is empty'));
            case CartFailure:
              return Center(child: Text((state as CartFailure).error));
            default:
              return const Center(
                child: CircularProgressIndicator(),
              ); // Initial loading
          }
        },
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              _cartBloc.add(CartNavigateToHomeEvent());
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _cartBloc.add(CartLogoutEvent());
            },
          ),
        ],
      ),
    );
  }
}
