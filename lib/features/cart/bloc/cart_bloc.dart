import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/models/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<CartInitialEvent>(_onCartInitialEvent);
    on<RemoveFromCartEvent>(_onRemoveFromCartEvent);
    on<CartNavigateToHomeEvent>(_onCartNavigateToHomeEvent);
    on<CartLogoutEvent>(_onCartLogoutEvent);
  }

  FutureOr<void> _onCartInitialEvent(
    CartInitialEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final currentUser = await Database().getCurrentUser();
    if (currentUser == null) {
      emit(CartFailure(error: 'User not logged in'));
      return;
    }
    final db = UserDatabase(uid: currentUser.uid);
    try {
      final products = await db.getCartItems();
      if (products.isNotEmpty) {
        emit(CartSuccess(products: products));
      } else {
        emit(EmptyCartState());
      }
    } catch (e) {
      emit(CartFailure(error: 'Failed to load cart items: $e'));
    }
  }

  FutureOr<void> _onRemoveFromCartEvent(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final currentUser = await Database().getCurrentUser();
    if (currentUser == null) {
      emit(CartFailure(error: 'User not logged in'));
      return;
    }
    final db = UserDatabase(uid: currentUser.uid);
    try {
      await db.removeFromCart(event.productId);
      emit(CartProductRemovedState()); // Action state for listener
      // Fetch updated cart items
      final updatedProducts = await db.getCartItems();
      if (updatedProducts.isNotEmpty) {
        emit(CartSuccess(products: updatedProducts));
      } else {
        emit(EmptyCartState());
      }
    } catch (e) {
      emit(CartFailure(error: 'Failed to remove item from cart: $e'));
    }
  }

  FutureOr<void> _onCartNavigateToHomeEvent(
    CartNavigateToHomeEvent event,
    Emitter<CartState> emit,
  ) {
    emit(CartNavigateToHomeState());
  }

  FutureOr<void> _onCartLogoutEvent(
    CartLogoutEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final db = Database();
    await db.signOut();
    emit(CartLogoutState());
  }
}
