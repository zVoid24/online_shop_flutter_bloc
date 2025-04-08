import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/features/home/bloc/home_bloc.dart';
import 'package:online_shop/features/home/ui/product_tile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:online_shop/features/product_screen/ui/product.dart';

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
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: _homeBloc,
      listenWhen: (previous, current) => current is HomeActionState,
      buildWhen: (previous, current) => current is! HomeActionState,
      listener: (context, state) {
        if (state is HomeAddToCartSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added to cart!'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is HomeAddToCartStateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is HomeNavigateToProductScreen) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(product: state.product),
            ),
          );
        }
      },
      builder: (context, state) {
        switch (state.runtimeType) {
          case HomeLoading:
            return const Center(
              child: SpinKitSpinningLines(color: Color(0xFF328E6E), size: 50.0),
            );
          case HomeSuccess:
            return RefreshIndicator(
              onRefresh: () async {
                _homeBloc.add(HomeRefreshEvent());
              },
              color: const Color(0xFF328E6E),
              backgroundColor: const Color(0xFFEAECCC),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: ListView.builder(
                  itemCount: (state as HomeSuccess).products.length,
                  itemBuilder: (context, index) {
                    return ProductTile(
                      homeBloc: _homeBloc,
                      product: (state).products[index],
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
    );
  }
}
