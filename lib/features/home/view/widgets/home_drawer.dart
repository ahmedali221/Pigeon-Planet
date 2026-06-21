import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/locale/locale_service.dart';
import '../../../../features/auth/model/user_model.dart';
import '../../../../features/auth/viewmodel/auth_bloc.dart';
import '../../../../features/cart/view/pages/cart_page.dart';
import '../../../../features/cart/view/pages/orders_page.dart';
import '../../../../features/cart/view/pages/seller_orders_page.dart';
import '../../../../features/cart/viewmodel/cart_bloc.dart';
import '../../../../features/chat/view/pages/conversations_page.dart';
import '../../../../features/chat/viewmodel/chat_bloc.dart';
import '../../../../features/notifications/view/pages/notifications_page.dart';
import '../../../../features/payments/view/pages/payments_page.dart';
import '../../../../features/subscription/view/pages/packages_page.dart';
import '../../../home/viewmodel/home_bloc.dart';
import '../../../loyalty/view/pages/seller_badges_page.dart';
import '../../../profile/view/pages/profile_switcher_page.dart';

class HomeDrawer extends StatelessWidget {
  final UserModel? authUser;
  final bool isSeller;
  final int unreadCount;

  const HomeDrawer({
    super.key,
    required this.authUser,
    required this.isSeller,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _DrawerHeader(authUser: authUser, isSeller: isSeller),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NotificationsTile(
                  unreadCount: unreadCount,
                  isSeller: isSeller,
                ),
                _ConversationsTile(isSeller: isSeller),
                if (isSeller) const _ProfileSwitcherTile(),
                if (isSeller) const _PackageTile(),
                const _BadgesTile(),
                if (isSeller) const _SellerOrdersTile(),
                if (isSeller) const _SellerPaymentsTile(),
                if (!isSeller) const _CartTile(),
                if (!isSeller) const _OrdersTile(),
                if (!isSeller) const _CustomerPaymentsTile(),
                const _LanguageTile(),
              ],
            ),
          ),
          const Divider(height: 1),
          const _LogoutTile(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final UserModel? authUser;
  final bool isSeller;

  const _DrawerHeader({required this.authUser, required this.isSeller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSeller ? 'بائع' : 'مشتري',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if ((authUser?.phoneNumber ?? '').isNotEmpty)
                  Text(
                    authUser!.phoneNumber,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsTile extends StatelessWidget {
  final int unreadCount;
  final bool isSeller;

  const _NotificationsTile({
    required this.unreadCount,
    required this.isSeller,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
          if (unreadCount > 0)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: const Text('الإشعارات'),
      onTap: () async {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
        if (context.mounted) {
          context
              .read<HomeBloc>()
              .add(HomeRefreshRequested(isSeller: isSeller));
        }
      },
    );
  }
}

class _ConversationsTile extends StatelessWidget {
  final bool isSeller;

  const _ConversationsTile({required this.isSeller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.chat_bubble_outline_rounded,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: const Text('محادثاتي'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<ChatBloc>()
                ..add(ChatStarted(
                  profileType: isSeller ? 'Seller' : 'Customer',
                )),
              child: const ConversationsPage(),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileSwitcherTile extends StatelessWidget {
  const _ProfileSwitcherTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.switch_account_rounded,
        color: AppColors.primary,
        size: 24,
      ),
      title: const Text('تبديل الملف الشخصي'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          ProfileSwitcherPage.route(context.read<AuthBloc>()),
        );
      },
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.workspace_premium_rounded,
        color: AppColors.primary,
        size: 24,
      ),
      title: const Text('باقتي'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PackagesPage()),
        );
      },
    );
  }
}

class _BadgesTile extends StatelessWidget {
  const _BadgesTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.military_tech_rounded,
        color: AppColors.orange,
        size: 24,
      ),
      title: const Text('أوسمتي'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SellerBadgesPage()),
        );
      },
    );
  }
}

class _SellerOrdersTile extends StatelessWidget {
  const _SellerOrdersTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.receipt_long_outlined,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: const Text('طلبات العملاء'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CartBloc>(),
              child: const SellerOrdersPage(),
            ),
          ),
        );
      },
    );
  }
}

class _SellerPaymentsTile extends StatelessWidget {
  const _SellerPaymentsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.payment_rounded,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: const Text('طلبات الدفع'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentsPage()),
        );
      },
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) => ListTile(
        leading: Badge(
          isLabelVisible: cartState.itemsCount > 0,
          label: Text('${cartState.itemsCount}'),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        title: const Text('سلة الشراء'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CartBloc>(),
                child: const CartPage(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrdersTile extends StatelessWidget {
  const _OrdersTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: const Text('طلباتي'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CartBloc>(),
              child: const OrdersPage(),
            ),
          ),
        );
      },
    );
  }
}

class _CustomerPaymentsTile extends StatelessWidget {
  const _CustomerPaymentsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.payment_rounded,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: const Text('طلبات الدفع'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentsPage()),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.notifier,
      builder: (_, locale, _) {
        final isAr = locale.languageCode == 'ar';
        return ListTile(
          leading: const Icon(
            Icons.language_rounded,
            color: AppColors.textPrimary,
            size: 24,
          ),
          title: const Text('اللغة'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              isAr ? 'EN' : 'ع',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: LocaleService.toggle,
        );
      },
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 24),
      title: Text(
        'تسجيل الخروج',
        style: TextStyle(color: Colors.red.shade400),
      ),
      onTap: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
                child: Text(
                  'تسجيل خروج',
                  style: TextStyle(color: Colors.red.shade400),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
