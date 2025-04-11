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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _homeBloc.add(HomeInitialEvent());
    _scrollController.addListener(() {
      final currentPosition = _scrollController.position.pixels;
      final maxExtent = _scrollController.position.maxScrollExtent;
      print('Scroll position: $currentPosition, maxExtent: $maxExtent');
      if (currentPosition >= maxExtent - 50 &&
          _homeBloc.state is! HomeLoadingMore) {
        print('Triggering load more');
        debugPrint("Last item");
        _homeBloc.add(HomeLoadMoreEvent());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _homeBloc.close();
    super.dispose();
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
        print('Building state: ${state.runtimeType}');
        switch (state.runtimeType) {
          case HomeLoading:
            return const Center(
              child: SpinKitSpinningLines(color: Color(0xFF328E6E), size: 50.0),
            );
          case HomeSuccess:
            final successState = state as HomeSuccess;
            return RefreshIndicator(
              onRefresh: () async {
                _homeBloc.add(HomeRefreshEvent());
              },
              color: const Color(0xFF328E6E),
              backgroundColor: const Color(0xFFEAECCC),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount:
                      successState.products.length +
                      (successState.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == successState.products.length &&
                        successState.hasMore) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SpinKitSpinningLines(
                            color: Color(0xFF328E6E),
                            size: 30.0,
                          ),
                        ),
                      );
                    }
                    return ProductTile(
                      homeBloc: _homeBloc,
                      product: successState.products[index],
                    );
                  },
                ),
              ),
            );
          case HomeLoadingMore:
            final loadingMoreState = state as HomeLoadingMore;
            return RefreshIndicator(
              onRefresh: () async {
                _homeBloc.add(HomeRefreshEvent());
              },
              color: const Color(0xFF328E6E),
              backgroundColor: const Color(0xFFEAECCC),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: loadingMoreState.products.length + 1,
                  itemBuilder: (context, index) {
                    if (index == loadingMoreState.products.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SpinKitSpinningLines(
                            color: Color(0xFF328E6E),
                            size: 30.0,
                          ),
                        ),
                      );
                    }
                    return ProductTile(
                      homeBloc: _homeBloc,
                      product: loadingMoreState.products[index],
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
