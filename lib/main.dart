import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/locale/locale_service.dart';
import 'features/auth/viewmodel/auth_bloc.dart';
import 'features/chat/viewmodel/chat_badge_cubit.dart';

import 'core/network/dio_client.dart';
import 'core/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await PermissionService.requestStartupPermissions();

  // Redirect to auth when a 401 is received from any API call.
  sl<DioClient>().onUnauthorized.listen((_) {
    sl<AuthBloc>().add(const AuthLogoutRequested());
  });

  runApp(const PigeonPlanetApp());
}

class PigeonPlanetApp extends StatelessWidget {
  const PigeonPlanetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ChatBadgeCubit>(
          create: (_) => sl<ChatBadgeCubit>(),
        ),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: LocaleService.notifier,
        builder: (_, locale, _) {
          return MaterialApp.router(
            title: 'Pigeon Planet',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
