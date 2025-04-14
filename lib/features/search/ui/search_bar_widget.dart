import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_shop/features/home/bloc/home_bloc.dart';
import 'package:online_shop/features/product_screen/ui/product.dart';
import 'package:online_shop/features/search/bloc/search_bloc.dart';
import 'package:online_shop/models/product.dart';

class SearchBody extends StatefulWidget {
  final SearchBloc searchBloc;
  const SearchBody({super.key, required this.searchBloc});

  @override
  _SearchBodyState createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (_lastQuery.isNotEmpty) {
        widget.searchBloc.add(LoadMoreProducts(_lastQuery));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              //hintStyle: TextStyle(color: Color(0xFF328E6E)),
              prefixIcon: const Icon(
                //color: Color(0xFF328E6E),
                Icons.search_sharp,
              ),

              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _lastQuery = '';
                          widget.searchBloc.add(SearchQueryChanged(''));
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF328E6E)),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF328E6E)),
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Color(0xFF328E6E).withOpacity(0.1),
              hoverColor: Color(0xFF328E6E),
            ),
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (_lastQuery != value) {
                  // Avoid duplicate events
                  _lastQuery = value;
                  widget.searchBloc.add(SearchQueryChanged(value));
                }
              });
            },
          ),
        ),
        Expanded(
          child: BlocConsumer<SearchBloc, SearchState>(
            bloc: widget.searchBloc,
            listener: (context, state) {
              if (state is SearchError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is SearchProductTapState) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(product: state.product),
                  ),
                );
              }
            },
            builder: (context, state) {
              // Immediately show initial state if query is empty
              if (_searchController.text.isEmpty && state is! SearchLoading) {
                return const Center(child: Text('Start searching...'));
              }

              switch (state.runtimeType) {
                case SearchInitial:
                  return const Center(child: Text('Start searching...'));
                case SearchLoading:
                  final loadingState = state as SearchLoading;
                  if (loadingState.isInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Preserve previous results during pagination
                  if (state is SearchLoaded) {
                    final loadedState = state as SearchLoaded;
                    return _buildProductList(
                      context,
                      loadedState.results,
                      loadedState.hasMore,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                case SearchLoaded:
                  final loadedState = state as SearchLoaded;
                  final results = loadedState.results;
                  if (results.isEmpty && _searchController.text.isNotEmpty) {
                    return const Center(child: Text('No products found'));
                  }
                  return _buildProductList(
                    context,
                    results,
                    loadedState.hasMore,
                  );
                case SearchError:
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${(state as SearchError).message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_lastQuery.isNotEmpty) {
                              widget.searchBloc.add(
                                SearchQueryChanged(_lastQuery),
                              );
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(
    BuildContext context,
    List<Product> results,
    bool hasMore,
  ) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: results.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length && hasMore) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final product = results[index];
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading:
                  product.imageUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Hero(
                          tag: 'product_image_${product.id}',
                          child: Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                          ),
                        ),
                      )
                      : const Icon(Icons.image_not_supported, size: 50),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onTap: () {
                // Navigate to product details or handle tap
                widget.searchBloc.add(SearchProductTapEvent(product: product));
              },
            ),
          ),
        );
      },
    );
  }
}
