part of 'pigeon_id_bloc.dart';

abstract class PigeonIdEvent extends Equatable {
  const PigeonIdEvent();
  @override
  List<Object?> get props => [];
}

class PigeonIdRingNumberChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdRingNumberChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdBreedChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdBreedChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdGenderChanged extends PigeonIdEvent {
  final PigeonGender gender;
  const PigeonIdGenderChanged(this.gender);
  @override
  List<Object?> get props => [gender];
}

class PigeonIdPhotoAdded extends PigeonIdEvent {
  final String path;
  const PigeonIdPhotoAdded(this.path);
  @override
  List<Object?> get props => [path];
}

class PigeonIdPhotoRemoved extends PigeonIdEvent {
  final int index;
  const PigeonIdPhotoRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class PigeonIdVideoRecorded extends PigeonIdEvent {
  final String path;
  const PigeonIdVideoRecorded(this.path);
  @override
  List<Object?> get props => [path];
}

class PigeonIdHatchDateChanged extends PigeonIdEvent {
  final DateTime date;
  const PigeonIdHatchDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class PigeonIdRaceResultAdded extends PigeonIdEvent {
  final String result;
  const PigeonIdRaceResultAdded(this.result);
  @override
  List<Object?> get props => [result];
}

class PigeonIdRaceResultRemoved extends PigeonIdEvent {
  final int index;
  const PigeonIdRaceResultRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class PigeonIdAchievementsChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdAchievementsChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdStaminaChanged extends PigeonIdEvent {
  final StaminaAbility stamina;
  const PigeonIdStaminaChanged(this.stamina);
  @override
  List<Object?> get props => [stamina];
}

class PigeonIdNameChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdNameChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdPriceChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdPriceChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdDescriptionChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdDescriptionChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdFlyingSpeedChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdFlyingSpeedChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdSubmitted extends PigeonIdEvent {
  const PigeonIdSubmitted();
}

class PigeonIdLoadedForEdit extends PigeonIdEvent {
  final PigeonModel pigeon;
  const PigeonIdLoadedForEdit(this.pigeon);
  @override
  List<Object?> get props => [pigeon];
}

class PigeonIdDeleteRequested extends PigeonIdEvent {
  final int id;
  const PigeonIdDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class PigeonIdStatusChanged extends PigeonIdEvent {
  final String status;
  const PigeonIdStatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class PigeonIdMarketListedChanged extends PigeonIdEvent {
  final bool value;
  const PigeonIdMarketListedChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdFatherChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdFatherChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class PigeonIdMotherChanged extends PigeonIdEvent {
  final String value;
  const PigeonIdMotherChanged(this.value);
  @override
  List<Object?> get props => [value];
}
