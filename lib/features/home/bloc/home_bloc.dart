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
  StreamSubscription<List<Product>>? _productSubscription;
  final ProductDatabase productDatabase = ProductDatabase();

  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<HomeAddToCartEvent>(_onHomeAddToCartEvent);
    on<HomeNavigateToCartEvent>(_onHomeNavigateToCartEvent);
    on<HomeLogoutEvent>(_onHomeLogoutEvent);
    on<HomeProductsUpdated>(_onProductsUpdated);
    on<HomeRefreshEvent>(_onHomeRefreshEvent);
  }

  Future<void> _onHomeInitialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    await _productSubscription?.cancel();

    _productSubscription = productDatabase.fetchProductsStream().listen(
      (products) {
        add(HomeProductsUpdated(products));
      },
      onError: (e) {
        emit(HomeFailure(error: 'Stream error: $e'));
      },
    );
  }

  Future<void> _onProductsUpdated(
    HomeProductsUpdated event,
    Emitter<HomeState> emit,
  ) async {
    //emit(HomeLoading());
    if (event.products.isEmpty) {
      emit(HomeFailure(error: 'No products found'));
    } else {
      emit(HomeSuccess(products: event.products));
    }
  }

  Future<void> _onHomeAddToCartEvent(
    HomeAddToCartEvent event,
    Emitter<HomeState> emit,
  ) async {
    final user = await Database().getCurrentUser();
    final db = UserDatabase(uid: user!.uid);
    try {
      await db.addToCart(productId: event.productId);
      emit(HomeAddToCartSuccessState());
    } catch (e) {
      emit(HomeAddToCartStateFailure(error: 'Failed to add to cart: $e'));
    }
  }

  void _onHomeNavigateToCartEvent(
    HomeNavigateToCartEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeNavigateToCartState());
  }

  Future<void> _onHomeLogoutEvent(
    HomeLogoutEvent event,
    Emitter<HomeState> emit,
  ) async {
    final db = Database();
    await db.signOut();
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onHomeRefreshEvent(
    HomeRefreshEvent event,
    Emitter<HomeState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 3));
    await _productSubscription?.cancel();

    _productSubscription = productDatabase.fetchProductsStream().listen(
      (products) {
        add(HomeProductsUpdated(products));
      },
      onError: (e) {
        emit(HomeFailure(error: 'Stream error: $e'));
      },
    );
  }
}
