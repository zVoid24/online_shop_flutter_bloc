part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class LoadMoreProducts extends SearchEvent {
  final String query;
  LoadMoreProducts(this.query);
}

class SearchProductTapEvent extends SearchEvent {
  final Product product;
  SearchProductTapEvent({required this.product});
}
