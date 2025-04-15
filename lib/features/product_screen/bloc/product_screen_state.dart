part of 'product_screen_bloc.dart';

@immutable
abstract class ProductScreenState {}

abstract class ProductScreenActionState extends ProductScreenState {}

class ProductScreenInitial extends ProductScreenState {}

class ProductLoadedState extends ProductScreenState {
  final int units;
  ProductLoadedState({this.units = 0});
}

class ProductScreenNavigateToCartState extends ProductScreenActionState {}

class ProductScreeLoadingState extends ProductScreenState {}

class ProductScreenAddToCartSuccessState extends ProductScreenActionState {}

class ProductScreenAddToCartFailureState extends ProductScreenActionState {
  final String error;
  ProductScreenAddToCartFailureState({required this.error});
}
