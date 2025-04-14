import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/sslcommerz.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/models/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<CartInitialEvent>(_onCartInitialEvent);
    on<RemoveFromCartEvent>(_onRemoveFromCartEvent);
    on<CartAddToCartEvent>(_onCartAddToCartEvent);
    on<OneQuantityRemoveFromCartEvent>(_onOneQuantityRemoveFromCartEvent);
    on<CheckOutButtonClicked>(_onCheckOutButtonClicked);
  }

  Future<void> _onCartInitialEvent(
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
      final amount = await db.fetchCheckOutAmount();
      if (products.isNotEmpty) {
        emit(CartSuccess(products: products, amount: amount));
      } else {
        emit(EmptyCartState());
      }
    } catch (e) {
      emit(CartFailure(error: 'Failed to load cart items: $e'));
    }
  }

  Future<void> _onRemoveFromCartEvent(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentUser = await Database().getCurrentUser();
    if (currentUser == null) {
      emit(CartFailure(error: 'User not logged in'));
      return;
    }
    final db = UserDatabase(uid: currentUser.uid);
    try {
      await db.removeFromCart(event.productId);
      emit(CartProductRemovedState()); // Action state for listener
      final updatedProducts = await db.getCartItems();
      final updatedAmount = await db.fetchCheckOutAmount();
      if (updatedProducts.isNotEmpty) {
        emit(CartSuccess(products: updatedProducts, amount: updatedAmount));
      } else {
        emit(EmptyCartState());
      }
    } catch (e) {
      emit(CartFailure(error: 'Failed to remove item from cart: $e'));
    }
  }

  Future<void> _onCartAddToCartEvent(
    CartAddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentUser = await Database().getCurrentUser();
    if (currentUser == null) {
      emit(CartFailure(error: 'User not logged in'));
      return;
    }
    final db = UserDatabase(uid: currentUser.uid);
    try {
      await db.addToCart(productId: event.productId);
      final products = await db.getCartItems();
      final updatedAmount = await db.fetchCheckOutAmount();
      if (products.isNotEmpty) {
        emit(CartSuccess(products: products, amount: updatedAmount));
      } else {
        emit(EmptyCartState());
      }
    } catch (e) {
      emit(CartFailure(error: 'Failed to add to cart: $e'));
    }
  }

  Future<void> _onOneQuantityRemoveFromCartEvent(
    OneQuantityRemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentUser = await Database().getCurrentUser();
    if (currentUser == null) {
      emit(CartFailure(error: 'User not logged in'));
      return;
    }
    final db = UserDatabase(uid: currentUser.uid);
    try {
      await db.oneItemRemoveFromCart(event.productId);
      final products = await db.getCartItems();
      final updatedAmount = await db.fetchCheckOutAmount();
      if (products.isNotEmpty) {
        emit(CartSuccess(products: products, amount: updatedAmount));
      } else {
        emit(EmptyCartState());
      }
      emit(OneProductDecreasedState(name: event.productName));
    } catch (e) {
      emit(CartFailure(error: 'Failed to remove one item from cart: $e'));
    }
  }

  FutureOr<void> _onCheckOutButtonClicked(
    CheckOutButtonClicked event,
    Emitter<CartState> emit,
  ) async {
    final SSLCommerzService paymentService = SSLCommerzService(
      amount: event.amount,
    );
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(CartFailure(error: 'User not logged in'));
      return;
    }
    final UserDatabase db = UserDatabase(uid: uid);
    final product = await db.getCartItems();
    bool success = await paymentService.initiatePayment();
    if (success) {
      await db.confirmOrder(product, event.amount);
      await db.deleteCartSubcollection();
      //emit(CartInitial());
      emit(CheckOutSuccess());
    } else {
      emit(CheckOutFailure());
    }
  }
}
