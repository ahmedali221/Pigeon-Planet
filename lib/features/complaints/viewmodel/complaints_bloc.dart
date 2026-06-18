import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/complaint_model.dart';
import '../model/complaints_repository.dart';
import 'complaints_event.dart';
import 'complaints_state.dart';

class ComplaintsBloc extends Bloc<ComplaintsEvent, ComplaintsState> {
  final ComplaintsRepository _repository;

  ComplaintsBloc({required ComplaintsRepository repository})
    : _repository = repository,
      super(const ComplaintsState()) {
    on<ComplaintsLoadRequested>(_onLoad);
    on<ComplaintDetailRequested>(_onDetail);
    on<ComplaintCreateRequested>(_onCreate);
    on<ComplaintCancelRequested>(_onCancel);
  }

  Future<void> _onLoad(
    ComplaintsLoadRequested event,
    Emitter<ComplaintsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ComplaintsStatus.loading,
        clearError: true,
        resetActions: true,
      ),
    );
    final result = await _repository.listMyComplaints();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ComplaintsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (complaints) => emit(
        state.copyWith(status: ComplaintsStatus.loaded, complaints: complaints),
      ),
    );
  }

  Future<void> _onDetail(
    ComplaintDetailRequested event,
    Emitter<ComplaintsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ComplaintsStatus.detailLoading,
        clearError: true,
        resetActions: true,
      ),
    );
    final result = await _repository.getComplaint(event.complaintId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ComplaintsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (complaint) => emit(
        state.copyWith(
          status: ComplaintsStatus.loaded,
          selectedComplaint: complaint,
          complaints: _upsert(complaint),
        ),
      ),
    );
  }

  Future<void> _onCreate(
    ComplaintCreateRequested event,
    Emitter<ComplaintsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ComplaintsStatus.creating,
        clearError: true,
        resetActions: true,
      ),
    );
    final result = await _repository.createComplaint(
      paymentRequestId: event.paymentRequestId,
      title: event.title,
      description: event.description,
      complaintType: event.complaintType,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ComplaintsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (complaint) => emit(
        state.copyWith(
          status: ComplaintsStatus.loaded,
          complaints: [complaint, ...state.complaints],
          selectedComplaint: complaint,
          createSuccess: true,
        ),
      ),
    );
  }

  Future<void> _onCancel(
    ComplaintCancelRequested event,
    Emitter<ComplaintsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ComplaintsStatus.cancelling,
        clearError: true,
        resetActions: true,
      ),
    );
    final result = await _repository.cancelComplaint(event.complaintId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ComplaintsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final selected = state.selectedComplaint?.id == event.complaintId
            ? state.selectedComplaint!.copyWith(status: 'cancelled')
            : state.selectedComplaint;
        final complaints = state.complaints
            .map(
              (c) => c.id == event.complaintId
                  ? c.copyWith(status: 'cancelled')
                  : c,
            )
            .toList();
        emit(
          state.copyWith(
            status: ComplaintsStatus.loaded,
            complaints: complaints,
            selectedComplaint: selected,
            cancelSuccess: true,
          ),
        );
      },
    );
  }

  List<ComplaintModel> _upsert(ComplaintModel complaint) {
    final exists = state.complaints.any((c) => c.id == complaint.id);
    if (!exists) return [complaint, ...state.complaints];
    return state.complaints
        .map((c) => c.id == complaint.id ? complaint : c)
        .toList();
  }
}
