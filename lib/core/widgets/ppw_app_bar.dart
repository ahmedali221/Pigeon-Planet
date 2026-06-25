import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../di/injection.dart';
import '../../features/auth/viewmodel/auth_bloc.dart';
import '../../features/cart/view/pages/cart_page.dart';
import '../../features/cart/viewmodel/cart_bloc.dart';
import '../../l10n/app_localizations.dart';

class PPWAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PPWAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.elevation = 0,
    this.onBackPressed,
    this.centerTitle = true,
    this.bottom,
    this.showCartAction = true,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final bool showCartAction;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final canPop = Navigator.canPop(context);

    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && showBackButton && canPop) {
      resolvedLeading = IconButton(
        icon: Icon(
          isRtl
              ? Icons.arrow_forward_ios_rounded
              : Icons.arrow_back_ios_rounded,
          size: 20,
          color: foregroundColor,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      );
    }

    final resolvedTitle =
        titleWidget ??
        (title != null
            ? Text(
                title!,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const _PigeonPlanetLogo());

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false,
      leading: resolvedLeading,
      centerTitle: centerTitle,
      title: resolvedTitle,
      actions: [
        ...?actions,
        if (showCartAction) _CustomerCartAction(color: foregroundColor),
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class _CustomerCartAction extends StatelessWidget {
  const _CustomerCartAction({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, bool>(
      selector: (state) {
        if (state is AuthSuccess) return state.user.isCustomer;
        if (state is AuthSwitchingProfile) return state.user.isCustomer;
        if (state is AuthProfileSwitchFailure) return state.user.isCustomer;
        return false;
      },
      builder: (context, isCustomer) {
        if (!isCustomer) return const SizedBox.shrink();

        final cartBloc = sl<CartBloc>();
        return BlocBuilder<CartBloc, CartState>(
          bloc: cartBloc,
          buildWhen: (previous, current) =>
              previous.itemsCount != current.itemsCount,
          builder: (context, state) {
            return IconButton(
              tooltip: AppLocalizations.of(context).cartTitle,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.shopping_cart_outlined, color: color),
                  if (state.itemsCount > 0)
                    PositionedDirectional(
                      top: -7,
                      end: -7,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          state.itemsCount > 99 ? '99+' : '${state.itemsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                if (cartBloc.state.status == CartStatus.initial) {
                  cartBloc.add(const CartStarted());
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cartBloc,
                      child: const CartPage(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PigeonPlanetLogo extends StatelessWidget {
  const _PigeonPlanetLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: SvgPicture.asset('assets/brand/logo.svg', fit: BoxFit.contain),
    );
  }
}
