import 'dart:async';
import 'package:online_shop/database/database_calls.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

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
    } catch (e) {
      emit(
        LoginFailure(
          error: 'Login failed: ${e.toString()}',
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
    if (state is LoginInitial || state is LoginFailure) {
      emit(LoginInitial(isPasswordObscured: !state.isPasswordObscured));
    } else if (state is LoginLoading) {
      emit(LoginLoading(isPasswordObscured: !state.isPasswordObscured));
    }
  }

  FutureOr<void> signUpButtonClicked(
    SignUpButtonClicked event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginNavigateToSignUp());
  }
}
