// lib/features/order_history/bloc/order_history_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/models/order.dart';

part 'order_history_event.dart';
part 'order_history_state.dart';

class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  final UserDatabase userDatabase;

  OrderHistoryBloc({required this.userDatabase})
    : super(OrderHistoryInitial()) {
    on<OrderHistoryFetchEvent>(_onOrderHistoryFetchEvent);
  }

  Future<void> _onOrderHistoryFetchEvent(
    OrderHistoryFetchEvent event,
    Emitter<OrderHistoryState> emit,
  ) async {
    emit(OrderHistoryLoading());
    try {
      final orders = await userDatabase.fetchOrder();
      if (orders.isEmpty) {
        emit(OrderHistoryEmpty());
      } else {
        emit(OrderHistorySuccess(orders: orders));
      }
    } catch (e) {
      emit(OrderHistoryFailure(error: e.toString()));
    }
  }
}
