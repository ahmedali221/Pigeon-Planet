import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/profile_model.dart';
import '../model/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileDeleteRequested>(_onDeleteRequested);
    on<ProfileRoomsLoadRequested>(_onRoomsLoad);
    on<ProfileCreateRoomRequested>(_onCreateRoom);
  }

  Future<void> _onStarted(
      ProfileStarted event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _repository.getProfile(event.profileType);
    result.fold(
      (f) => emit(state.copyWith(
          status: ProfileStatus.error, errorMessage: f.message)),
      (profile) =>
          emit(state.copyWith(status: ProfileStatus.loaded, profile: profile)),
    );
  }

  Future<void> _onUpdateRequested(
      ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    final result = await _repository.updateProfile(event.profile);
    result.fold(
      (f) => emit(state.copyWith(
          status: ProfileStatus.error, errorMessage: f.message)),
      (updated) => emit(state.copyWith(
          status: ProfileStatus.updated, profile: updated)),
    );
  }

  Future<void> _onDeleteRequested(
      ProfileDeleteRequested event, Emitter<ProfileState> emit) async {
    if (state.profile == null) return;
    emit(state.copyWith(status: ProfileStatus.deleting));
    final result = await _repository.deleteProfile(state.profile!);
    result.fold(
      (f) => emit(state.copyWith(
          status: ProfileStatus.error, errorMessage: f.message)),
      (_) => emit(state.copyWith(status: ProfileStatus.deleted)),
    );
  }

  Future<void> _onRoomsLoad(
      ProfileRoomsLoadRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(roomsStatus: RoomsStatus.loading));
    final result = await _repository.fetchAllSellerProfiles();
    result.fold(
      (f) => emit(state.copyWith(roomsStatus: RoomsStatus.error)),
      (rooms) => emit(state.copyWith(
        roomsStatus: RoomsStatus.loaded,
        rooms: rooms,
      )),
    );
  }

  Future<void> _onCreateRoom(
      ProfileCreateRoomRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(roomsStatus: RoomsStatus.creating));
    final result = await _repository.createRoom(
      nickname: event.nickname,
      description: event.description,
      country: event.country,
      currency: event.currency,
    );
    result.fold(
      (f) => emit(state.copyWith(
        roomsStatus: RoomsStatus.error,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(roomsStatus: RoomsStatus.created)),
    );
  }
}
