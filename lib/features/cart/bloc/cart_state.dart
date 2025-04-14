part of 'cart_bloc.dart';

@immutable
abstract class CartState {}

abstract class CartActionState extends CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartSuccess extends CartState {
  final List<Product> products;
  final double amount;
  CartSuccess({required this.products,required this.amount});
}

class CartFailure extends CartState {
  final String error;
  CartFailure({required this.error});
}

class EmptyCartState extends CartState {}

class CartProductRemovedState extends CartActionState {}

class OneProductDecreasedState extends CartActionState {
  final String name;
  OneProductDecreasedState({required this.name});
}

class CheckOutSuccess extends CartActionState{}

class CheckOutFailure extends CartActionState{}