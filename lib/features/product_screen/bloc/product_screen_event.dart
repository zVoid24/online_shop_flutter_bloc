part of 'product_screen_bloc.dart';

@immutable
abstract class ProductScreenEvent {}

class ProductScreenInitialEvent extends ProductScreenEvent {}

class ProductScreenAddButtonPressed extends ProductScreenEvent {
  final int units;
  ProductScreenAddButtonPressed({required this.units});
}

class ProductScreenRemoveButtonPressed extends ProductScreenEvent {
  final int units;
  ProductScreenRemoveButtonPressed({required this.units});
}

class ProductScreenAddToCartButtonPressed extends ProductScreenEvent {
  final String productId;
  final int quantity;
  ProductScreenAddToCartButtonPressed({required this.productId,required this.quantity});
}

class ProductScreenNavigateToCart extends ProductScreenEvent {}
