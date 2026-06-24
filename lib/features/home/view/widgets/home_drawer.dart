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
import '../../../../features/chat/viewmodel/chat_badge_cubit.dart';
import '../../../../features/chat/viewmodel/chat_bloc.dart';
import '../../../../features/notifications/view/pages/notifications_page.dart';
import '../../../../features/payments/view/pages/payments_page.dart';
import '../../../../features/subscription/view/pages/packages_page.dart';
import '../../../home/viewmodel/home_bloc.dart';
import '../../../loyalty/view/pages/seller_badges_page.dart';
import '../../../profile/view/pages/profile_switcher_page.dart';

import '../../../../l10n/app_localizations.dart';
class HomeDrawer extends StatelessWidget {
  final UserModel? authUser;
  final bool isSeller;
  final int unreadCount;
  final String? sellerNickname;

  HomeDrawer({
    super.key,
    required this.authUser,
    required this.isSeller,
    required this.unreadCount,
    this.sellerNickname,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _DrawerHeader(
            authUser: authUser,
            isSeller: isSeller,
            sellerNickname: sellerNickname,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                _NotificationsTile(
                  unreadCount: unreadCount,
                  isSeller: isSeller,
                ),
                _ConversationsTile(isSeller: isSeller),
                if (isSeller) _ProfileSwitcherTile(),
                if (isSeller) _PackageTile(),
                _BadgesTile(),
                if (isSeller) _SellerOrdersTile(),
                if (isSeller) _SellerPaymentsTile(),
                if (!isSeller) _CartTile(),
                if (!isSeller) _OrdersTile(),
                if (!isSeller) _CustomerPaymentsTile(),
                _LanguageTile(),
              ],
            ),
          ),
          Divider(height: 1),
          _LogoutTile(),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final UserModel? authUser;
  final bool isSeller;
  final String? sellerNickname;

  _DrawerHeader({
    required this.authUser,
    required this.isSeller,
    this.sellerNickname,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 52, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSeller
                      ? (sellerNickname?.isNotEmpty == true
                          ? sellerNickname!
                          : AppLocalizations.of(context).sellerRole)
                      : AppLocalizations.of(context).buyerRole,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSeller)
                  Text(
                    AppLocalizations.of(context).sellerRole,
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                if ((authUser?.phoneNumber ?? '').isNotEmpty)
                  Text(
                    authUser!.phoneNumber,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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

  _NotificationsTile({
    required this.unreadCount,
    required this.isSeller,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
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
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: TextStyle(
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
      title: Text(AppLocalizations.of(context).notifications),
      onTap: () async {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationsPage()),
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

  _ConversationsTile({required this.isSeller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBadgeCubit, int>(
      builder: (context, chatUnread) => ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
            if (chatUnread > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      chatUnread > 99 ? '99+' : '$chatUnread',
                      style: TextStyle(
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
        title: Text(AppLocalizations.of(context).myConversations),
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
                child: ConversationsPage(),
              ),
            ),
          ).then((_) {
            if (context.mounted) sl<ChatBadgeCubit>().refresh();
          });
        },
      ),
    );
  }
}

class _ProfileSwitcherTile extends StatelessWidget {
  _ProfileSwitcherTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.switch_account_rounded,
        color: AppColors.primary,
        size: 24,
      ),
      title: Text(AppLocalizations.of(context).switchProfile),
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
  _PackageTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.workspace_premium_rounded,
        color: AppColors.primary,
        size: 24,
      ),
      title: Text(AppLocalizations.of(context).myPackage),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PackagesPage()),
        );
      },
    );
  }
}

class _BadgesTile extends StatelessWidget {
  _BadgesTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.military_tech_rounded,
        color: AppColors.orange,
        size: 24,
      ),
      title: Text(AppLocalizations.of(context).myBadges),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SellerBadgesPage()),
        );
      },
    );
  }
}

class _SellerOrdersTile extends StatelessWidget {
  _SellerOrdersTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.receipt_long_outlined,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: Text(AppLocalizations.of(context).customerOrders),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CartBloc>(),
              child: SellerOrdersPage(),
            ),
          ),
        );
      },
    );
  }
}

class _SellerPaymentsTile extends StatelessWidget {
  _SellerPaymentsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.payment_rounded,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: Text(AppLocalizations.of(context).paymentRequests),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaymentsPage()),
        );
      },
    );
  }
}

class _CartTile extends StatelessWidget {
  _CartTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) => ListTile(
        leading: Badge(
          isLabelVisible: cartState.itemsCount > 0,
          label: Text('${cartState.itemsCount}'),
          child: Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        title: Text(AppLocalizations.of(context).shoppingCart),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CartBloc>(),
                child: CartPage(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrdersTile extends StatelessWidget {
  _OrdersTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: Text(AppLocalizations.of(context).myOrders),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CartBloc>(),
              child: OrdersPage(),
            ),
          ),
        );
      },
    );
  }
}

class _CustomerPaymentsTile extends StatelessWidget {
  _CustomerPaymentsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.payment_rounded,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: Text(AppLocalizations.of(context).paymentRequests),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaymentsPage()),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  _LanguageTile();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.notifier,
      builder: (_, locale, _) {
        final isAr = locale.languageCode == 'ar';
        return ListTile(
          leading: Icon(
            Icons.language_rounded,
            color: AppColors.textPrimary,
            size: 24,
          ),
          title: Text(AppLocalizations.of(context).language),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              isAr ? 'EN' : 'ع',
              style: TextStyle(
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
  _LogoutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 24),
      title: Text(
        AppLocalizations.of(context).logout,
        style: TextStyle(color: Colors.red.shade400),
      ),
      onTap: () {
        final authBloc = context.read<AuthBloc>();
        final l10n = AppLocalizations.of(context);
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.logout),
            content: Text(l10n.logoutConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  authBloc.add(AuthLogoutRequested());
                },
                child: Text(
                  AppLocalizations.of(context).logout,
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
