import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/datasources/notifications_remote_datasource.dart';
import '../data/notifications_mock_data.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _tabIndex = 0;
  List<NotificationItem>? _remoteItems;
  bool _remoteLoadDone = false;

  @override
  void initState() {
    super.initState();
    _loadRemote();
  }

  Future<void> _loadRemote() async {
    try {
      final raw = await sl<NotificationsRemoteDataSource>().fetchNotifications();
      if (!mounted) return;
      final mapped = raw.map(_notificationFromApi).toList();
      setState(() {
        _remoteItems = mapped;
        _remoteLoadDone = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _remoteItems = null;
        _remoteLoadDone = true;
      });
    }
  }

  List<NotificationItem> get _items {
    if (_remoteItems != null && _remoteItems!.isNotEmpty) {
      return _remoteItems!.where((n) {
        if (n.tag == 'عام') return true;
        if (_tabIndex == 0) return n.tag == 'مشتري';
        return n.tag == 'بائع';
      }).toList();
    }
    return _tabIndex == 0
        ? NotificationsMockData.buyerNotifications
        : NotificationsMockData.sellerNotifications;
  }

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> _markRead(NotificationItem item) async {
    final id = item.apiId;
    if (id == null || item.isRead) return;
    try {
      await sl<NotificationsRemoteDataSource>().markRead(id);
      if (!mounted) return;
      setState(() {
        if (_remoteItems != null) {
          _remoteItems = _remoteItems!
              .map(
                (n) => n.apiId == id
                    ? NotificationItem(
                        title: n.title,
                        body: n.body,
                        timeAgo: n.timeAgo,
                        isRead: true,
                        type: n.type,
                        tag: n.tag,
                        apiId: n.apiId,
                      )
                    : n,
              )
              .toList();
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحديث حالة الإشعار'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _NotificationsHeader(
            onBack: () => Navigator.pop(context),
            onRefresh: _remoteLoadDone ? _loadRemote : null,
          ),
          _TabBar(
            selectedIndex: _tabIndex,
            onTap: (i) => setState(() => _tabIndex = i),
          ),
          if (_unreadCount > 0) _UnreadBanner(count: _unreadCount),
          Expanded(
            child: !_remoteLoadDone
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      return _NotificationTile(
                        item: item,
                        onMarkRead: item.apiId != null && !item.isRead
                            ? () => _markRead(item)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

NotificationType _mapKind(String kind) {
  final k = kind.toLowerCase();
  if (k.contains('order') || k.contains('sold') || k.contains('won')) {
    return NotificationType.auctionWon;
  }
  if (k.contains('accept')) return NotificationType.bidAccepted;
  if (k.contains('badge') || k.contains('وسام')) {
    return NotificationType.newBadge;
  }
  return NotificationType.newBid;
}

String _arTimeHintFromIso(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  final now = DateTime.now().toUtc();
  var secs = now.difference(dt.toUtc()).inSeconds;
  if (secs < 0) secs = 0;
  if (secs < 60) return 'الآن';
  if (secs < 3600) {
    final m = secs ~/ 60;
    return m == 1 ? 'منذ دقيقة' : 'منذ $m دقيقة';
  }
  if (secs < 86400) {
    final h = secs ~/ 3600;
    return h == 1 ? 'منذ ساعة' : 'منذ $h ساعة';
  }
  final d = secs ~/ 86400;
  return d == 1 ? 'منذ يوم' : 'منذ $d يوم';
}

NotificationItem _notificationFromApi(Map<String, dynamic> j) {
  final id = (j['id'] as num?)?.toInt();
  final kind = j['kind'] as String? ?? '';
  final title = j['title'] as String? ?? '';
  final body = j['body'] as String? ?? '';
  final readAt = j['read_at'];
  final created = j['created'] as String?;
  final pt = j['profile_type'] as String? ?? 'All';
  String tag;
  if (pt == 'Seller') {
    tag = 'بائع';
  } else if (pt == 'Customer') {
    tag = 'مشتري';
  } else {
    tag = 'عام';
  }
  return NotificationItem(
    title: title,
    body: body.isEmpty ? ' ' : body,
    timeAgo: _arTimeHintFromIso(created),
    isRead: readAt != null,
    type: _mapKind(kind),
    tag: tag,
    apiId: id,
  );
}

// ── Header ────────────────────────────────────────────────────────────────────
class _NotificationsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final Future<void> Function()? onRefresh;

  const _NotificationsHeader({
    required this.onBack,
    this.onRefresh,
  });

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
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'الإشعارات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (onRefresh != null)
            IconButton(
              onPressed: () => onRefresh!(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
                        color: selected ? AppColors.primary : Colors.white,
                      ),
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
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final Future<void> Function()? onMarkRead;

  const _NotificationTile({
    required this.item,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead ? Colors.white : AppColors.primaryLight,
      child: InkWell(
        onTap: onMarkRead == null
            ? null
            : () async {
                await onMarkRead!();
              },
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
                        fontWeight:
                            item.isRead ? FontWeight.w600 : FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.tag,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 10),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isRead ? Colors.transparent : AppColors.primary,
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

// ── Type icon ────────────────────────────────────────────────────────────────
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
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 22),
    );
  }
}
