import 'dart:io';
import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// Import App Files
import 'utilities/dev/http_overrides.dart';
import 'common/themes.dart';
import 'routes/router.dart';
import 'routes/router.gr.dart';
import 'utilities/functions.dart';
import 'screens/error/error_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'states/apptheme_state.dart';
import 'states/system_state.dart';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides(); /* For Development Only */
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final appRouter = AppRouter();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
          Locale('de', 'DE'),
          Locale('el', 'GR'),
          Locale('es', 'ES'),
          Locale('fr', 'FR'),
          Locale('it', 'IT'),
          Locale('nl', 'NL'),
          Locale('pt', 'BR'),
          Locale('pt', 'PT'),
          Locale('ro', 'RO'),
          Locale('ru', 'RU'),
          Locale('tr', 'TR'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: MyApp(appRouter: appRouter),
      ),
    ),
  );
  await initOneSignal(appRouter);
}

class MyApp extends ConsumerWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(systemConfigProvider).when(
          loading: () => LoadingScreen(),
          error: (error, _) => ErrorScreen(message: error.toString()),
          data: (_) {
            final $system = ref.watch(systemProvider);
            final $user = ref.watch(userProvider);
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: $system['system_title'],
              theme: appTheme(context: context),
              darkTheme: appTheme(context: context, isDark: true),
              themeMode: ref.watch(appThemeModeProvider).value ?? ThemeMode.light,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              routerDelegate: appRouter.delegate(
                deepLinkBuilder: (_) => DeepLink(
                  [$user.isNotEmpty ? goHome(ref, context: context, returnRoute: true) : const SplashRoute()],
                ),
              ),
              routeInformationParser: appRouter.defaultRouteParser(),
            );
          },
        );
  }
}
