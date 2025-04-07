import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/models/user.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileInitialEvent>(_onProfileInitialEvent);
    on<ChangePasswordEvent>(_onChangePasswordEvent);
    on<ChangePasswordButtonPressedEvent>(_onChangePasswordButtonPressedEvent);
  }

  FutureOr<void> _onProfileInitialEvent(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final User? user = await Database().getCurrentUser();
      final String uid = user?.uid ?? '';
      final userData = await UserDatabase(uid: uid).getUserData();
      if (userData != null) {
        emit(ProfileSuccess(user: userData));
      } else {
        emit(ProfileFailure(error: 'User data is null'));
      }
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  FutureOr<void> _onChangePasswordEvent(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final Database db = Database();
      await db.resetPassword(event.email);
      db.signOut();
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  FutureOr<void> _onChangePasswordButtonPressedEvent(
    ChangePasswordButtonPressedEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(ProfilePasswordChangeButtonPressed());
  }
}
