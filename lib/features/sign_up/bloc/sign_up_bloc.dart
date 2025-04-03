import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitial()) {
    on<SignUpButtonClicked>(signUpButtonClicked);
  }

  FutureOr<void> signUpButtonClicked(SignUpButtonClicked event, Emitter<SignUpState> emit) {
  }
}
