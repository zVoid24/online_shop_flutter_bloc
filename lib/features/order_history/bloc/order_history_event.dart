// lib/features/order_history/bloc/order_history_event.dart
part of 'order_history_bloc.dart';

@immutable
abstract class OrderHistoryEvent {}

class OrderHistoryFetchEvent extends OrderHistoryEvent {}