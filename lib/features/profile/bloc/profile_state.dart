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

class ProfilePasswordChangeButtonPressed extends ProfileActionState {}

class ProfileFailure extends ProfileState {
  final String error;
  ProfileFailure({required this.error});
}
