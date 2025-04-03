part of 'wrapper_bloc.dart';

@immutable
abstract class WrapperEvent {}

class AuthStateChanged extends WrapperEvent {
  final User? user;
  AuthStateChanged({required this.user});
}

class CheckAuthStatus extends WrapperEvent {}
