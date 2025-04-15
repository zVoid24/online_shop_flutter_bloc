part of 'home_bloc.dart';
@immutable
abstract class HomeState {}

abstract class HomeActionState extends HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadingMore extends HomeState {
  final List<Product> products;
  final String? selectedCategory; // New field
  HomeLoadingMore({
    required this.products,
    this.selectedCategory,
  });
}

class HomeSuccess extends HomeState {
  final List<Product> products;
  final bool hasMore;
  final String? message;
  final String? selectedCategory; // New field
  HomeSuccess({
    required this.products,
    required this.hasMore,
    this.message,
    this.selectedCategory,
  });
}

class HomeFailure extends HomeState {
  final String error;
  HomeFailure({required this.error});
}

class HomeAddToCartSuccessState extends HomeActionState {}

class HomeAddToCartStateFailure extends HomeActionState {
  final String error;
  HomeAddToCartStateFailure({required this.error});
}

class HomeNavigateToProductScreen extends HomeActionState {
  final Product product;
  HomeNavigateToProductScreen({required this.product});
}