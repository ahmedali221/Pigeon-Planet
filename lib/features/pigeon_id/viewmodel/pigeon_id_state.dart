part of 'pigeon_id_bloc.dart';

enum PigeonIdStatus {
  initial,
  editing,
  submitting,
  submitted,
  updating,
  updated,
  deleting,
  deleted,
  error,
}

class PigeonIdState extends Equatable {
  final PigeonIdStatus status;
  final int? editingId;
  final String ringNumber;
  final String breed;
  final PigeonGender gender;
  final List<String> photoPaths;
  final String? videoPath;
  final DateTime? hatchDate;
  final List<String> raceResults;
  final String? qrData;
  final String? errorMessage;
  final String achievements;
  final StaminaAbility staminaAbility;
  final String name;
  final String price;
  final String description;
  final String flyingSpeed;
  final PigeonModel? savedBird;

  const PigeonIdState({
    this.status = PigeonIdStatus.initial,
    this.editingId,
    this.ringNumber = '',
    this.breed = '',
    this.gender = PigeonGender.male,
    this.photoPaths = const [],
    this.videoPath,
    this.hatchDate,
    this.raceResults = const [],
    this.qrData,
    this.errorMessage,
    this.achievements = '',
    this.staminaAbility = StaminaAbility.good,
    this.name = '',
    this.price = '',
    this.description = '',
    this.flyingSpeed = '',
    this.savedBird,
  });

  bool get canProceedToPhotos =>
      ringNumber.isNotEmpty && breed.isNotEmpty;
  bool get canProceedToVideo => photoPaths.length >= 4;
  bool get isReadyToSubmit =>
      ringNumber.isNotEmpty &&
      breed.isNotEmpty &&
      (editingId != null || photoPaths.length >= 4);

  PigeonIdState copyWith({
    PigeonIdStatus? status,
    int? editingId,
    String? ringNumber,
    String? breed,
    PigeonGender? gender,
    List<String>? photoPaths,
    String? videoPath,
    DateTime? hatchDate,
    List<String>? raceResults,
    String? qrData,
    String? errorMessage,
    String? achievements,
    StaminaAbility? staminaAbility,
    String? name,
    String? price,
    String? description,
    String? flyingSpeed,
    PigeonModel? savedBird,
  }) =>
      PigeonIdState(
        status: status ?? this.status,
        editingId: editingId ?? this.editingId,
        ringNumber: ringNumber ?? this.ringNumber,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        photoPaths: photoPaths ?? this.photoPaths,
        videoPath: videoPath ?? this.videoPath,
        hatchDate: hatchDate ?? this.hatchDate,
        raceResults: raceResults ?? this.raceResults,
        qrData: qrData ?? this.qrData,
        errorMessage: errorMessage ?? this.errorMessage,
        achievements: achievements ?? this.achievements,
        staminaAbility: staminaAbility ?? this.staminaAbility,
        name: name ?? this.name,
        price: price ?? this.price,
        description: description ?? this.description,
        flyingSpeed: flyingSpeed ?? this.flyingSpeed,
        savedBird: savedBird ?? this.savedBird,
      );

  @override
  List<Object?> get props => [
        status,
        editingId,
        ringNumber,
        breed,
        gender,
        photoPaths,
        videoPath,
        hatchDate,
        raceResults,
        qrData,
        errorMessage,
        achievements,
        staminaAbility,
        name,
        price,
        description,
        flyingSpeed,
        savedBird,
      ];
}
