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
  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<HomeAddToCartEvent>(_onHomeAddToCartEvent);
  }

  Future<void> _onHomeInitialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final db = ProductDatabase();
    try {
      final products = await db.fetchProducts();
      if (products.isNotEmpty) {
        emit(HomeSuccess(products: products));
      } else {
        emit(HomeFailure(error: 'No products found'));
      }
    } catch (e) {
      emit(HomeFailure(error: 'Failed to load products: $e'));
    }
  }

  FutureOr<void> _onHomeAddToCartEvent(
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
}
