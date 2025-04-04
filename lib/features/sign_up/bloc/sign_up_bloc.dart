import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/user_database.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(const SignUpInitial(isPasswordObscured: true)) {
    on<SignUpInitialEvent>(_onSignUpInitialEvent);
    on<SignUpButtonClicked>(_onSignUpButtonClicked);
    on<SignUpObscuredButtonClicked>(_onSignUpObscuredButtonClicked);
  }

  FutureOr<void> _onSignUpInitialEvent(
    SignUpInitialEvent event,
    Emitter<SignUpState> emit,
  ) {
    emit(SignUpInitial(isPasswordObscured: event.isPasswordObscured));
  }

  FutureOr<void> _onSignUpButtonClicked(
    SignUpButtonClicked event,
    Emitter<SignUpState> emit,
  ) async {
    // Validation checks
    if (event.name.trim().isEmpty) {
      emit(
        SignUpFailure(
          error: 'Please enter your full name',
          isPasswordObscured: state.isPasswordObscured,
        ),
      );
      return;
    }
    if (event.email.trim().isEmpty) {
      emit(
        SignUpFailure(
          error: 'Please enter your email',
          isPasswordObscured: state.isPasswordObscured,
        ),
      );
      return;
    }
    if (event.password.trim().isEmpty) {
      emit(
        SignUpFailure(
          error: 'Please enter a password',
          isPasswordObscured: state.isPasswordObscured,
        ),
      );
      return;
    }

    final db = Database();
    emit(SignUpLoading(isPasswordObscured: state.isPasswordObscured));
    try {
      final user = await db.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        final userDatabase = UserDatabase(uid: user.uid);
        await userDatabase.createUserData(name: event.name, email: event.email);
        emit(SignUpSuccess());
      } else {
        emit(
          SignUpFailure(
            error: 'Sign-up succeeded but no user returned.',
            isPasswordObscured: state.isPasswordObscured,
          ),
        );
      }
    } catch (e) {
      emit(
        SignUpFailure(
          error: e.toString(), // Now shows user-friendly messages from Database
          isPasswordObscured: state.isPasswordObscured,
        ),
      );
    }
  }

  FutureOr<void> _onSignUpObscuredButtonClicked(
    SignUpObscuredButtonClicked event,
    Emitter<SignUpState> emit,
  ) {
    emit(SignUpInitial(isPasswordObscured: !state.isPasswordObscured));
  }
}
