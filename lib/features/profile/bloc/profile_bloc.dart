import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/database_calls.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/features/profile/cached_data/shared_prefs.dart';
import 'package:online_shop/models/user.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint('Checking SharedPreferences for user data');
      final cachedUser = await SharedPrefs.getUserData();
      if (cachedUser != null) {
        debugPrint('Found cached user: ${cachedUser.email}');
        emit(ProfileSuccess(user: cachedUser));
        return;
      }

      debugPrint('No cached data, fetching current user');
      final User? user = await Database().getCurrentUser();
      if (user == null) {
        debugPrint('No user is signed in');
        emit(ProfileFailure(error: 'Please sign in to view your profile'));
        return;
      }

      final String uid = user.uid;
      debugPrint('Fetching user data for UID: $uid');
      final userData = await UserDatabase(uid: uid).getUserData();
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
      emit(ProfileSuccess(
          user: UserData(uid: '', name: '', email: event.email)));
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
}