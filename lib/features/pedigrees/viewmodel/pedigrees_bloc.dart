import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/pedigrees_repository.dart';
import 'pedigrees_event.dart';
import 'pedigrees_state.dart';

class PedigreesBloc extends Bloc<PedigreesEvent, PedigreesState> {
  final PedigreesRepository _repository;

  PedigreesBloc({required PedigreesRepository repository})
      : _repository = repository,
        super(const PedigreesState()) {
    on<PedigreesListRequested>(_onList);
    on<PedigreeUploadRequested>(_onUpload);
    on<PedigreeDetailRequested>(_onDetail);
    on<PedigreeReviewSubmitted>(_onReview);
  }

  Future<void> _onList(
    PedigreesListRequested event,
    Emitter<PedigreesState> emit,
  ) async {
    emit(state.copyWith(status: PedigreesStatus.loading, clearError: true));
    final result = await _repository.listDocuments(birdId: event.birdId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PedigreesStatus.error,
        errorMessage: failure.message,
      )),
      (docs) => emit(state.copyWith(
        status: PedigreesStatus.loaded,
        documents: docs,
      )),
    );
  }

  Future<void> _onUpload(
    PedigreeUploadRequested event,
    Emitter<PedigreesState> emit,
  ) async {
    emit(state.copyWith(status: PedigreesStatus.uploading, clearError: true));
    final result = await _repository.uploadDocument(
      event.file,
      birdId: event.birdId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: PedigreesStatus.error,
        errorMessage: failure.message,
      )),
      (doc) => emit(state.copyWith(
        status: PedigreesStatus.loaded,
        documents: [doc, ...state.documents],
        selectedDocument: doc,
      )),
    );
  }

  Future<void> _onDetail(
    PedigreeDetailRequested event,
    Emitter<PedigreesState> emit,
  ) async {
    emit(state.copyWith(status: PedigreesStatus.uploading, clearError: true));
    final result = await _repository.getDocument(event.documentId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PedigreesStatus.error,
        errorMessage: failure.message,
      )),
      (doc) => emit(state.copyWith(
        status: PedigreesStatus.loaded,
        selectedDocument: doc,
      )),
    );
  }

  Future<void> _onReview(
    PedigreeReviewSubmitted event,
    Emitter<PedigreesState> emit,
  ) async {
    emit(state.copyWith(status: PedigreesStatus.reviewing, clearError: true));
    final result = await _repository.reviewDocument(
      event.documentId,
      ringNumber: event.ringNumber,
      description: event.description,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: PedigreesStatus.error,
        errorMessage: failure.message,
      )),
      (updated) {
        final updatedDocs = state.documents
            .map((d) => d.id == updated.id ? updated : d)
            .toList();
        emit(state.copyWith(
          status: PedigreesStatus.loaded,
          documents: updatedDocs,
          selectedDocument: updated,
        ));
      },
    );
  }
}
