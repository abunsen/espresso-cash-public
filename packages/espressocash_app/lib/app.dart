import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'di.dart';
import 'features/accounts/services/accounts_bloc.dart';
import 'features/analytics/analytics_manager.dart';
import 'features/app_lock/app_lock.dart';
import 'features/authenticated/screens/authenticated_flow_screen.dart';
import 'features/sign_in/screens/sign_in_flow_screen.dart';
import 'l10n/gen/app_localizations.dart';
import 'routes.dart';
import 'ui/loader.dart';
import 'ui/splash_screen.dart';
import 'ui/theme.dart';

class EspressoCashApp extends StatefulWidget {
  const EspressoCashApp({super.key});

  @override
  State<EspressoCashApp> createState() => _EspressoCashAppState();
}

class _EspressoCashAppState extends State<EspressoCashApp> {
  final _router = AppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CpTheme(
        theme: const CpThemeData.light(),
        child: Builder(
          builder: (context) {
            final isAuthenticated = context
                .select<AccountsBloc, bool>((b) => b.state.account != null);
            final isLoading =
                context.select<AccountsBloc, bool>((b) => b.state.isProcessing);

            return MaterialApp.router(
              routeInformationParser: _router.defaultRouteParser(),
              routerDelegate: AutoRouterDelegate.declarative(
                _router,
                routes: (_) => [
                  if (isAuthenticated)
                    AuthenticatedFlowScreen.route()
                  else if (isLoading)
                    SplashScreen.route()
                  else
                    SignInFlowScreen.route(),
                ],
                navigatorObservers: () => [
                  sl<AnalyticsManager>().analyticsObserver,
                ],
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              title: 'Espresso Cash',
              theme: context.watch<CpThemeData>().toMaterialTheme(),
              builder: (context, child) => CpLoader(
                isLoading: isLoading,
                child: AppLockModule(child: child),
              ),
            );
          },
        ),
      );
}
