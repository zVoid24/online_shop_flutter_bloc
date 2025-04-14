import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:online_shop/database/product_database.dart';
import 'package:online_shop/models/product.dart';
import 'package:meta/meta.dart';
import 'dart:async';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductDatabase productDatabase; // Remove instantiation
  SearchBloc(this.productDatabase) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<SearchProductTapEvent>(_onSeachProductTapEvent);
  }

  final int _pageSize = 10; // Matches ProductDatabase limit
  List<Product> _currentResults = [];
  String? _lastDocId;

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      _currentResults = [];
      _lastDocId = null;
      emit(SearchLoaded([]));
      return;
    }

    emit(SearchLoading());
    try {
      final products = await productDatabase.searchProducts(
        searchQuery: query,
        limit: _pageSize,
      );

      _currentResults = products;
      _lastDocId = products.isNotEmpty ? products.last.id : null;
      final hasMore = products.length == _pageSize;

      emit(
        SearchLoaded(_currentResults, lastDocId: _lastDocId, hasMore: hasMore),
      );
    } catch (e) {
      emit(SearchError('Failed to search products: $e'));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoaded && !(state as SearchLoaded).hasMore) {
      return;
    }

    final query = event.query.trim();
    final currentState = state as SearchLoaded;

    emit(SearchLoading(isInitial: false));
    try {
      final products = await productDatabase.searchProducts(
        searchQuery: query,
        lastDocId: currentState.lastDocId,
        limit: _pageSize,
      );

      _currentResults.addAll(products);
      _lastDocId =
          products.isNotEmpty ? products.last.id : currentState.lastDocId;
      final hasMore = products.length == _pageSize;

      emit(
        SearchLoaded(_currentResults, lastDocId: _lastDocId, hasMore: hasMore),
      );
    } catch (e) {
      emit(SearchError('Failed to load more products: $e'));
    }
  }

  FutureOr<void> _onSeachProductTapEvent(
    SearchProductTapEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchProductTapState(product: event.product));
  }
}
