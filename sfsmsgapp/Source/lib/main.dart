import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 
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
import 'states/apptheme_state.dart';
import 'states/system_state.dart';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides(); /* For Development Only */
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Pre-load system configuration BEFORE running the app
  final container = ProviderContainer();
  await container.read(systemConfigProvider.future);
  
  final appRouter = AppRouter();
  runApp(
    ProviderScope(
      parent: container,
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
    // Data should already be loaded, but handle any errors
    final systemState = ref.watch(systemConfigProvider);
    
    return systemState.when(
      loading: () => _buildSplashApp(context), // Show minimal splash if still loading
      error: (error, _) => ErrorScreen(message: error.toString()),
      data: (_) {
        final $system = ref.watch(systemProvider);
        final $user = ref.watch(userProvider);
        final themeMode = ref.watch(appThemeModeProvider).value ?? ThemeMode.light;
        final isDark = themeMode == ThemeMode.dark || 
                      (themeMode == ThemeMode.system && 
                       MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        setSystemUIOverlayStyle(isDark);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: $system['system_title'],
          theme: appTheme(context: context, isDark: false),
          darkTheme: appTheme(context: context, isDark: true),
          themeMode: themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerDelegate: appRouter.delegate(
            deepLinkBuilder: (_) => DeepLink(
              [$user.isNotEmpty ? goHome(ref, context: context, returnRoute: true) : const SplashRoute()],
            ),
          ),
          routeInformationParser: appRouter.defaultRouteParser(),
          builder: (context, child) {
            final currentIsDark = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: currentIsDark ? Brightness.light : Brightness.dark,
                systemNavigationBarColor: currentIsDark ? xBackgroundColorDark : xBackgroundColor,
                systemNavigationBarIconBrightness: currentIsDark ? Brightness.light : Brightness.dark,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }

  // Minimal splash as fallback (should rarely be seen)
  Widget _buildSplashApp(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
