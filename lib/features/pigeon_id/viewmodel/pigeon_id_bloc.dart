import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/pigeon_model.dart';
import '../model/pigeon_repository.dart';

part 'pigeon_id_event.dart';
part 'pigeon_id_state.dart';

class PigeonIdBloc extends Bloc<PigeonIdEvent, PigeonIdState> {
  final PigeonRepository _repository;
  final void Function(PigeonModel)? onBirdSaved;

  PigeonIdBloc({required PigeonRepository repository, this.onBirdSaved})
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
    on<PigeonIdAchievementsChanged>(_onAchievementsChanged);
    on<PigeonIdStaminaChanged>(_onStaminaChanged);
    on<PigeonIdNameChanged>(_onNameChanged);
    on<PigeonIdPriceChanged>(_onPriceChanged);
    on<PigeonIdDescriptionChanged>(_onDescriptionChanged);
    on<PigeonIdFlyingSpeedChanged>(_onFlyingSpeedChanged);
    on<PigeonIdSubmitted>(_onSubmitted);
    on<PigeonIdLoadedForEdit>(_onLoadedForEdit);
    on<PigeonIdDeleteRequested>(_onDeleteRequested);
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

  void _onAchievementsChanged(
      PigeonIdAchievementsChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(achievements: event.value));
  }

  void _onStaminaChanged(
      PigeonIdStaminaChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(staminaAbility: event.stamina));
  }

  void _onNameChanged(
      PigeonIdNameChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(name: event.value));
  }

  void _onPriceChanged(
      PigeonIdPriceChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(price: event.value));
  }

  void _onDescriptionChanged(
      PigeonIdDescriptionChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(description: event.value));
  }

  void _onFlyingSpeedChanged(
      PigeonIdFlyingSpeedChanged event, Emitter<PigeonIdState> emit) {
    emit(state.copyWith(flyingSpeed: event.value));
  }

  Future<void> _onSubmitted(
      PigeonIdSubmitted event, Emitter<PigeonIdState> emit) async {
    if (!state.isReadyToSubmit) return;

    final pigeon = PigeonModel(
      id: state.editingId,
      ringNumber: state.ringNumber,
      name: state.name.isNotEmpty ? state.name : state.ringNumber,
      breed: state.breed,
      gender: state.gender,
      hatchDate: state.hatchDate,
      achievements: state.achievements,
      staminaAbility: state.staminaAbility,
      price: double.tryParse(state.price) ?? 0.0,
      description: state.description,
      flyingSpeed: double.tryParse(state.flyingSpeed),
      isMarketListed: true,
      photoPaths: state.photoPaths,
      videoPath: state.videoPath,
    );

    if (state.editingId != null) {
      emit(state.copyWith(status: PigeonIdStatus.updating));
      final result = await _repository.updateBird(state.editingId!, pigeon);
      result.fold(
        (f) => emit(state.copyWith(
          status: PigeonIdStatus.error,
          errorMessage: f.message,
        )),
        (updated) => emit(state.copyWith(
          status: PigeonIdStatus.updated,
          savedBird: updated,
        )),
      );
    } else {
      emit(state.copyWith(status: PigeonIdStatus.submitting));
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
            savedBird: saved,
            qrData: qrData,
          ));
        },
      );
    }
  }

  void _onLoadedForEdit(
      PigeonIdLoadedForEdit event, Emitter<PigeonIdState> emit) {
    final p = event.pigeon;
    emit(PigeonIdState(
      status: PigeonIdStatus.editing,
      editingId: p.id,
      ringNumber: p.ringNumber,
      breed: p.breed,
      gender: p.gender,
      hatchDate: p.hatchDate,
      achievements: p.achievements,
      staminaAbility: p.staminaAbility,
      name: p.name,
      price: p.price > 0 ? p.price.toStringAsFixed(0) : '',
      description: p.description,
      flyingSpeed: p.flyingSpeed != null
          ? p.flyingSpeed!.toStringAsFixed(1)
          : '',
      savedBird: p,
    ));
  }

  Future<void> _onDeleteRequested(
      PigeonIdDeleteRequested event, Emitter<PigeonIdState> emit) async {
    emit(state.copyWith(status: PigeonIdStatus.deleting));
    final result = await _repository.deleteBird(event.id);
    result.fold(
      (f) => emit(state.copyWith(
        status: PigeonIdStatus.error,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(status: PigeonIdStatus.deleted)),
    );
  }
}
