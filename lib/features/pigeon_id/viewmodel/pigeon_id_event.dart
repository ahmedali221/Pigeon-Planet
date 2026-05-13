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

class PigeonIdSubmitted extends PigeonIdEvent {
  const PigeonIdSubmitted();
}
