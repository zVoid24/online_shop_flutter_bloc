part of 'sign_up_bloc.dart';

@immutable
abstract class SignUpEvent {}

class SignUpButtonClicked extends SignUpEvent {
  final String name;
  final String email;
  final String password;
  SignUpButtonClicked({
    required this.name,
    required this.email,
    required this.password,
  });
}

class SignUpInitialEvent extends SignUpEvent {
  final bool isPasswordObscured;
  SignUpInitialEvent({required this.isPasswordObscured});
}

class SignUpObscuredButtonClicked extends SignUpEvent {}
