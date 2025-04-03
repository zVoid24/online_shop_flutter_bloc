part of 'wrapper_bloc.dart';

@immutable
abstract class WrapperState {}

class UnAuthenticated extends WrapperState {}

class Authenticated extends WrapperState {
  final String uid;
  Authenticated({required this.uid});
}
