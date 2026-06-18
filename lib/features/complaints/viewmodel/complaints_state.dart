import 'package:equatable/equatable.dart';

import '../model/complaint_model.dart';

enum ComplaintsStatus {
  initial,
  loading,
  loaded,
  detailLoading,
  creating,
  cancelling,
  error,
}

class ComplaintsState extends Equatable {
  final ComplaintsStatus status;
  final List<ComplaintModel> complaints;
  final ComplaintModel? selectedComplaint;
  final String? errorMessage;
  final bool createSuccess;
  final bool cancelSuccess;

  const ComplaintsState({
    this.status = ComplaintsStatus.initial,
    this.complaints = const [],
    this.selectedComplaint,
    this.errorMessage,
    this.createSuccess = false,
    this.cancelSuccess = false,
  });

  ComplaintsState copyWith({
    ComplaintsStatus? status,
    List<ComplaintModel>? complaints,
    ComplaintModel? selectedComplaint,
    String? errorMessage,
    bool? createSuccess,
    bool? cancelSuccess,
    bool clearSelected = false,
    bool clearError = false,
    bool resetActions = false,
  }) {
    return ComplaintsState(
      status: status ?? this.status,
      complaints: complaints ?? this.complaints,
      selectedComplaint: clearSelected
          ? null
          : selectedComplaint ?? this.selectedComplaint,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      createSuccess: resetActions ? false : createSuccess ?? this.createSuccess,
      cancelSuccess: resetActions ? false : cancelSuccess ?? this.cancelSuccess,
    );
  }

  @override
  List<Object?> get props => [
    status,
    complaints,
    selectedComplaint,
    errorMessage,
    createSuccess,
    cancelSuccess,
  ];
}
