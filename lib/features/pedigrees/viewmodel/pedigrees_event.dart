import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class PedigreesEvent extends Equatable {
  const PedigreesEvent();
  @override
  List<Object?> get props => [];
}

class PedigreesListRequested extends PedigreesEvent {
  final int? birdId;
  const PedigreesListRequested({this.birdId});

  @override
  List<Object?> get props => [birdId];
}

class PedigreeUploadRequested extends PedigreesEvent {
  final XFile file;
  final int? birdId;

  const PedigreeUploadRequested(this.file, {this.birdId});

  @override
  List<Object?> get props => [file.path, birdId];
}

class PedigreeDetailRequested extends PedigreesEvent {
  final int documentId;
  const PedigreeDetailRequested(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class PedigreeReviewSubmitted extends PedigreesEvent {
  final int documentId;
  final String ringNumber;
  final String description;

  const PedigreeReviewSubmitted({
    required this.documentId,
    required this.ringNumber,
    required this.description,
  });

  @override
  List<Object?> get props => [documentId, ringNumber, description];
}

class PedigreeCreateSubmitted extends PedigreesEvent {
  final String ringNumber;
  final String description;
  final int? birdId;

  const PedigreeCreateSubmitted({
    required this.ringNumber,
    this.description = '',
    this.birdId,
  });

  @override
  List<Object?> get props => [ringNumber, description, birdId];
}
