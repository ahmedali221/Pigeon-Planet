part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ProfileStarted extends ProfileEvent {
  final String profileType; // 'Seller' | 'Customer'
  const ProfileStarted(this.profileType);
  @override
  List<Object?> get props => [profileType];
}

class ProfileUpdateRequested extends ProfileEvent {
  final ProfileModel profile;
  const ProfileUpdateRequested(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileDeleteRequested extends ProfileEvent {
  const ProfileDeleteRequested();
  @override
  List<Object?> get props => [];
}
