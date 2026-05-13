import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/locale/locale_service.dart';
import 'features/auth/view/pages/account_type_page.dart';
import 'features/auth/viewmodel/auth_bloc.dart';
import 'features/home/view/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const PigeonPlanetApp());
}

class PigeonPlanetApp extends StatelessWidget {
  const PigeonPlanetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.notifier,
      builder: (_, locale, _) {
        return MaterialApp(
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
          home: BlocProvider(
            create: (_) =>
                sl<AuthBloc>()..add(const AuthCheckRequested()),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthSuccess ||
                    state is AuthSwitchingProfile ||
                    state is AuthProfileSwitchFailure) {
                  return const HomePage();
                }
                if (state is AuthLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const AccountTypePage();
              },
            ),
          ),
        );
      },
    );
  }
}
