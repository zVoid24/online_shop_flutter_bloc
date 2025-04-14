part of 'cart_bloc.dart';

@immutable
abstract class CartEvent {}

class CartInitialEvent extends CartEvent {}

class RemoveFromCartEvent extends CartEvent {
  final String productId;
  RemoveFromCartEvent({required this.productId});
}

class CartAddToCartEvent extends CartEvent {
  final String productId;
  CartAddToCartEvent({required this.productId});
}

class OneQuantityRemoveFromCartEvent extends CartEvent {
  final String productId;
  final String productName;
  OneQuantityRemoveFromCartEvent({
    required this.productId,
    required this.productName,
  });
}

class CheckOutButtonClicked extends CartEvent {
  final double amount;
  CheckOutButtonClicked({required this.amount});
}
