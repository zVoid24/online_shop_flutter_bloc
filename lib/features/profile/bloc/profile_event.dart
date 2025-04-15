// lib/features/profile/bloc/profile_event.dart
part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class ProfileInitialEvent extends ProfileEvent {}

class ChangePasswordEvent extends ProfileEvent {
  final String email;

  ChangePasswordEvent({required this.email});
}

class ChangePasswordButtonPressedEvent extends ProfileEvent {}

class ProfileChangeEmailEvent extends ProfileEvent {
  final String email;
  final String password;

  ProfileChangeEmailEvent({required this.email, required this.password});
}

class ProfileChangeEmailButtonPressedEvent extends ProfileEvent {}

class ProfileSyncEmailEvent extends ProfileEvent {
  final String newEmail;

  ProfileSyncEmailEvent({required this.newEmail});
}