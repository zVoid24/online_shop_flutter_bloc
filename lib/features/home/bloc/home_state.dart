part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

abstract class HomeActionState extends HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<Product> products;
  HomeSuccess({required this.products});
}

class HomeFailure extends HomeState {
  final String error;
  HomeFailure({required this.error});
}

class HomeNavigateToCartState extends HomeActionState {}

class HomeAddToCartSuccessState extends HomeActionState {}

class HomeAddToCartStateFailure extends HomeActionState {
  final String error;
  HomeAddToCartStateFailure({required this.error});
}
