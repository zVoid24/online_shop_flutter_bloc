import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/database_calls.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeScreenBloc() : super(HomeScreenInitial()) {
    on<HomeScreenNavigateToSettingsEvent>(_onHomeScreenNavigateToSettingsEvent);
    on<HomeScreenNavigateToHelpEvent>(_onHomeScreenNavigateToHelpEvent);
    on<HomeScreenLogoutEvent>(_onHomeScreenLogoutEvent);
    on<HomeScreenInitialEvent>(_onHomeScreenInitialEvent);
    on<HomeScreenNavigateToOrderHistoryEvent>(
      _onHomeScreenNavigateToOrderHistoryEvent,
    );
  }

  FutureOr<void> _onHomeScreenLogoutEvent(
    HomeScreenLogoutEvent event,
    Emitter<HomeScreenState> emit,
  ) {
    Database().signOut();
  }

  FutureOr<void> _onHomeScreenNavigateToHelpEvent(
    HomeScreenNavigateToHelpEvent event,
    Emitter<HomeScreenState> emit,
  ) {
    emit(HomeScreenNavigateToHelpState());
  }

  FutureOr<void> _onHomeScreenNavigateToSettingsEvent(
    HomeScreenNavigateToSettingsEvent event,
    Emitter<HomeScreenState> emit,
  ) {
    emit(HomeScreenNavigateToSettingsState());
  }

  FutureOr<void> _onHomeScreenInitialEvent(
    HomeScreenInitialEvent event,
    Emitter<HomeScreenState> emit,
  ) {
    emit(HomeScreenLoadedState());
  }

  FutureOr<void> _onHomeScreenNavigateToOrderHistoryEvent(
    HomeScreenNavigateToOrderHistoryEvent event,
    Emitter<HomeScreenState> emit,
  ) {
    emit(HomeScreenNavigateToOrderHistoryState());
  }
}
