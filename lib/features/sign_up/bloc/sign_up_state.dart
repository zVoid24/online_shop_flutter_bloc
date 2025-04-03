part of 'sign_up_bloc.dart';

@immutable
abstract class SignUpState {
  final bool isPasswordObscured;
  const SignUpState({this.isPasswordObscured = true});
}

abstract class SignUpActionState extends SignUpState {}

class SignUpInitial extends SignUpState {
  const SignUpInitial({super.isPasswordObscured});
}

class SignUpLoading extends SignUpState {
  const SignUpLoading({super.isPasswordObscured});
}

class SignUpSuccess extends SignUpActionState {}

class SignUpFailure extends SignUpState {
  final String error;
  const SignUpFailure({required this.error, super.isPasswordObscured});
}
