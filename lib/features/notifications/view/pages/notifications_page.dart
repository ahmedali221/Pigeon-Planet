import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/notification_model.dart';
import '../../viewmodel/notifications_bloc.dart';
import '../data/notifications_mock_data.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsBloc>(
      create: (_) =>
          sl<NotificationsBloc>()..add(const NotificationsStarted()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  int _tabIndex = 0;

  List<NotificationModel> _filtered(List<NotificationModel> all) {
    return all.where((n) {
      if (n.profileType == 'All' || n.profileType.isEmpty) return true;
      if (_tabIndex == 0) return n.profileType == 'Customer';
      return n.profileType == 'Seller';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listenWhen: (p, c) => p.isActing && !c.isActing,
      listener: (context, state) {
        if (state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('تعذر تحديث حالة الإشعار'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == NotificationsStatus.loading;

        final items = _filtered(
          state.notifications.isNotEmpty
              ? state.notifications
              : NotificationsMockData.forTab(_tabIndex),
        );
        final unread = items.where((n) => !n.isRead).length;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Column(
            children: [
              _NotificationsHeader(
                onBack: () => Navigator.pop(context),
                onRefresh: isLoading
                    ? null
                    : () => context
                        .read<NotificationsBloc>()
                        .add(const NotificationsRefreshRequested()),
              ),
              _TabBar(
                selectedIndex: _tabIndex,
                onTap: (i) => setState(() => _tabIndex = i),
              ),
              if (unread > 0) _UnreadBanner(count: unread),
              Expanded(
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      )
                    : state.status == NotificationsStatus.error &&
                            state.notifications.isEmpty
                        ? _ErrorView(
                            message: state.errorMessage,
                            onRetry: () => context
                                .read<NotificationsBloc>()
                                .add(const NotificationsRefreshRequested()),
                          )
                        : items.isEmpty
                            ? const _EmptyView()
                            : RefreshIndicator(
                                color: AppColors.primary,
                                onRefresh: () async => context
                                    .read<NotificationsBloc>()
                                    .add(const NotificationsRefreshRequested()),
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) => const Divider(
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: AppColors.divider,
                                  ),
                                  itemBuilder: (context, i) {
                                    final item = items[i];
                                    return _NotificationTile(
                                      item: item,
                                      onMarkRead: item.id > 0 && !item.isRead
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
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  const _NotificationsHeader({required this.onBack, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'الإشعارات',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon:
                  const Icon(Icons.refresh_rounded, color: Colors.white),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _TabBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const tabs = ['مشتري', 'بائع'];
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = selectedIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? AppColors.primary
                              : Colors.white),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Unread banner ─────────────────────────────────────────────────────────────

class _UnreadBanner extends StatelessWidget {
  final int count;
  const _UnreadBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'لديك $count إشعار غير مقروء',
          textAlign: TextAlign.start,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Empty & error states ──────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: AppColors.textHint),
          SizedBox(height: 12),
          Text('لا توجد إشعارات',
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

  const _ErrorView({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message ?? 'فشل تحميل الإشعارات',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('إعادة المحاولة'),
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

  const _NotificationTile({required this.item, this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead ? Colors.white : AppColors.primaryLight,
      child: InkWell(
        onTap: onMarkRead,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(type: item.type),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.tag,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(top: 6, start: 10),
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
  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color bg, Color fg) = switch (type) {
      NotificationType.auctionWon => (
        Icons.emoji_events_rounded,
        const Color(0xFFFFF8E1),
        const Color(0xFFF9A825),
      ),
      NotificationType.bidAccepted => (
        Icons.check_circle_rounded,
        AppColors.primaryLight,
        AppColors.primary,
      ),
      NotificationType.newBid => (
        Icons.trending_up_rounded,
        const Color(0xFFFFEBEE),
        const Color(0xFFE53935),
      ),
      NotificationType.newBadge => (
        Icons.military_tech_rounded,
        const Color(0xFFFFF8E1),
        const Color(0xFFF9A825),
      ),
      NotificationType.payment => (
        Icons.payment_rounded,
        AppColors.blueLight,
        AppColors.blue,
      ),
      NotificationType.order => (
        Icons.shopping_bag_outlined,
        AppColors.primaryLight,
        AppColors.primary,
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
