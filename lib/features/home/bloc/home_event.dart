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

class HomeRefreshEvent extends HomeEvent {}

class HomeProductTapEvent extends HomeEvent {
  final Product product;
  HomeProductTapEvent({required this.product});
}

class HomeLoadMoreEvent extends HomeEvent {}

class HomeCategoryTapEvent extends HomeEvent {
  final String categoryName;
  HomeCategoryTapEvent({required this.categoryName});
}
