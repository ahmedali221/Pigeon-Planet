import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../model/comment_model.dart';
import '../../model/rating_model.dart';
import '../../model/ratings_repository.dart';
import '../../viewmodel/ratings_bloc.dart';

import '../../../../l10n/app_localizations.dart';
enum RatingTargetType { asset, seller }

class RatingsSection extends StatelessWidget {
  final RatingTargetType targetType;
  final int targetId;

  /// Pass true only for customer profiles — guards the "Rate" button.
  final bool canRate;

  RatingsSection({
    super.key,
    required this.targetType,
    required this.targetId,
    this.canRate = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = RatingsBloc(repository: sl<RatingsRepository>());
        if (targetType == RatingTargetType.asset) {
          bloc.add(AssetRatingsLoadRequested(targetId));
        } else {
          bloc.add(SellerRatingsLoadRequested(targetId));
        }
        return bloc;
      },
      child: _RatingsSectionBody(
        targetType: targetType,
        targetId: targetId,
        canRate: canRate,
      ),
    );
  }
}

class _RatingsSectionBody extends StatelessWidget {
  final RatingTargetType targetType;
  final int targetId;
  final bool canRate;

  _RatingsSectionBody({
    required this.targetType,
    required this.targetId,
    required this.canRate,
  });

  void _showRatingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<RatingsBloc>(),
        child: _RatingBottomSheet(
          targetType: targetType,
          targetId: targetId,
        ),
      ),
    );
  }

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<RatingsBloc>(),
        child: _CommentBottomSheet(
          targetType: targetType,
          targetId: targetId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RatingsBloc, RatingsState>(
      listenWhen: (p, c) =>
          (c.submitSuccess && !p.submitSuccess) ||
          (c.submitError != null && c.submitError != p.submitError),
      listener: (context, state) {
        if (state.submitSuccess) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).ratingSubmittedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.submitError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              avgStars: state.avgStars,
              ratingsCount: state.ratings.length,
              canRate: canRate,
              onRate: () => _showRatingSheet(context),
              onComment: () => _showCommentSheet(context),
            ),
            if (state.loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (state.ratings.isNotEmpty) ...[
                _SubHeading(AppLocalizations.of(context).reviews),
                ...state.ratings.map((r) => _RatingTile(rating: r)),
              ],
              if (state.comments.isNotEmpty) ...[
                _SubHeading(AppLocalizations.of(context).altalyqat),
                ...state.comments.map((c) => _CommentTile(comment: c)),
              ],
              if (state.hasMore)
                _LoadMoreButton(
                  loading: state.loadingMore,
                  onTap: () {
                    if (targetType == RatingTargetType.asset) {
                      context
                          .read<RatingsBloc>()
                          .add(AssetRatingsLoadMoreRequested(targetId));
                    } else {
                      context
                          .read<RatingsBloc>()
                          .add(SellerRatingsLoadMoreRequested(targetId));
                    }
                  },
                ),
              if (state.ratings.isEmpty && state.comments.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'لا توجد تقييمات أو تعليقات بعد',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  _LoadMoreButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          visualDensity: VisualDensity.compact,
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text('Ø¹Ø±Ø¶ Ø§Ù„Ù…Ø²ÙŠØ¯'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final double avgStars;
  final int ratingsCount;
  final bool canRate;
  final VoidCallback onRate;
  final VoidCallback onComment;

  _SectionHeader({
    required this.avgStars,
    required this.ratingsCount,
    required this.canRate,
    required this.onRate,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          SizedBox(width: 4),
          Text(
            avgStars > 0 ? avgStars.toStringAsFixed(1) : '—',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textPrimary),
          ),
          if (ratingsCount > 0) ...[
            SizedBox(width: 4),
            Text(
              '($ratingsCount)',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          Spacer(),
          if (canRate)
            TextButton.icon(
              onPressed: onRate,
              icon: Icon(Icons.star_outline, size: 16),
              label: Text(AppLocalizations.of(context).ratingLabel),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  visualDensity: VisualDensity.compact),
            ),
          TextButton.icon(
            onPressed: onComment,
            icon: Icon(Icons.chat_bubble_outline, size: 16),
            label: Text(AppLocalizations.of(context).commentLabel),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  final String text;
  _SubHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textSecondary),
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  final RatingModel rating;
  _RatingTile({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, size: 18, color: AppColors.primary),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rating.ownerNickname,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textPrimary),
                    ),
                    SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < rating.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 13,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                if (rating.commentText != null && rating.commentText!.isNotEmpty) ...[
                  SizedBox(height: 3),
                  Text(
                    rating.commentText!,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.inputBg,
            child: Icon(Icons.person, size: 18, color: AppColors.textSecondary),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.ownerNickname,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary),
                ),
                SizedBox(height: 3),
                Text(
                  comment.text,
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheets ────────────────────────────────────────────────────────────

class _RatingBottomSheet extends StatefulWidget {
  final RatingTargetType targetType;
  final int targetId;

  _RatingBottomSheet({required this.targetType, required this.targetId});

  @override
  State<_RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<_RatingBottomSheet> {
  int _stars = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_stars == 0) return;
    if (widget.targetType == RatingTargetType.asset) {
      context.read<RatingsBloc>().add(AssetRatingSubmitted(
            assetId: widget.targetId,
            stars: _stars,
            commentText: _commentCtrl.text.trim().isEmpty
                ? null
                : _commentCtrl.text.trim(),
          ));
    } else {
      context.read<RatingsBloc>().add(SellerRatingSubmitted(
            sellerId: widget.targetId,
            stars: _stars,
            commentText: _commentCtrl.text.trim().isEmpty
                ? null
                : _commentCtrl.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أضف تقييمك',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Icon(
                  i < _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 36,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).addCommentHint,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          SizedBox(height: 16),
          BlocBuilder<RatingsBloc, RatingsState>(
            buildWhen: (p, c) => p.submitting != c.submitting,
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_stars == 0 || state.submitting)
                      ? null
                      : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: state.submitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppLocalizations.of(context).submitRatingBtn),
                ),
              );
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CommentBottomSheet extends StatefulWidget {
  final RatingTargetType targetType;
  final int targetId;

  _CommentBottomSheet({required this.targetType, required this.targetId});

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (widget.targetType == RatingTargetType.asset) {
      context.read<RatingsBloc>().add(
            AssetCommentSubmitted(assetId: widget.targetId, text: text),
          );
    } else {
      context.read<RatingsBloc>().add(
            SellerCommentSubmitted(sellerId: widget.targetId, text: text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أضف تعليقك',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).writeYourComment,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          SizedBox(height: 16),
          BlocBuilder<RatingsBloc, RatingsState>(
            buildWhen: (p, c) => p.submitting != c.submitting,
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.submitting ? null : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: state.submitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppLocalizations.of(context).submitCommentBtn),
                ),
              );
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
