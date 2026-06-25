part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  photoUploading,
  photoUpdated,
  deleting,
  deleted,
  error,
}

enum RoomsStatus { initial, loading, loaded, creating, created, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileModel? profile;
  final String? errorMessage;
  final RoomsStatus roomsStatus;
  final List<ProfileModel> rooms;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.roomsStatus = RoomsStatus.initial,
    this.rooms = const [],
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? errorMessage,
    RoomsStatus? roomsStatus,
    List<ProfileModel>? rooms,
  }) =>
      ProfileState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        errorMessage: errorMessage ?? this.errorMessage,
        roomsStatus: roomsStatus ?? this.roomsStatus,
        rooms: rooms ?? this.rooms,
      );

  @override
  List<Object?> get props =>
      [status, profile, errorMessage, roomsStatus, rooms];
}
