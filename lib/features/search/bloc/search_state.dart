part of 'search_bloc.dart';

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final bool isInitial; // True for initial search, false for pagination
  SearchLoading({this.isInitial = true});
}

class SearchLoaded extends SearchState {
  final List<Product> results;
  final String? lastDocId;
  final bool hasMore;
  SearchLoaded(this.results, {this.lastDocId, this.hasMore = true});
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchProductTapState extends SearchState {
  final Product product;
  SearchProductTapState({required this.product});
}
