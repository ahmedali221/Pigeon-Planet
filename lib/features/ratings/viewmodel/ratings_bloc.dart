import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/comment_model.dart';
import '../model/rating_model.dart';
import '../model/ratings_repository.dart';

part 'ratings_event.dart';
part 'ratings_state.dart';

class RatingsBloc extends Bloc<RatingsEvent, RatingsState> {
  final RatingsRepository _repository;

  RatingsBloc({required RatingsRepository repository})
      : _repository = repository,
        super(const RatingsState()) {
    on<AssetRatingsLoadRequested>(_onAssetRatingsLoad);
    on<SellerRatingsLoadRequested>(_onSellerRatingsLoad);
    on<AssetRatingSubmitted>(_onAssetRatingSubmit);
    on<SellerRatingSubmitted>(_onSellerRatingSubmit);
    on<AssetCommentSubmitted>(_onAssetCommentSubmit);
    on<SellerCommentSubmitted>(_onSellerCommentSubmit);
  }

  Future<void> _onAssetRatingsLoad(
    AssetRatingsLoadRequested event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    final results = await Future.wait([
      _repository.getAssetRatings(event.assetId),
      _repository.getAssetComments(event.assetId),
    ]);
    final ratingsResult = results[0] as dynamic;
    final commentsResult = results[1] as dynamic;
    emit(state.copyWith(
      loading: false,
      ratings: ratingsResult.fold((_) => state.ratings, (r) => r as List<RatingModel>),
      comments: commentsResult.fold((_) => state.comments, (c) => c as List<CommentModel>),
      error: ratingsResult.isLeft() ? (ratingsResult.fold((f) => f.message, (_) => null)) : null,
    ));
  }

  Future<void> _onSellerRatingsLoad(
    SellerRatingsLoadRequested event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    final results = await Future.wait([
      _repository.getSellerRatings(event.sellerId),
      _repository.getSellerComments(event.sellerId),
    ]);
    final ratingsResult = results[0] as dynamic;
    final commentsResult = results[1] as dynamic;
    emit(state.copyWith(
      loading: false,
      ratings: ratingsResult.fold((_) => state.ratings, (r) => r as List<RatingModel>),
      comments: commentsResult.fold((_) => state.comments, (c) => c as List<CommentModel>),
      error: ratingsResult.isLeft() ? (ratingsResult.fold((f) => f.message, (_) => null)) : null,
    ));
  }

  Future<void> _onAssetRatingSubmit(
    AssetRatingSubmitted event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearSubmitError: true, submitSuccess: false));
    final result = await _repository.createAssetRating(
      assetId: event.assetId,
      stars: event.stars,
      commentText: event.commentText,
    );
    result.fold(
      (f) => emit(state.copyWith(submitting: false, submitError: f.message)),
      (_) {
        emit(state.copyWith(submitting: false, submitSuccess: true));
        add(AssetRatingsLoadRequested(event.assetId));
      },
    );
  }

  Future<void> _onSellerRatingSubmit(
    SellerRatingSubmitted event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearSubmitError: true, submitSuccess: false));
    final result = await _repository.createSellerRating(
      sellerId: event.sellerId,
      stars: event.stars,
      commentText: event.commentText,
    );
    result.fold(
      (f) => emit(state.copyWith(submitting: false, submitError: f.message)),
      (_) {
        emit(state.copyWith(submitting: false, submitSuccess: true));
        add(SellerRatingsLoadRequested(event.sellerId));
      },
    );
  }

  Future<void> _onAssetCommentSubmit(
    AssetCommentSubmitted event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearSubmitError: true, submitSuccess: false));
    final result = await _repository.createAssetComment(
      assetId: event.assetId,
      text: event.text,
    );
    result.fold(
      (f) => emit(state.copyWith(submitting: false, submitError: f.message)),
      (_) {
        emit(state.copyWith(submitting: false, submitSuccess: true));
        add(AssetRatingsLoadRequested(event.assetId));
      },
    );
  }

  Future<void> _onSellerCommentSubmit(
    SellerCommentSubmitted event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearSubmitError: true, submitSuccess: false));
    final result = await _repository.createSellerComment(
      sellerId: event.sellerId,
      text: event.text,
    );
    result.fold(
      (f) => emit(state.copyWith(submitting: false, submitError: f.message)),
      (_) {
        emit(state.copyWith(submitting: false, submitSuccess: true));
        add(SellerRatingsLoadRequested(event.sellerId));
      },
    );
  }
}
