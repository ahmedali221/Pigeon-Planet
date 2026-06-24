import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../chat/view/pages/chat_room_page.dart';
import '../../../chat/viewmodel/chat_bloc.dart';
import '../../../feed/viewmodel/feed_bloc.dart';
import '../../../ratings/model/comment_model.dart';
import '../../../../../l10n/app_localizations.dart';
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

  bool get _canComment {
    final isClosed = widget.auction.isEnded ||
                     widget.auction.status == 'cancelled' ||
                     widget.auction.status == 'closed';
    return !isClosed;
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

    final auctionClosed = !_canComment;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.forum_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discussion',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (auctionClosed)
                      const Text(
                        'Auction closed',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.auction.isOwner)
                const _SmallPill(label: 'Owner'),
            ],
          ),
          const SizedBox(height: 14),
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
          if (!_canComment)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outlined, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This auction is closed. Comments are no longer accepted.',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_isCustomer || _isSeller) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: _canComment,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write a comment',
                      filled: true,
                      fillColor: _canComment
                          ? AppColors.pageBackground
                          : AppColors.border.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.3),
                        ),
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
                  width: 46,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: (!_canComment || _submittingComment)
                        ? null
                        : _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: isBlocked ? null : (isFollowing ? null : onFollow),
                icon: Icon(
                  isFollowing
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                ),
                label: Text(
                  isBlocked
                      ? 'Blocked'
                      : isFollowing
                          ? 'Following'
                          : 'Follow',
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isBlocked
                      ? AppColors.textSecondary
                      : isFollowing
                          ? AppColors.orange
                          : AppColors.primary,
                  side: BorderSide(
                    color: isBlocked
                        ? AppColors.border
                        : isFollowing
                            ? AppColors.orange
                            : AppColors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: onMessage,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  isFollowing ? 'Message' : 'Follow first',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: onMessage != null
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;

  const _CommentTile({required this.comment});

  static final _avatarColors = [
    AppColors.primary,
    AppColors.orange,
    AppColors.blue,
    AppColors.purple,
  ];

  Color get _avatarColor {
    final code = comment.ownerNickname.isEmpty
        ? comment.ownerType.hashCode
        : comment.ownerNickname.hashCode;
    return _avatarColors[(code.abs()) % _avatarColors.length];
  }

  String get _initial {
    return comment.ownerNickname.isNotEmpty
        ? comment.ownerNickname[0].toUpperCase()
        : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _avatarColor,
                child: Text(
                  _initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.ownerNickname.isNotEmpty
                          ? comment.ownerNickname
                          : comment.ownerType,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'now';
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
