import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
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
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case HomeLoading:
              return const Center(child: CircularProgressIndicator());
            case HomeSuccess:
              final products = (state as HomeSuccess).products;
              return Padding(
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
}
