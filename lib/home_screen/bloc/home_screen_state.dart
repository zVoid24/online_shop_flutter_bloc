part of 'home_screen_bloc.dart';

@immutable
abstract class HomeScreenState {}

abstract class HomeScreenActionState extends HomeScreenState {}

class HomeScreenInitial extends HomeScreenState {}

class HomeScreenNavigateToSettingsState extends HomeScreenActionState {}

class HomeScreenNavigateToHelpState extends HomeScreenActionState {}

class HomeScreenLoadedState extends HomeScreenState {}

class HomeScreenNavigateToOrderHistoryState extends HomeScreenActionState{}
