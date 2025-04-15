part of 'home_screen_bloc.dart';

@immutable
abstract class HomeScreenEvent {}

class HomeScreenNavigateToSettingsEvent extends HomeScreenEvent {}

class HomeScreenNavigateToHelpEvent extends HomeScreenEvent {}

class HomeScreenLogoutEvent extends HomeScreenEvent {}

class HomeScreenInitialEvent extends HomeScreenEvent {}

class HomeScreenNavigateToOrderHistoryEvent extends HomeScreenEvent{}
