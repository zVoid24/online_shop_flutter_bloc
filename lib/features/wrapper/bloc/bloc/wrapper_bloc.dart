import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'wrapper_event.dart';
part 'wrapper_state.dart';

class WrapperBloc extends Bloc<WrapperEvent, WrapperState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WrapperBloc() : super(UnAuthenticated()) {
    _auth.authStateChanges().listen((User? user) {
      add(AuthStateChanged(user: user));
    });
    on<AuthStateChanged>((event, emit) {
      if (event.user != null) {
        emit(Authenticated(uid: event.user!.uid));
      } else {
        emit(UnAuthenticated());
      }
    });
  }
}
