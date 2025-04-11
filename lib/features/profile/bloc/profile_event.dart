part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class ProfileInitialEvent extends ProfileEvent {}

class ChangePasswordButtonPressedEvent extends ProfileEvent {}

class ChangePasswordEvent extends ProfileEvent {
  final String email;
  ChangePasswordEvent({required this.email});
}

class ProfileUpdateEvent extends ProfileEvent {
  final UserData updatedUser;
  ProfileUpdateEvent({required this.updatedUser});
}