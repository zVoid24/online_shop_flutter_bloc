part of 'login_bloc.dart';

@immutable
abstract class LoginState {
  final bool isPasswordObscured;
  LoginState({required this.isPasswordObscured});
}

abstract class LoginActionState extends LoginState {
  LoginActionState({required super.isPasswordObscured});
}

class LoginInitial extends LoginState {
  LoginInitial({required super.isPasswordObscured});
}

class LoginLoading extends LoginState {
  LoginLoading({required super.isPasswordObscured});
}

class LoginFailure extends LoginActionState {
  final String error;
  LoginFailure({required this.error, required super.isPasswordObscured});
}

class LoginNavigateToSignUp extends LoginActionState {
  LoginNavigateToSignUp({required super.isPasswordObscured});
}

class LoginSuccess extends LoginActionState {
  LoginSuccess({required super.isPasswordObscured});
}