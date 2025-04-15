// lib/features/home/bloc/home_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/product_database.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/models/product.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ProductDatabase productDatabase = ProductDatabase();
  final List<Product> _products = [];
  String? _lastDocId;
  bool _hasMore = true;
  int _totalProducts = 0;
  String? _currentCategory; // Track current category

  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<HomeAddToCartEvent>(_onHomeAddToCartEvent);
    on<HomeRefreshEvent>(_onHomeRefreshEvent);
    on<HomeProductTapEvent>(_onHomeProductTapEvent);
    on<HomeLoadMoreEvent>(_onHomeLoadMoreEvent);
    on<HomeCategoryTapEvent>(_onHomeCategoryTapEvent);
  }

  Future<void> _onHomeInitialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      _products.clear();
      _lastDocId = null;
      _hasMore = true;
      _currentCategory = null;

      final initialProducts = await productDatabase.fetchProducts(limit: 10);
      _products.addAll(initialProducts);
      _lastDocId = initialProducts.isNotEmpty ? initialProducts.last.id : null;
      _totalProducts = await productDatabase.getProductCount();
      _hasMore = _products.length < _totalProducts;
      debugPrint(
        'Initial fetch: ${_products.length} products, total: $_totalProducts, hasMore: $_hasMore, lastDocId: $_lastDocId',
      );

      emit(
        HomeSuccess(
          products: List.from(_products),
          hasMore: _hasMore,
          selectedCategory: _currentCategory,
        ),
      );
    } catch (e) {
      emit(HomeFailure(error: 'Failed to load products: $e'));
    }
  }

  Future<void> _onHomeLoadMoreEvent(
    HomeLoadMoreEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      HomeLoadingMore(
        products: List.from(_products),
        selectedCategory: _currentCategory,
      ),
    );
    try {
      List<Product> moreProducts;
      if (_currentCategory != null) {
        moreProducts = await productDatabase.fetchProductsByCategory(
          category: _currentCategory!,
          lastDocId: _lastDocId,
          limit: 10,
        );
      } else {
        moreProducts = await productDatabase.fetchProducts(
          lastDocId: _lastDocId,
          limit: 10,
        );
      }

      if (moreProducts.isNotEmpty) {
        _products.addAll(moreProducts);
        _lastDocId = moreProducts.last.id;
      }
      _totalProducts =
          _currentCategory != null
              ? await productDatabase.getProductCountByCategory(
                _currentCategory!,
              )
              : await productDatabase.getProductCount();
      _hasMore = _products.length < _totalProducts;
      debugPrint(
        'Load more: ${moreProducts.length} products added, total: ${_products.length}, category: ${_currentCategory ?? "all"}, totalProducts: $_totalProducts, hasMore: $_hasMore, lastDocId: $_lastDocId',
      );

      emit(
        HomeSuccess(
          products: List.from(_products),
          hasMore: _hasMore,
          selectedCategory: _currentCategory,
        ),
      );
    } catch (e) {
      emit(HomeFailure(error: 'Failed to load more products: $e'));
    }
  }

  Future<void> _onHomeAddToCartEvent(
    HomeAddToCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    final user = await Database().getCurrentUser();
    if (user == null) {
      emit(HomeAddToCartStateFailure(error: 'User not logged in'));
      return;
    }
    final db = UserDatabase(uid: user.uid);
    try {
      await db.addToCart(productId: event.productId);
      emit(HomeAddToCartSuccessState());
    } catch (e) {
      emit(HomeAddToCartStateFailure(error: 'Failed to add to cart: $e'));
    }
  }

  Future<void> _onHomeRefreshEvent(
    HomeRefreshEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      _products.clear();
      _lastDocId = null;
      _hasMore = true;
      _currentCategory = null;

      final refreshedProducts = await productDatabase.fetchProducts(limit: 10);
      _products.addAll(refreshedProducts);
      _lastDocId =
          refreshedProducts.isNotEmpty ? refreshedProducts.last.id : null;
      _totalProducts = await productDatabase.getProductCount();
      _hasMore = _products.length < _totalProducts;

      emit(
        HomeSuccess(
          products: List.from(_products),
          hasMore: _hasMore,
          selectedCategory: _currentCategory,
        ),
      );
    } catch (e) {
      emit(HomeFailure(error: 'Failed to refresh products: $e'));
    }
  }

  Future<void> _onHomeProductTapEvent(
    HomeProductTapEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeNavigateToProductScreen(product: event.product));
  }

  Future<void> _onHomeCategoryTapEvent(
    HomeCategoryTapEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      _products.clear();
      _lastDocId = null;
      _hasMore = true;
      _currentCategory = event.categoryName;

      final categoryProducts = await productDatabase.fetchProductsByCategory(
        category: event.categoryName,
        limit: 10,
      );
      _products.addAll(categoryProducts);
      _lastDocId =
          categoryProducts.isNotEmpty ? categoryProducts.last.id : null;
      _totalProducts = await productDatabase.getProductCountByCategory(
        event.categoryName,
      );
      _hasMore = _products.length < _totalProducts;
      debugPrint(
        'Category fetch: ${event.categoryName}, loaded: ${_products.length}, total: $_totalProducts, hasMore: $_hasMore, lastDocId: $_lastDocId',
      );

      if (categoryProducts.isEmpty) {
        emit(
          HomeSuccess(
            products: [],
            hasMore: false,
            message: 'No products found for ${event.categoryName}',
            selectedCategory: _currentCategory,
          ),
        );
      } else {
        emit(
          HomeSuccess(
            products: List.from(_products),
            hasMore: _hasMore,
            selectedCategory: _currentCategory,
          ),
        );
      }
    } catch (e) {
      emit(HomeFailure(error: 'Failed to load category products: $e'));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
