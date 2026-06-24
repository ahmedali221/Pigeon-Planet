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
    on<AssetRatingsLoadMoreRequested>(_onAssetRatingsLoadMore);
    on<SellerRatingsLoadMoreRequested>(_onSellerRatingsLoadMore);
    on<AssetRatingSubmitted>(_onAssetRatingSubmit);
    on<SellerRatingSubmitted>(_onSellerRatingSubmit);
    on<AssetCommentSubmitted>(_onAssetCommentSubmit);
    on<SellerCommentSubmitted>(_onSellerCommentSubmit);
  }

  Future<void> _onAssetRatingsLoad(
    AssetRatingsLoadRequested event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      currentPage: 1,
      hasMore: false,
      clearError: true,
    ));
    final ratingsResult = await _repository.getAssetRatings(event.assetId);
    final commentsResult = await _repository.getAssetComments(event.assetId);
    final ratingsPage = ratingsResult.getOrElse(
      () => (items: state.ratings, hasMore: false),
    );
    final commentsPage = commentsResult.getOrElse(
      () => (items: state.comments, hasMore: false),
    );
    emit(state.copyWith(
      loading: false,
      ratings: ratingsPage.items,
      comments: commentsPage.items,
      hasMore: ratingsPage.hasMore || commentsPage.hasMore,
      error: ratingsResult.isLeft() ? (ratingsResult.fold((f) => f.message, (_) => null)) : null,
    ));
  }

  Future<void> _onSellerRatingsLoad(
    SellerRatingsLoadRequested event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      currentPage: 1,
      hasMore: false,
      clearError: true,
    ));
    final ratingsResult = await _repository.getSellerRatings(event.sellerId);
    final commentsResult = await _repository.getSellerComments(event.sellerId);
    final ratingsPage = ratingsResult.getOrElse(
      () => (items: state.ratings, hasMore: false),
    );
    final commentsPage = commentsResult.getOrElse(
      () => (items: state.comments, hasMore: false),
    );
    emit(state.copyWith(
      loading: false,
      ratings: ratingsPage.items,
      comments: commentsPage.items,
      hasMore: ratingsPage.hasMore || commentsPage.hasMore,
      error: ratingsResult.isLeft() ? (ratingsResult.fold((f) => f.message, (_) => null)) : null,
    ));
  }

  Future<void> _onAssetRatingsLoadMore(
    AssetRatingsLoadMoreRequested event,
    Emitter<RatingsState> emit,
  ) async {
    if (!state.hasMore || state.loadingMore) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(loadingMore: true, clearError: true));
    final ratingsResult =
        await _repository.getAssetRatings(event.assetId, page: nextPage);
    final commentsResult =
        await _repository.getAssetComments(event.assetId, page: nextPage);
    final ratingsPage = ratingsResult.getOrElse(
      () => (items: <RatingModel>[], hasMore: false),
    );
    final commentsPage = commentsResult.getOrElse(
      () => (items: <CommentModel>[], hasMore: false),
    );
    emit(state.copyWith(
      loadingMore: false,
      currentPage: nextPage,
      ratings: [...state.ratings, ...ratingsPage.items],
      comments: [...state.comments, ...commentsPage.items],
      hasMore: ratingsPage.hasMore || commentsPage.hasMore,
      error: ratingsResult.isLeft() ? (ratingsResult.fold((f) => f.message, (_) => null)) : null,
    ));
  }

  Future<void> _onSellerRatingsLoadMore(
    SellerRatingsLoadMoreRequested event,
    Emitter<RatingsState> emit,
  ) async {
    if (!state.hasMore || state.loadingMore) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(loadingMore: true, clearError: true));
    final ratingsResult =
        await _repository.getSellerRatings(event.sellerId, page: nextPage);
    final commentsResult =
        await _repository.getSellerComments(event.sellerId, page: nextPage);
    final ratingsPage = ratingsResult.getOrElse(
      () => (items: <RatingModel>[], hasMore: false),
    );
    final commentsPage = commentsResult.getOrElse(
      () => (items: <CommentModel>[], hasMore: false),
    );
    emit(state.copyWith(
      loadingMore: false,
      currentPage: nextPage,
      ratings: [...state.ratings, ...ratingsPage.items],
      comments: [...state.comments, ...commentsPage.items],
      hasMore: ratingsPage.hasMore || commentsPage.hasMore,
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
