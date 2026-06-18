part of 'insights_bloc.dart';

enum InsightsStatus { initial, loading, loaded, error }

class InsightsState extends Equatable {
  final InsightsStatus status;
  final SellerInsightsModel? insights;
  final String? errorMessage;

  const InsightsState({
    this.status = InsightsStatus.initial,
    this.insights,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, insights, errorMessage];
}
