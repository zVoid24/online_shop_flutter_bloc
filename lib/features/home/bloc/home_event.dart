part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeInitialEvent extends HomeEvent {}

class HomeNavigateToCartEvent extends HomeEvent {}

class HomeAddToCartEvent extends HomeEvent {
  final String productId;
  HomeAddToCartEvent({required this.productId});
}

class HomeLogoutEvent extends HomeEvent {}

class HomeProductsUpdated extends HomeEvent {
  final List<Product> products;
  HomeProductsUpdated(this.products);
}

class HomeRefreshEvent extends HomeEvent {}
