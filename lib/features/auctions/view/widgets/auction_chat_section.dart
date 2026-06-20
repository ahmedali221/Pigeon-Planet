import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/auction_comment_model.dart';
import '../../model/auction_model.dart';
import '../../viewmodel/auctions_bloc.dart';

class AuctionChatSection extends StatefulWidget {
  final AuctionModel auction;
  const AuctionChatSection({super.key, required this.auction});

  @override
  State<AuctionChatSection> createState() => _AuctionChatSectionState();
}

class _AuctionChatSectionState extends State<AuctionChatSection> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isAnnouncement = false;
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<AuctionsBloc>()
            .add(AuctionChatLoadRequested(widget.auction.id));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _send(BuildContext ctx) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    ctx.read<AuctionsBloc>().add(AuctionCommentPosted(
          auctionId: widget.auction.id,
          body: text,
          isAnnouncement: _isAnnouncement,
        ));
    _ctrl.clear();
    if (mounted) setState(() => _isAnnouncement = false);
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;
    final screenH = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<AuctionsBloc, AuctionsState>(
      listenWhen: (p, c) =>
          (c.chatError != null && c.chatError != p.chatError) ||
          c.chatComments.length > _prevCount,
      listener: (ctx, state) {
        if (state.chatError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.chatError!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
        if (state.chatComments.length > _prevCount) {
          _prevCount = state.chatComments.length;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }
      },
      buildWhen: (p, c) =>
          p.chatComments != c.chatComments ||
          p.isChatLoading != c.isChatLoading ||
          p.isSendingComment != c.isSendingComment ||
          p.isUpdating != c.isUpdating ||
          p.selectedAuction?.chatEnabled != c.selectedAuction?.chatEnabled,
      builder: (ctx, state) {
        final chatEnabled =
            state.selectedAuction?.chatEnabled ?? auction.chatEnabled;
        final isOwner = auction.isOwner;

        return Container(
          height: screenH * 0.78,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── handle ──────────────────────────────────────────────────
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'شات المزاد',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    if (isOwner)
                      _ChatToggleChip(
                        enabled: chatEnabled,
                        isLoading: state.isUpdating,
                        onTap: () => ctx.read<AuctionsBloc>().add(
                              AuctionChatToggleRequested(
                                auctionId: auction.id,
                                chatEnabled: !chatEnabled,
                              ),
                            ),
                      )
                    else
                      _CountBadge(count: state.chatComments.length),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),

              // ── body ────────────────────────────────────────────────────
              Expanded(
                child: !chatEnabled && !isOwner
                    ? const _DisabledPlaceholder()
                    : state.isChatLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2),
                          )
                        : state.chatComments.isEmpty
                            ? const _EmptyPlaceholder()
                            : ListView.builder(
                                controller: _scrollCtrl,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                itemCount: state.chatComments.length,
                                itemBuilder: (_, i) =>
                                    _CommentTile(comment: state.chatComments[i]),
                              ),
              ),

              // ── input row ───────────────────────────────────────────────
              if (chatEnabled || isOwner) ...[
                const Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOwner)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isAnnouncement = !_isAnnouncement),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isAnnouncement
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              const Text('إعلان رسمي',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      if (isOwner) const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              decoration: InputDecoration(
                                hintText: isOwner
                                    ? 'أضف تنويهاً أو إعلاناً...'
                                    : 'أضف تعليقاً...',
                                hintStyle: const TextStyle(
                                    fontSize: 13, color: AppColors.textHint),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: const BorderSide(
                                        color: AppColors.border)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: const BorderSide(
                                        color: AppColors.border)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: const BorderSide(
                                        color: AppColors.primary, width: 1.5)),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(ctx),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _SendButton(
                            isSending: state.isSendingComment,
                            onTap: () => _send(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Comment tile dispatcher ────────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final AuctionCommentModel comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    if (comment.isAnnouncement) return _AnnouncementTile(comment: comment);
    return _BubbleTile(comment: comment);
  }
}

// ── Announcement tile ─────────────────────────────────────────────────────────
class _AnnouncementTile extends StatelessWidget {
  final AuctionCommentModel comment;
  const _AnnouncementTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded,
                  size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text('إعلان رسمي',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const Spacer(),
              Text(_fmtTime(comment.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment.body,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
        ],
      ),
    );
  }
}

// ── Chat bubble tile ──────────────────────────────────────────────────────────
class _BubbleTile extends StatelessWidget {
  final AuctionCommentModel comment;
  const _BubbleTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isMine = comment.isMine;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        // RTL: start = right, end = left
        mainAxisAlignment:
            isMine ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isMine
            ? [_Bubble(comment: comment, isMine: true)]
            : [
                _Bubble(comment: comment, isMine: false),
                const SizedBox(width: 6),
                _Avatar(initial: comment.senderNickname),
              ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final AuctionCommentModel comment;
  final bool isMine;
  const _Bubble({required this.comment, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.65),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (!isMine)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 4, bottom: 2),
              child: Text(comment.senderNickname,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary)),
            ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMine ? AppColors.primary : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft:
                    Radius.circular(isMine ? 4 : 14),
                bottomRight:
                    Radius.circular(isMine ? 14 : 4),
              ),
            ),
            child: Text(comment.body,
                style: TextStyle(
                    fontSize: 13,
                    color:
                        isMine ? Colors.white : AppColors.textPrimary)),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2, end: 2),
            child: Text(_fmtTime(comment.createdAt),
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textHint)),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    final ch = initial.isNotEmpty ? initial[0] : '؟';
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primaryLight,
      child: Text(ch,
          style: const TextStyle(fontSize: 12, color: AppColors.primary)),
    );
  }
}

// ── Header helpers ─────────────────────────────────────────────────────────────
class _ChatToggleChip extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;
  const _ChatToggleChip(
      {required this.enabled,
      required this.isLoading,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.divider,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: enabled
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border),
        ),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: AppColors.primary),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    enabled ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                    size: 16,
                    color: enabled
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    enabled ? 'مفعّل' : 'معطّل',
                    style: TextStyle(
                        fontSize: 12,
                        color: enabled
                            ? AppColors.primary
                            : AppColors.textSecondary),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$count رسالة',
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold)),
    );
  }
}

// ── Empty / disabled states ───────────────────────────────────────────────────
class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 40, color: AppColors.textHint),
          SizedBox(height: 10),
          Text('لا توجد تعليقات بعد',
              style: TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _DisabledPlaceholder extends StatelessWidget {
  const _DisabledPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 40, color: AppColors.textHint),
          SizedBox(height: 10),
          Text('الشات غير مفعل حالياً',
              style: TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Send button ───────────────────────────────────────────────────────────────
class _SendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onTap;
  const _SendButton({required this.isSending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSending ? null : onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: isSending
            ? const Padding(
                padding: EdgeInsets.all(11),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
