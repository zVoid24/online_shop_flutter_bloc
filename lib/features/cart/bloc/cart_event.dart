part of 'cart_bloc.dart';

@immutable
abstract class CartEvent {}

class CartInitialEvent extends CartEvent {}

class RemoveFromCartEvent extends CartEvent {
  final String productId;
  RemoveFromCartEvent({required this.productId});
}

class CartNavigateToHomeEvent extends CartEvent {}

class CartLogoutEvent extends CartEvent {}
