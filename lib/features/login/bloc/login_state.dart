part of 'login_bloc.dart';

@immutable
abstract class LoginState {
  final bool isPasswordObscured;
  const LoginState({this.isPasswordObscured = true});
}

abstract class LoginActionState extends LoginState {
  const LoginActionState({super.isPasswordObscured});
}

class LoginInitial extends LoginState {
  const LoginInitial({required super.isPasswordObscured});
}

class LoginLoading extends LoginState {
  const LoginLoading({super.isPasswordObscured});
}

class LoginFailure extends LoginActionState {
  final String error;
  LoginFailure({required this.error, super.isPasswordObscured});
}

class LoginNavigateToSignUp extends LoginActionState {}
