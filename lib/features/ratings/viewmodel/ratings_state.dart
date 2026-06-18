part of 'ratings_bloc.dart';

class RatingsState extends Equatable {
  final List<RatingModel> ratings;
  final List<CommentModel> comments;
  final bool loading;
  final bool submitting;
  final bool submitSuccess;
  final String? error;
  final String? submitError;

  const RatingsState({
    this.ratings = const [],
    this.comments = const [],
    this.loading = false,
    this.submitting = false,
    this.submitSuccess = false,
    this.error,
    this.submitError,
  });

  double get avgStars {
    if (ratings.isEmpty) return 0;
    return ratings.fold(0, (sum, r) => sum + r.stars) / ratings.length;
  }

  RatingsState copyWith({
    List<RatingModel>? ratings,
    List<CommentModel>? comments,
    bool? loading,
    bool? submitting,
    bool? submitSuccess,
    String? error,
    bool clearError = false,
    String? submitError,
    bool clearSubmitError = false,
  }) =>
      RatingsState(
        ratings: ratings ?? this.ratings,
        comments: comments ?? this.comments,
        loading: loading ?? this.loading,
        submitting: submitting ?? this.submitting,
        submitSuccess: submitSuccess ?? this.submitSuccess,
        error: clearError ? null : (error ?? this.error),
        submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      );

  @override
  List<Object?> get props =>
      [ratings, comments, loading, submitting, submitSuccess, error, submitError];
}
