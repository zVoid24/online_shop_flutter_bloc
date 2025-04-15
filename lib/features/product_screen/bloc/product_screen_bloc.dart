import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/user_database.dart';

part 'product_screen_event.dart';
part 'product_screen_state.dart';

class ProductScreenBloc extends Bloc<ProductScreenEvent, ProductScreenState> {
  ProductScreenBloc() : super(ProductScreenInitial()) {
    on<ProductScreenInitialEvent>(_onProductScreenInitialEvent);
    on<ProductScreenAddButtonPressed>(_onProductScreenAddButtonPressed);
    on<ProductScreenRemoveButtonPressed>(_onProductScreenRemoveButtonPressed);
    on<ProductScreenAddToCartButtonPressed>(
      _onProductScreenAddToCartButtonPressed,
    );
  }

  FutureOr<void> _onProductScreenInitialEvent(
    ProductScreenInitialEvent event,
    Emitter<ProductScreenState> emit,
  ) {
    emit(ProductLoadedState());
  }

  FutureOr<void> _onProductScreenAddButtonPressed(
    ProductScreenAddButtonPressed event,
    Emitter<ProductScreenState> emit,
  ) {
    emit(ProductLoadedState(units: event.units + 1));
  }

  FutureOr<void> _onProductScreenRemoveButtonPressed(
    ProductScreenRemoveButtonPressed event,
    Emitter<ProductScreenState> emit,
  ) {
    emit(ProductLoadedState(units: event.units - 1));
  }

  FutureOr<void> _onProductScreenAddToCartButtonPressed(
    ProductScreenAddToCartButtonPressed event,
    Emitter<ProductScreenState> emit,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final db = UserDatabase(uid: user!.uid);
      await db.addToCart(productId: event.productId, quantity: event.quantity);
      emit(ProductScreenAddToCartSuccessState());
    } catch (e) {
      emit(ProductScreenAddToCartFailureState(error: e.toString()));
    }
  }
}
