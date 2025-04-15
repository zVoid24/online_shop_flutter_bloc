// lib/features/order_history/bloc/order_history_state.dart
part of 'order_history_bloc.dart';

@immutable
abstract class OrderHistoryState {}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistorySuccess extends OrderHistoryState {
  final List<Order> orders;

  OrderHistorySuccess({required this.orders});
}

class OrderHistoryEmpty extends OrderHistoryState {}

class OrderHistoryFailure extends OrderHistoryState {
  final String error;

  OrderHistoryFailure({required this.error});
}