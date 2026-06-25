import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/chat_conversation_model.dart';
import '../../viewmodel/chat_bloc.dart';
import 'chat_room_page.dart';

import '../../../../l10n/app_localizations.dart';
class ConversationsPage extends StatelessWidget {
  ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          // ── Green header ──────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).conversationsTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.conversationsStatus == ChatStatus.loading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state.conversationsStatus == ChatStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 48),
                        SizedBox(height: 12),
                        Text(
                          state.errorMessage ?? AppLocalizations.of(context).errorOccurred2,
                          style: TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.read<ChatBloc>().add(
                              ChatStarted(
                                  profileType: state.myProfileType)),
                          child: Text(AppLocalizations.of(context).retry),
                        ),
                      ],
                    ),
                  );
                }
                if (state.conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chat_bubble_outline_rounded,
                              size: 52, color: AppColors.primary),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد محادثات بعد',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'تواصل مع البائعين من صفحة ملفاتهم الشخصية',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<ChatBloc>().add(
                      ChatStarted(profileType: state.myProfileType)),
                  child: ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: state.conversations.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final conv = state.conversations[i];
                      return _ConversationTile(
                        conversation: conv,
                        partnerNickname: state.partnerNicknameFor(conv),
                        onTap: () => _openRoom(context, state, conv),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openRoom(
      BuildContext context, ChatState state, ChatConversationModel conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: ChatRoomPage(
            conversationId: conv.id,
            partnerNickname: state.partnerNicknameFor(conv),
          ),
        ),
      ),
    );
  }
}

// ── Conversation tile ─────────────────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final ChatConversationModel conversation;
  final String partnerNickname;
  final VoidCallback onTap;

  _ConversationTile({
    required this.conversation,
    required this.partnerNickname,
    required this.onTap,
  });

  String _formatTime(BuildContext context, DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppLocalizations.of(context).now3;
    if (diff.inMinutes < 60) return AppLocalizations.of(context).mnthD(diff.inMinutes);
    if (diff.inHours < 24) return AppLocalizations.of(context).mnthS(diff.inHours);
    if (diff.inDays < 7) return AppLocalizations.of(context).mnthAyam(diff.inDays);
    return DateFormat('d/M').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar — rightmost in RTL
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                partnerNickname.isNotEmpty
                    ? partnerNickname.characters.first
                    : '؟',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(width: 12),

            // Name + last message — center
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnerNickname,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hasUnread
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (conversation.lastMessage != null &&
                      conversation.lastMessage!.isNotEmpty) ...[
                    SizedBox(height: 3),
                    Text(
                      conversation.lastMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: hasUnread
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 8),

            // Time + unread badge — leftmost in RTL
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(context, conversation.lastMessageAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: hasUnread ? AppColors.primary : AppColors.textHint,
                  ),
                ),
                if (hasUnread) ...[
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      conversation.unreadCount > 99
                          ? '99+'
                          : '${conversation.unreadCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
