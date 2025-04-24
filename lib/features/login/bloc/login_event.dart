part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginInitialEvent extends LoginEvent {
  final bool isPasswordObscured;

  LoginInitialEvent({required this.isPasswordObscured});
}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  LoginButtonPressed({required this.email, required this.password});
}

class PasswordObscured extends LoginEvent {}

class SignUpButtonClicked extends LoginEvent {}