import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/database_calls.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial(isPasswordObscured: true)) {
    on<LoginButtonPressed>(loginButtonPressed);
    on<LoginInitialEvent>(loginInitialEvent);
    on<PasswordObscured>(passwordObscured);
    on<SignUpButtonClicked>(signUpButtonClicked);
  }

  FutureOr<void> loginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    final Database db = Database();
    emit(LoginLoading(isPasswordObscured: state.isPasswordObscured));
    try {
      await db.signInWithEmail(email: event.email, password: event.password);
      emit(LoginSuccess(isPasswordObscured: state.isPasswordObscured));
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format';
      } else if (e.toString().contains('user-not-found')) {
        errorMessage = 'User not found';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many attempts, try again later';
      }
      emit(
        LoginFailure(
          error: errorMessage,
          isPasswordObscured: state.isPasswordObscured,
        ),
      );
    }
  }

  FutureOr<void> loginInitialEvent(
    LoginInitialEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitial(isPasswordObscured: event.isPasswordObscured));
  }

  FutureOr<void> passwordObscured(
    PasswordObscured event,
    Emitter<LoginState> emit,
  ) {
    if (state is LoginInitial) {
      emit(LoginInitial(isPasswordObscured: !state.isPasswordObscured));
    } else if (state is LoginFailure) {
      emit(LoginFailure(
        error: (state as LoginFailure).error,
        isPasswordObscured: !state.isPasswordObscured,
      ));
    } else if (state is LoginLoading) {
      emit(LoginLoading(isPasswordObscured: !state.isPasswordObscured));
    }
  }

  FutureOr<void> signUpButtonClicked(
    SignUpButtonClicked event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginNavigateToSignUp(isPasswordObscured: state.isPasswordObscured));
  }
}