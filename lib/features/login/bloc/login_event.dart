part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  LoginButtonPressed({required this.email, required this.password});
}

class LoginInitialEvent extends LoginEvent {
  final bool isPasswordObscured;
  LoginInitialEvent({required this.isPasswordObscured});
}

class PasswordObscured extends LoginEvent {}

class SignUpButtonClicked extends LoginEvent {}
