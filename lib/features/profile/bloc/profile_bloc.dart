// lib/features/profile/bloc/profile_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/features/profile/cached_data/shared_prefs.dart';
import 'package:online_shop/models/user.dart';
import 'package:flutter/foundation.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserDatabase userDatabase;

  ProfileBloc({required this.userDatabase}) : super(ProfileInitial()) {
    on<ProfileInitialEvent>(_onProfileInitialEvent);
    on<ChangePasswordEvent>(_onChangePasswordEvent);
    on<ChangePasswordButtonPressedEvent>(_onChangePasswordButtonPressedEvent);
    on<ProfileChangeEmailEvent>(_onProfileChangeEmailEvent);
    on<ProfileChangeEmailButtonPressedEvent>(
      _onProfileChangeEmailButtonPressedEvent,
    );
    on<ProfileSyncEmailEvent>(_onProfileSyncEmailEvent);
  }

  FutureOr<void> _onProfileInitialEvent(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      debugPrint('Checking SharedPreferences for user data');
      final cachedUser = await SharedPrefs.getUserData();
      if (cachedUser != null) {
        debugPrint('Found cached user: ${cachedUser.email}');
        emit(ProfileSuccess(user: cachedUser));
        return;
      }

      debugPrint('Fetching user data for UID: ${userDatabase.uid}');
      final userData = await userDatabase.getUserData();
      if (userData != null) {
        debugPrint('User data fetched: ${userData.email}');
        await SharedPrefs.saveUserData(userData);
        emit(ProfileSuccess(user: userData));
      } else {
        debugPrint('User data is null');
        emit(ProfileFailure(error: 'User data not found'));
      }
    } catch (e) {
      debugPrint('Error in _onProfileInitialEvent: $e');
      emit(ProfileFailure(error: 'Failed to load profile: $e'));
    }
  }

  FutureOr<void> _onChangePasswordEvent(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      debugPrint('Resetting password for email: ${event.email}');
      final Database db = Database();
      await db.resetPassword(event.email);
      debugPrint('Password reset email sent, signing out');
      await db.signOut();
      await SharedPrefs.clearUserData();
      debugPrint('Cache cleared');
      emit(
        ProfileSuccess(user: UserData(uid: '', name: '', email: event.email)),
      );
    } catch (e) {
      debugPrint('Error in _onChangePasswordEvent: $e');
      emit(ProfileFailure(error: 'Failed to reset password: $e'));
    }
  }

  FutureOr<void> _onChangePasswordButtonPressedEvent(
    ChangePasswordButtonPressedEvent event,
    Emitter<ProfileState> emit,
  ) {
    debugPrint('Change password button pressed');
    emit(ProfilePasswordChangeButtonPressed());
  }

  FutureOr<void> _onProfileChangeEmailEvent(
    ProfileChangeEmailEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final Database user = Database();
      if (user == null) {
        throw Exception('No user is signed in');
      }

      await user.updateMail(email: event.email, password: event.password);
      debugPrint('Verification email sent to ${event.email}');
      add(ProfileSyncEmailEvent(newEmail: event.email));
      user.signOut();
    } catch (e) {
      debugPrint('Error in _onProfileChangeEmailEvent: $e');
      emit(ProfileUpdateFailure(error: e.toString()));
    }
  }

  FutureOr<void> _onProfileChangeEmailButtonPressedEvent(
    ProfileChangeEmailButtonPressedEvent event,
    Emitter<ProfileState> emit,
  ) {
    debugPrint('Change email button pressed');
    emit(ProfileChangeEmailButtonPressedState());
  }

  FutureOr<void> _onProfileSyncEmailEvent(
    ProfileSyncEmailEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await userDatabase.syncEmailAfterVerification(event.newEmail);
      debugPrint('Firestore synced with ${event.newEmail}');
      final userData = await userDatabase.getUserData();
      if (userData != null) {
        await SharedPrefs.saveUserData(userData);
        emit(ProfileSuccess(user: userData));
      } else {
        emit(ProfileFailure(error: 'User data not found after sync'));
      }
    } catch (e) {
      debugPrint('Error in _onProfileSyncEmailEvent: $e');
      emit(ProfileUpdateFailure(error: 'Failed to sync email: $e'));
    }
  }
}
