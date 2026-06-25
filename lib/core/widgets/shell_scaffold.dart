import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/viewmodel/cart_bloc.dart';
import '../../features/home/view/widgets/home_bottom_nav_bar.dart';
import '../../l10n/app_localizations.dart';

class ShellScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScaffold({super.key, required this.navigationShell});

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  static const _marketIndex = 2;
  late final _ShellBackController _backController;

  @override
  void initState() {
    super.initState();
    _backController = _ShellBackController(widget.navigationShell);
    _backController.addListener(_onBackHistoryChanged);
  }

  @override
  void didUpdateWidget(ShellScaffold old) {
    super.didUpdateWidget(old);
    _backController.attach(widget.navigationShell);
    if (widget.navigationShell.currentIndex == _marketIndex &&
        old.navigationShell.currentIndex != _marketIndex) {
      context.read<CartBloc>().add(const CartStarted());
    }
  }

  @override
  void dispose() {
    _backController.removeListener(_onBackHistoryChanged);
    _backController.dispose();
    super.dispose();
  }

  void _onBackHistoryChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _ShellBackScope(
      controller: _backController,
      child: PopScope(
        canPop: !_backController.canNavigateBack,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _backController.canNavigateBack) {
            _backController.goBackOrHome();
          }
        },
        child: Scaffold(
          body: widget.navigationShell,
          bottomNavigationBar: HomeBottomNavBar(
            currentIndex: widget.navigationShell.currentIndex.clamp(0, 5),
            onTap: (index) => _onTap(context, index),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    final l = AppLocalizations.of(context);
    if (index >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.comingSoon),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _backController.goBranch(index);
  }
}

class _ShellBackScope extends InheritedNotifier<_ShellBackController> {
  const _ShellBackScope({
    super.key,
    required _ShellBackController controller,
    required super.child,
  }) : super(notifier: controller);

  static _ShellBackController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ShellBackScope>()
        ?.notifier;
  }
}

class ShellBackButton extends StatelessWidget {
  final Color? color;
  final bool reserveSpace;

  const ShellBackButton({
    super.key,
    this.color,
    this.reserveSpace = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = _ShellBackScope.maybeOf(context);
    final canGoBack = (controller?.canNavigateBack ?? false) ||
        Navigator.of(context).canPop();

    if (!canGoBack) {
      return reserveSpace ? const SizedBox(width: 48) : const SizedBox.shrink();
    }

    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: const BackButtonIcon(),
      color: color,
      onPressed: () {
        if (controller?.canNavigateBack ?? false) {
          controller!.goBackOrHome();
          return;
        }
        Navigator.of(context).maybePop();
      },
    );
  }
}

class _ShellBackController extends ChangeNotifier {
  static const _homeIndex = 0;

  _ShellBackController(this._navigationShell);

  StatefulNavigationShell _navigationShell;

  bool get isHome => _navigationShell.currentIndex == _homeIndex;
  bool get canNavigateBack => !isHome;

  void attach(StatefulNavigationShell navigationShell) {
    final previous = _navigationShell.currentIndex;
    _navigationShell = navigationShell;
    if (previous != navigationShell.currentIndex) {
      notifyListeners();
    }
  }

  void goBranch(int index) {
    final current = _navigationShell.currentIndex;
    _navigationShell.goBranch(
      index,
      initialLocation: index == current,
    );
    if (index != current) {
      notifyListeners();
    }
  }

  void goHome() {
    if (isHome) return;
    _navigationShell.goBranch(_homeIndex);
    notifyListeners();
  }

  void goBackOrHome() {
    if (!canNavigateBack) return;
    goHome();
  }
}
