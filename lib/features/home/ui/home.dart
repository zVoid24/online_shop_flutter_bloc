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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeBloc.add(HomeInitialEvent());
    });

    _scrollController.addListener(() {
      final currentPosition = _scrollController.position.pixels;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (currentPosition >= maxExtent - 50 &&
          _homeBloc.state is! HomeLoadingMore) {
        _homeBloc.add(HomeLoadMoreEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _homeBloc.close();
    super.dispose();
  }

  // Category data (image paths and titles)
  final List<Map<String, String>> categories = [
    {'title': 'Fruits & Vegetables', 'image': 'assets/images/3652015.jpg'},
    {'title': 'Dairy & Eggs', 'image': 'assets/images/dairyandeggs.jpg'},
    {'title': 'Meat & Seafood', 'image': 'assets/images/meatandseafood.jpeg'},
    {'title': 'Snacks & Sweets', 'image': 'assets/images/snacksandsweets.jpg'},
    {'title': 'Beverages', 'image': 'assets/images/beverages.jpg'},
    {'title': 'Frozen Foods', 'image': 'assets/images/frozen_foods.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
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
                child: SpinKitSpinningLines(
                  color: Color(0xFF328E6E),
                  size: 50.0,
                ),
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
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _homeBloc.add(
                                    HomeCategoryTapEvent(
                                      categoryName: categories[index]['title']!,
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: Image.asset(
                                              categories[index]['image']!,
                                              fit: BoxFit.cover,
                                              width: 90,
                                              height: 90,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            left: 5,
                                            right: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2,
                                                    horizontal: 4,
                                                  ),

                                              child: Text(
                                                categories[index]['title']!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  height: 1.2,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(thickness: 1),
                      Expanded(
                        child:
                            successState.products.isEmpty &&
                                    successState.message != null
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(successState.message!),
                                      ElevatedButton(
                                        onPressed:
                                            () => _homeBloc.add(
                                              HomeInitialEvent(),
                                            ),
                                        child: const Text(
                                          'Back to All Products',
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : GridView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  controller: _scrollController,
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 200,
                                        mainAxisExtent: 220,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
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
                    ],
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
                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _homeBloc.add(
                                    HomeCategoryTapEvent(
                                      categoryName: categories[index]['title']!,
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: Image.asset(
                                              categories[index]['image']!,
                                              fit: BoxFit.cover,
                                              width: 90,
                                              height: 90,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            left: 5,
                                            right: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2,
                                                    horizontal: 4,
                                                  ),

                                              child: Text(
                                                categories[index]['title']!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  height: 1.2,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(thickness: 1),
                      Expanded(
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                mainAxisExtent: 220,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
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
                    ],
                  ),
                ),
              );
            case HomeFailure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${(state as HomeFailure).error}'),
                    ElevatedButton(
                      onPressed: () => _homeBloc.add(HomeInitialEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            default:
              return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}
