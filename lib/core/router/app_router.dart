import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../widgets/shell_scaffold.dart';
import 'routes.dart';
import '../../features/auth/view/pages/account_type_page.dart';
import '../../features/auth/viewmodel/auth_bloc.dart';
import '../../features/cart/viewmodel/cart_bloc.dart';
import '../../features/feed/viewmodel/feed_bloc.dart';
import '../../features/home/view/pages/home_page.dart';
import '../../features/auctions/view/pages/auctions_page.dart';
import '../../features/market/view/pages/market_page.dart';
import '../../features/rooms/view/pages/rooms_page.dart';
import '../../features/races/view/pages/races_page.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();
  static final _homeKey = GlobalKey<NavigatorState>();
  static final _auctionsKey = GlobalKey<NavigatorState>();
  static final _marketKey = GlobalKey<NavigatorState>();
  static final _roomsKey = GlobalKey<NavigatorState>();
  static final _racesKey = GlobalKey<NavigatorState>();

  static final _refresh = _GoRouterRefreshStream(sl<AuthBloc>().stream);

  static final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.loading,
    refreshListenable: _refresh,
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;
      final loc = state.matchedLocation;

      if (authState is AuthLoading) {
        return loc == AppRoutes.loading ? null : AppRoutes.loading;
      }

      final authed = authState is AuthSuccess ||
          authState is AuthSwitchingProfile ||
          authState is AuthProfileSwitchFailure;

      if (!authed) {
        return loc == AppRoutes.auth ? null : AppRoutes.auth;
      }

      if (loc == AppRoutes.loading || loc == AppRoutes.auth) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      // ── Splash while AuthBloc initialises ──────────────────────────────────
      GoRoute(
        path: AppRoutes.loading,
        builder: (_, _) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),

      // ── Auth (unauthenticated entry point) ─────────────────────────────────
      GoRoute(
        path: AppRoutes.auth,
        builder: (_, _) => const AccountTypePage(),
      ),

      // ── Persistent shell with 5 bottom-nav tabs ────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<CartBloc>(
                create: (_) => sl<CartBloc>()..add(const CartStarted()),
              ),
              BlocProvider<FeedBloc>(
                create: (_) => sl<FeedBloc>(),
              ),
            ],
            child: ShellScaffold(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _auctionsKey,
            routes: [
              GoRoute(
                path: AppRoutes.auctions,
                builder: (_, _) => AuctionsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _marketKey,
            routes: [
              GoRoute(
                path: AppRoutes.market,
                builder: (_, _) => MarketPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _roomsKey,
            routes: [
              GoRoute(
                path: AppRoutes.rooms,
                builder: (_, _) => RoomsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _racesKey,
            routes: [
              GoRoute(
                path: AppRoutes.races,
                builder: (_, _) => RacesPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// Bridges a BLoC stream into a Listenable that go_router can watch.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
