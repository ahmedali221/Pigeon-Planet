import 'package:equatable/equatable.dart';

import '../model/pedigree_document_model.dart';

enum PedigreesStatus { initial, loading, uploading, loaded, reviewing, error }

class PedigreesState extends Equatable {
  final PedigreesStatus status;
  final List<PedigreeDocumentModel> documents;
  final PedigreeDocumentModel? selectedDocument;
  final String? errorMessage;

  const PedigreesState({
    this.status = PedigreesStatus.initial,
    this.documents = const [],
    this.selectedDocument,
    this.errorMessage,
  });

  PedigreesState copyWith({
    PedigreesStatus? status,
    List<PedigreeDocumentModel>? documents,
    PedigreeDocumentModel? selectedDocument,
    String? errorMessage,
    bool clearSelected = false,
    bool clearError = false,
  }) {
    return PedigreesState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      selectedDocument:
          clearSelected ? null : selectedDocument ?? this.selectedDocument,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, documents, selectedDocument, errorMessage];
}
