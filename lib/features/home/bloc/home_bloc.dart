import 'dart:async';
import 'package:bloc/bloc.dart';
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

  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<HomeAddToCartEvent>(_onHomeAddToCartEvent);
    on<HomeLogoutEvent>(_onHomeLogoutEvent);
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

      final initialProducts = await productDatabase.fetchProducts(limit: 10);
      _products.addAll(initialProducts);
      _lastDocId = initialProducts.isNotEmpty ? initialProducts.last.id : null;
      _totalProducts = await productDatabase.getProductCount();
      _hasMore = _products.length < _totalProducts;
      print(
        'Initial fetch: ${_products.length} products, total: $_totalProducts, hasMore: $_hasMore, lastDocId: $_lastDocId',
      );

      emit(HomeSuccess(products: List.from(_products), hasMore: _hasMore));
    } catch (e) {
      emit(HomeFailure(error: 'Failed to load products: $e'));
    }
  }

  Future<void> _onHomeLoadMoreEvent(
    HomeLoadMoreEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (!_hasMore) {
      print('Checking for new products...');
      final newTotal = await productDatabase.getProductCount();
      if (newTotal > _totalProducts) {
        _totalProducts = newTotal;
        _hasMore = true;
        print('New products detected, total now: $_totalProducts');
      } else {
        print('No more products to load');
        return;
      }
    }

    emit(HomeLoadingMore(products: List.from(_products)));
    try {
      final moreProducts = await productDatabase.fetchProducts(
        lastDocId: _lastDocId,
        limit: 10,
      );
      _products.addAll(moreProducts);
      _lastDocId = moreProducts.isNotEmpty ? moreProducts.last.id : null;
      _hasMore = _products.length < _totalProducts;
      print(
        'Load more: ${moreProducts.length} products added, total: ${_products.length}, hasMore: $_hasMore',
      );

      emit(HomeSuccess(products: List.from(_products), hasMore: _hasMore));
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

  Future<void> _onHomeLogoutEvent(
    HomeLogoutEvent event,
    Emitter<HomeState> emit,
  ) async {
    final db = Database();
    await db.signOut();
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

      final refreshedProducts = await productDatabase.fetchProducts(limit: 10);
      _products.addAll(refreshedProducts);
      _lastDocId =
          refreshedProducts.isNotEmpty ? refreshedProducts.last.id : null;
      _totalProducts = await productDatabase.getProductCount();
      _hasMore = _products.length < _totalProducts;

      emit(HomeSuccess(products: List.from(_products), hasMore: _hasMore));
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

  @override
  Future<void> close() {
    return super.close();
  }

  FutureOr<void> _onHomeCategoryTapEvent(
    HomeCategoryTapEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeCategoryTapState(categoryName: event.categoryName));
  }
}
