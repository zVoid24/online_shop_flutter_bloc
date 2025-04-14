part of 'help_bloc.dart';

@immutable
abstract class HelpState {}

abstract class HelpActionState extends HelpState {}

class HelpInitial extends HelpState {}

class HelpLoadedState extends HelpState {
  final List<Map<String, dynamic>> message;
  HelpLoadedState({required this.message});
}

class HelpErrorState extends HelpState {
  final String error;
  HelpErrorState({required this.error});
}

class HelpLoadingState extends HelpState {}

class HelpSentSuccessState extends HelpActionState {}

class HelpSentFailureState extends HelpActionState {
  final String error;
  HelpSentFailureState({required this.error});
}
