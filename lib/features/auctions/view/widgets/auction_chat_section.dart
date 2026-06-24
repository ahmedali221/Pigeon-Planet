import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../chat/view/pages/chat_room_page.dart';
import '../../../chat/viewmodel/chat_bloc.dart';
import '../../../feed/viewmodel/feed_bloc.dart';
import '../../../ratings/model/comment_model.dart';
import '../../../ratings/model/ratings_repository.dart';
import '../../model/auction_model.dart';

class AuctionChatSection extends StatefulWidget {
  final AuctionModel auction;

  const AuctionChatSection({super.key, required this.auction});

  @override
  State<AuctionChatSection> createState() => _AuctionChatSectionState();
}

class _AuctionChatSectionState extends State<AuctionChatSection> {
  final _controller = TextEditingController();
  final List<CommentModel> _comments = [];
  bool _loadingComments = false;
  bool _submittingComment = false;
  String? _commentError;

  int? get _commentAssetId =>
      widget.auction.items.isNotEmpty ? widget.auction.items.first.bird.id : null;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _currentUserLabel {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) return authState.user.phoneNumber;
    if (authState is AuthSwitchingProfile) return authState.user.phoneNumber;
    if (authState is AuthProfileSwitchFailure) return authState.user.phoneNumber;
    return 'You';
  }

  bool get _isCustomer {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) return authState.user.isCustomer;
    if (authState is AuthSwitchingProfile) return authState.user.isCustomer;
    if (authState is AuthProfileSwitchFailure) return authState.user.isCustomer;
    return false;
  }

  bool get _isSeller {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) return authState.user.isSeller;
    if (authState is AuthSwitchingProfile) return authState.user.isSeller;
    if (authState is AuthProfileSwitchFailure) return authState.user.isSeller;
    return false;
  }

  Future<void> _loadComments() async {
    final assetId = _commentAssetId;
    if (assetId == null) return;
    setState(() {
      _loadingComments = true;
      _commentError = null;
    });
    final result = await sl<RatingsRepository>().getAssetComments(assetId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loadingComments = false;
        _commentError = failure.message;
      }),
      (page) => setState(() {
        _loadingComments = false;
        _comments
          ..clear()
          ..addAll(page.items);
      }),
    );
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final assetId = _commentAssetId;
    if (assetId == null) {
      setState(() => _commentError = 'No auction item is available for comments.');
      return;
    }
    setState(() {
      _submittingComment = true;
      _commentError = null;
    });
    final result = await sl<RatingsRepository>().createAssetComment(
      assetId: assetId,
      text: text,
    );
    if (!mounted) return;
    await result.fold(
      (failure) async => setState(() {
        _submittingComment = false;
        _commentError = failure.message;
      }),
      (_) async {
        _controller.clear();
        setState(() => _submittingComment = false);
        await _loadComments();
      },
    );
  }

  void _openChat(int sellerId, String sellerNickname) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ChatBloc>()
            ..add(const ChatStarted(profileType: 'Customer')),
          child: ChatRoomPage(
            receiverProfileId: sellerId,
            partnerNickname: sellerNickname,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellerId = widget.auction.owner;
    final canContactSeller = sellerId != null &&
        !widget.auction.isOwner &&
        _isCustomer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forum_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Auction comments',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.auction.isOwner)
                const _SmallPill(label: 'Owner view'),
            ],
          ),
          const SizedBox(height: 10),
          if (canContactSeller)
            BlocBuilder<FeedBloc, FeedState>(
              buildWhen: (p, c) =>
                  p.followedSellerIds.contains(sellerId!) !=
                      c.followedSellerIds.contains(sellerId) ||
                  p.blockedProfileIds.contains(sellerId) !=
                      c.blockedProfileIds.contains(sellerId),
              builder: (context, feedState) {
                final isFollowing =
                    feedState.followedSellerIds.contains(sellerId);
                final isBlocked =
                    feedState.blockedProfileIds.contains(sellerId);
                return _SellerContactRow(
                  isFollowing: isFollowing,
                  isBlocked: isBlocked,
                  onFollow: () =>
                      context
                          .read<FeedBloc>()
                          .add(FeedFollowRequested(sellerId!)),
                  onMessage: isFollowing && !isBlocked
                      ? () => _openChat(
                            sellerId!,
                            widget.auction.sellerNickname.isNotEmpty
                                ? widget.auction.sellerNickname
                                : 'Seller',
                          )
                      : null,
                );
              },
            ),
          if (canContactSeller) const SizedBox(height: 12),
          if (_isCustomer || _isSeller) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write a comment',
                      filled: true,
                      fillColor: AppColors.pageBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submittingComment ? null : _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _submittingComment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (_commentError != null) ...[
            Text(
              _commentError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (_loadingComments)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No comments yet. Saved as comments on the auction bird until auction comments exist.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            )
          else
            ..._comments.map((comment) => _CommentTile(comment: comment)),
        ],
      ),
    );
  }
}

class _SellerContactRow extends StatelessWidget {
  final bool isFollowing;
  final bool isBlocked;
  final VoidCallback onFollow;
  final VoidCallback? onMessage;

  const _SellerContactRow({
    required this.isFollowing,
    required this.isBlocked,
    required this.onFollow,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isFollowing || isBlocked ? null : onFollow,
            icon: Icon(
              isFollowing ? Icons.check_circle_rounded : Icons.person_add_alt,
              size: 18,
            ),
            label: Text(isBlocked
                ? 'Blocked'
                : isFollowing
                    ? 'Following'
                    : 'Follow seller'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isFollowing ? AppColors.primary : AppColors.textSecondary,
              side: BorderSide(
                color: isFollowing ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(isFollowing ? 'Message' : 'Follow to message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.ownerNickname.isNotEmpty
                      ? comment.ownerNickname
                      : comment.ownerType,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTime(comment.created),
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment.text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SmallPill extends StatelessWidget {
  final String label;

  const _SmallPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
