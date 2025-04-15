// lib/features/profile/bloc/profile_state.dart
part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

abstract class ProfileActionState extends ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final UserData user;

  ProfileSuccess({required this.user});
}

class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure({required this.error});
}

class ProfilePasswordChangeButtonPressed extends ProfileActionState {}

class ProfileChangeEmailButtonPressedState extends ProfileActionState {}

class ProfileVerificationSent extends ProfileActionState {
  final String newEmail;

  ProfileVerificationSent({required this.newEmail});
}

class ProfileUpdateSuccess extends ProfileActionState {}

class ProfileUpdateFailure extends ProfileActionState {
  final String error;

  ProfileUpdateFailure({required this.error});
}