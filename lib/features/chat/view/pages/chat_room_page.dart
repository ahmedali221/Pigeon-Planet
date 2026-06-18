import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/chat_message_model.dart';
import '../../viewmodel/chat_bloc.dart';

class ChatRoomPage extends StatefulWidget {
  /// Pass [conversationId] when opening an existing conversation.
  /// Pass [receiverProfileId] when starting a new one.
  /// One of the two must be non-null.
  final int? conversationId;
  final int? receiverProfileId;
  final String partnerNickname;

  const ChatRoomPage({
    super.key,
    this.conversationId,
    this.receiverProfileId,
    required this.partnerNickname,
  }) : assert(conversationId != null || receiverProfileId != null,
            'Provide either conversationId or receiverProfileId');

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _inputHasText = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      final has = _inputController.text.trim().isNotEmpty;
      if (has != _inputHasText) setState(() => _inputHasText = has);
    });
    final bloc = context.read<ChatBloc>();
    if (widget.conversationId != null) {
      bloc.add(ChatRoomOpened(widget.conversationId!));
    } else {
      bloc.add(ChatConversationStartRequested(widget.receiverProfileId!));
    }
  }

  @override
  void dispose() {
    context.read<ChatBloc>().add(const ChatRoomClosed());
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final body = _inputController.text.trim();
    if (body.isEmpty) return;
    _inputController.clear();
    context.read<ChatBloc>().add(ChatMessageSent(body));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (prev, curr) =>
          curr.sendStatus == ChatSendStatus.error ||
          curr.roomStatus == ChatRoomStatus.error ||
          prev.messages.length != curr.messages.length,
      listener: (context, state) {
        if (state.sendStatus == ChatSendStatus.error &&
            state.sendError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.sendError!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state.roomStatus == ChatRoomStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
        // scroll to bottom when new messages arrive
        if (state.messages.isNotEmpty) _scrollToBottom();
      },
      builder: (context, state) {
        final conv = state.activeConversation;
        final myId = conv != null ? state.myProfileIdFor(conv) : -1;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.partnerNickname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (state.roomStatus == ChatRoomStatus.loading)
                  const Text(
                    'جارٍ التحميل...',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
              ],
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              // ── Messages area ─────────────────────────────────────────────
              Expanded(
                child: _buildMessages(context, state, myId),
              ),

              // ── Input box ─────────────────────────────────────────────────
              _buildInput(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessages(BuildContext context, ChatState state, int myId) {
    if (state.roomStatus == ChatRoomStatus.loading &&
        state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.roomStatus == ChatRoomStatus.error &&
        state.messages.isEmpty) {
      return Center(
        child: Text(
          state.errorMessage ?? 'فشل تحميل الرسائل',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    if (state.messages.isEmpty) {
      return const Center(
        child: Text(
          'ابدأ المحادثة بإرسال رسالة',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: state.messages.length,
      itemBuilder: (context, i) {
        final msg = state.messages[i];
        final isMine = msg.senderProfileId == myId;
        return _MessageBubble(message: msg, isMine: isMine);
      },
    );
  }

  Widget _buildInput(BuildContext context, ChatState state) {
    final isSending = state.sendStatus == ChatSendStatus.sending;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Send button — rightmost in RTL
            AnimatedOpacity(
              opacity: _inputHasText && !isSending ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 180),
              child: GestureDetector(
                onTap: _inputHasText && !isSending ? _send : null,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // TextField — expands
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _inputController,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle:
                        TextStyle(color: AppColors.textHint, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.body,
              style: TextStyle(
                fontSize: 14,
                color: isMine ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
