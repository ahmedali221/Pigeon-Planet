import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/notification_model.dart';
import '../../viewmodel/notifications_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class NotificationsPage extends StatelessWidget {
  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsBloc>(
      create: (_) => sl<NotificationsBloc>()..add(NotificationsStarted()),
      child: _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listenWhen: (p, c) => p.isActing && !c.isActing,
      listener: (context, state) {
        if (state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).notificationUpdateError),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      buildWhen: (p, c) =>
          p.status != c.status ||
          p.notifications != c.notifications ||
          p.unreadCount != c.unreadCount,
      builder: (context, state) {
        final isLoading = state.status == NotificationsStatus.loading;
        final unread = state.unreadCount;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Column(
            children: [
              _NotificationsHeader(
                unreadCount: unread,
                isLoading: isLoading,
                onBack: () => Navigator.pop(context),
                onRefresh: () => context
                    .read<NotificationsBloc>()
                    .add(NotificationsRefreshRequested()),
                onMarkAll: unread > 0
                    ? () => context
                        .read<NotificationsBloc>()
                        .add(NotificationMarkAllReadRequested())
                    : null,
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      )
                    : state.status == NotificationsStatus.error &&
                            state.notifications.isEmpty
                        ? _ErrorView(
                            message: state.errorMessage,
                            onRetry: () => context
                                .read<NotificationsBloc>()
                                .add(NotificationsRefreshRequested()),
                          )
                        : state.notifications.isEmpty
                            ? _EmptyView()
                            : RefreshIndicator(
                                color: AppColors.primary,
                                onRefresh: () async => context
                                    .read<NotificationsBloc>()
                                    .add(NotificationsRefreshRequested()),
                                child: ListView.separated(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 8),
                                  itemCount: state.notifications.length +
                                      (state.hasMore ? 1 : 0),
                                  separatorBuilder: (_, i) {
                                    if (i >= state.notifications.length - 1) {
                                      return SizedBox.shrink();
                                    }
                                    return Divider(
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                      color: AppColors.divider,
                                    );
                                  },
                                  itemBuilder: (context, i) {
                                    if (i == state.notifications.length) {
                                      return _LoadMoreButton(
                                        loading: state.status ==
                                            NotificationsStatus.loadingMore,
                                        onTap: () => context
                                            .read<NotificationsBloc>()
                                            .add(NotificationsLoadMoreRequested()),
                                      );
                                    }
                                    final item = state.notifications[i];
                                    return _NotificationTile(
                                      item: item,
                                      onMarkRead: !item.isRead
                                          ? () => context
                                              .read<NotificationsBloc>()
                                              .add(NotificationMarkReadRequested(
                                                  item.id))
                                          : null,
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback? onMarkAll;

  _NotificationsHeader({
    required this.unreadCount,
    required this.isLoading,
    required this.onBack,
    required this.onRefresh,
    this.onMarkAll,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: unreadCount > 0 ? 0 : 14,
        left: 16,
        right: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 20),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).notifications,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (onMarkAll != null)
                TextButton(
                  onPressed: onMarkAll,
                  child: Text(
                    'قراءة الكل',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else
                IconButton(
                  onPressed: isLoading ? null : onRefresh,
                  icon: Icon(Icons.refresh_rounded, color: Colors.white),
                ),
            ],
          ),
          if (unreadCount > 0)
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(0, 8, 0, 12),
              padding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'لديك $unreadCount إشعار غير مقروء',
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty & error states ──────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(AppLocalizations.of(context).noNotifications,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  _ErrorView({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: 12),
            Text(message ?? 'فشل تحميل الإشعارات',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback? onMarkRead;

  _NotificationTile({required this.item, this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead ? Colors.white : AppColors.primaryLight,
      child: InkWell(
        onTap: onMarkRead,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(type: item.type),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: item.isRead
                              ? FontWeight.w600
                              : FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    if (item.body.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        item.body,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5),
                      ),
                    ],
                    SizedBox(height: 8),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(top: 6, start: 10),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isRead
                        ? Colors.transparent
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Type icon ─────────────────────────────────────────────────────────────────

class _NotificationIcon extends StatelessWidget {
  final NotificationType type;
  _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color bg, Color fg) = switch (type) {
      NotificationType.auctionWon => (
        Icons.emoji_events_rounded,
        Color(0xFFFFF8E1),
        Color(0xFFF9A825),
      ),
      NotificationType.auctionOutbid => (
        Icons.trending_up_rounded,
        Color(0xFFFFEBEE),
        Color(0xFFE53935),
      ),
      NotificationType.orderItemApproved => (
        Icons.check_circle_rounded,
        AppColors.primaryLight,
        AppColors.primary,
      ),
      NotificationType.orderItemRejected => (
        Icons.cancel_rounded,
        Color(0xFFFFEBEE),
        Color(0xFFE53935),
      ),
      NotificationType.paymentRequestCreated => (
        Icons.payment_rounded,
        AppColors.blueLight,
        AppColors.blue,
      ),
      NotificationType.paymentRequestApproved => (
        Icons.verified_rounded,
        AppColors.primaryLight,
        AppColors.primary,
      ),
      NotificationType.paymentRequestRejected => (
        Icons.money_off_rounded,
        Color(0xFFFFEBEE),
        Color(0xFFE53935),
      ),
      NotificationType.chatMessageReceived => (
        Icons.chat_bubble_rounded,
        AppColors.blueLight,
        AppColors.blue,
      ),
      NotificationType.complaintCreated => (
        Icons.report_rounded,
        Color(0xFFFFF3E0),
        Color(0xFFE65100),
      ),
      NotificationType.complaintStatusUpdated => (
        Icons.update_rounded,
        Color(0xFFFFF3E0),
        Color(0xFFE65100),
      ),
      NotificationType.cashbackEarned => (
        Icons.savings_rounded,
        Color(0xFFE8F5E9),
        Color(0xFF2E7D32),
      ),
      NotificationType.badgeAwarded => (
        Icons.military_tech_rounded,
        Color(0xFFFFF8E1),
        Color(0xFFF9A825),
      ),
      NotificationType.packageExpiringSoon => (
        Icons.timer_rounded,
        Color(0xFFFFF3E0),
        Color(0xFFE65100),
      ),
      NotificationType.manualManagerNotification => (
        Icons.admin_panel_settings_rounded,
        Color(0xFFEDE7F6),
        Color(0xFF6A1B9A),
      ),
      NotificationType.auctionBidPlaced => (
        Icons.gavel_rounded,
        AppColors.primaryLight,
        AppColors.primary,
      ),
      NotificationType.auctionBuyNowSuccess => (
        Icons.flash_on_rounded,
        Color(0xFFFFF3E0),
        Color(0xFFEF6C00),
      ),
      NotificationType.orderItemPendingSeller => (
        Icons.hourglass_top_rounded,
        AppColors.blueLight,
        AppColors.blue,
      ),
      NotificationType.orderItemAutoCancelled => (
        Icons.cancel_schedule_send_rounded,
        Color(0xFFFFEBEE),
        Color(0xFFE53935),
      ),
      NotificationType.unknown => (
        Icons.notifications_rounded,
        AppColors.pageBackground,
        AppColors.textSecondary,
      ),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 22),
    );
  }
}

// ── Load more button ──────────────────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  _LoadMoreButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton(
          onPressed: loading ? null : onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.primary),
                )
              : Text(AppLocalizations.of(context).loadMore,
                  style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
