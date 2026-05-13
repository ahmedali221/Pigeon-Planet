part of 'pigeon_id_bloc.dart';

enum PigeonIdStatus { initial, editing, submitting, submitted, error }

class PigeonIdState extends Equatable {
  final PigeonIdStatus status;
  final String ringNumber;
  final String breed;
  final PigeonGender gender;
  final List<String> photoPaths;
  final String? videoPath;
  final DateTime? hatchDate;
  final List<String> raceResults;
  final String? qrData;
  final String? errorMessage;

  const PigeonIdState({
    this.status = PigeonIdStatus.initial,
    this.ringNumber = '',
    this.breed = '',
    this.gender = PigeonGender.male,
    this.photoPaths = const [],
    this.videoPath,
    this.hatchDate,
    this.raceResults = const [],
    this.qrData,
    this.errorMessage,
  });

  bool get canProceedToPhotos => ringNumber.isNotEmpty && breed.isNotEmpty;
  bool get canProceedToVideo => photoPaths.length >= 4;
  bool get isReadyToSubmit =>
      ringNumber.isNotEmpty &&
      breed.isNotEmpty &&
      photoPaths.length >= 4 &&
      videoPath != null;

  PigeonIdState copyWith({
    PigeonIdStatus? status,
    String? ringNumber,
    String? breed,
    PigeonGender? gender,
    List<String>? photoPaths,
    String? videoPath,
    DateTime? hatchDate,
    List<String>? raceResults,
    String? qrData,
    String? errorMessage,
  }) =>
      PigeonIdState(
        status: status ?? this.status,
        ringNumber: ringNumber ?? this.ringNumber,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        photoPaths: photoPaths ?? this.photoPaths,
        videoPath: videoPath ?? this.videoPath,
        hatchDate: hatchDate ?? this.hatchDate,
        raceResults: raceResults ?? this.raceResults,
        qrData: qrData ?? this.qrData,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        ringNumber,
        breed,
        gender,
        photoPaths,
        videoPath,
        hatchDate,
        raceResults,
        qrData,
        errorMessage,
      ];
}
