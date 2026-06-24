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

class ProfileRoomsLoadRequested extends ProfileEvent {
  const ProfileRoomsLoadRequested();
  @override
  List<Object?> get props => [];
}

class ProfileCreateRoomRequested extends ProfileEvent {
  final String nickname;
  final String country;
  final String currency;
  const ProfileCreateRoomRequested({
    required this.nickname,
    required this.country,
    required this.currency,
  });
  @override
  List<Object?> get props => [nickname, country, currency];
}
