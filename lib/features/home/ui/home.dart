import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/features/cart/ui/cart.dart';
import 'package:online_shop/features/home/bloc/home_bloc.dart';
import 'package:online_shop/features/home/ui/product_tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeBloc _homeBloc = HomeBloc();

  @override
  void initState() {
    _homeBloc.add(HomeInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF328E6E),
      ),
      drawer: buildDrawer(context),
      backgroundColor: Color(0xFFEAECCC),
      body: BlocConsumer<HomeBloc, HomeState>(
        bloc: _homeBloc,
        listenWhen: (previous, current) => current is HomeActionState,
        buildWhen: (previous, current) => current is! HomeActionState,
        listener: (context, state) {
          if (state is HomeAddToCartSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product added to cart!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is HomeAddToCartStateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is HomeNavigateToCartState) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Cart()),
            );
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case HomeLoading:
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF328E6E)),
              );
            case HomeSuccess:
              final products = (state as HomeSuccess).products;
              return RefreshIndicator(
                onRefresh: () async {
                  _homeBloc.add(HomeRefreshEvent());
                },
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductTile(
                        homeBloc: _homeBloc,
                        product: products[index],
                      );
                    },
                  ),
                ),
              );
            case HomeFailure:
              return Center(child: Text((state as HomeFailure).error));
            default:
              return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: const Color(0xFFEAECCC)),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF328E6E)),
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                _homeBloc.add(HomeNavigateToCartEvent());
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _homeBloc.add(HomeLogoutEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
