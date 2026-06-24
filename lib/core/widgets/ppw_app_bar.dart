import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final canPop = Navigator.canPop(context);

    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && showBackButton && canPop) {
      resolvedLeading = IconButton(
        icon: Icon(
          isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
          size: 20,
          color: foregroundColor,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      );
    }

    final resolvedTitle = titleWidget ??
        (title != null
            ? Text(
                title!,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null);

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false,
      leading: resolvedLeading,
      centerTitle: centerTitle,
      title: resolvedTitle,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
