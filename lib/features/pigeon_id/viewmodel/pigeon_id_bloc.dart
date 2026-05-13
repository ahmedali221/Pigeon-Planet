import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/pigeon_model.dart';
import '../model/pigeon_repository.dart';

part 'pigeon_id_event.dart';
part 'pigeon_id_state.dart';

class PigeonIdBloc extends Bloc<PigeonIdEvent, PigeonIdState> {
  final PigeonRepository _repository;

  PigeonIdBloc({required PigeonRepository repository})
      : _repository = repository,
        super(const PigeonIdState(status: PigeonIdStatus.editing)) {
    on<PigeonIdRingNumberChanged>(_onRingNumberChanged);
    on<PigeonIdBreedChanged>(_onBreedChanged);
    on<PigeonIdGenderChanged>(_onGenderChanged);
    on<PigeonIdPhotoAdded>(_onPhotoAdded);
    on<PigeonIdPhotoRemoved>(_onPhotoRemoved);
    on<PigeonIdVideoRecorded>(_onVideoRecorded);
    on<PigeonIdHatchDateChanged>(_onHatchDateChanged);
    on<PigeonIdRaceResultAdded>(_onRaceResultAdded);
    on<PigeonIdRaceResultRemoved>(_onRaceResultRemoved);
    on<PigeonIdSubmitted>(_onSubmitted);
  }

  void _onRingNumberChanged(
      PigeonIdRingNumberChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(ringNumber: event.value));
  }

  void _onBreedChanged(
      PigeonIdBreedChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(breed: event.value));
  }

  void _onGenderChanged(
      PigeonIdGenderChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(gender: event.gender));
  }

  void _onPhotoAdded(PigeonIdPhotoAdded event, Emitter<PigeonIdState> emit) {
    if (state.photoPaths.length >= 8) return;
    emit(state.copyWith(photoPaths: [...state.photoPaths, event.path]));
  }

  void _onPhotoRemoved(
      PigeonIdPhotoRemoved event, Emitter<PigeonIdState> emit) {
    final updated = List<String>.from(state.photoPaths)
      ..removeAt(event.index);
    emit(state.copyWith(photoPaths: updated));
  }

  void _onVideoRecorded(
      PigeonIdVideoRecorded event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(videoPath: event.path));
  }

  void _onHatchDateChanged(
      PigeonIdHatchDateChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(hatchDate: event.date));
  }

  void _onRaceResultAdded(
      PigeonIdRaceResultAdded event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(raceResults: [...state.raceResults, event.result]));
  }

  void _onRaceResultRemoved(
      PigeonIdRaceResultRemoved event, Emitter<PigeonIdState> emit) {
    final updated = List<String>.from(state.raceResults)
      ..removeAt(event.index);
    emit(state.copyWith(raceResults: updated));
  }

  Future<void> _onSubmitted(
      PigeonIdSubmitted event, Emitter<PigeonIdState> emit) async {
    if (!state.isReadyToSubmit) return;
    emit(state.copyWith(status: PigeonIdStatus.submitting));

    final pigeon = PigeonModel(
      ringNumber: state.ringNumber,
      breed: state.breed,
      gender: state.gender,
      hatchDate: state.hatchDate,
    );

    final result = await _repository.saveBird(pigeon);
    result.fold(
      (f) => emit(state.copyWith(
        status: PigeonIdStatus.error,
        errorMessage: f.message,
      )),
      (saved) {
        final qrData =
            'PP-BIRD::${saved.ringNumber}::${DateTime.now().millisecondsSinceEpoch}';
        emit(state.copyWith(
          status: PigeonIdStatus.submitted,
          qrData: qrData,
        ));
      },
    );
  }
}
