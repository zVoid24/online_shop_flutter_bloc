part of 'cart_bloc.dart';

@immutable
abstract class CartState {}

abstract class CartActionState extends CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartSuccess extends CartState {
  final List<Product> products;
  CartSuccess({required this.products});
}

class CartFailure extends CartState {
  final String error;
  CartFailure({required this.error});
}

class EmptyCartState extends CartState {}

class CartNavigateToHomeState extends CartActionState {}

class CartProductRemovedState extends CartActionState {}

class CartLogoutState extends CartActionState {}
