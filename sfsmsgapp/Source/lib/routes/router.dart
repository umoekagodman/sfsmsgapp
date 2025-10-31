// Import Third Party Packages
import 'package:auto_route/auto_route.dart';

// Import App Files
import './router.gr.dart';
import '../screens/screens.dart';

// Define Contacts Empty Router
@RoutePage(name: 'ContactsRouter')
class ContactsRouterPage extends AutoRouter {
  const ContactsRouterPage({super.key});
}

// Define Settings Empty Router
@RoutePage(name: 'SettingsRouter')
class SettingsRouterPage extends AutoRouter {
  const SettingsRouterPage({super.key});
}

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        // Splash Screen
        AutoRoute(
          path: SplashScreen.routeName,
          page: SplashRoute.page,
        ),
        // Sign In Screen
        AutoRoute(
          path: SignInScreen.routeName,
          page: SignInRoute.page,
        ),
        // Two Factor Auth Screen
        AutoRoute(
          path: TwoFactorAuthScreen.routeName,
          page: TwoFactorAuthRoute.page,
        ),
        // Sign Up Screen
        AutoRoute(
          path: SignUpScreen.routeName,
          page: SignUpRoute.page,
        ),
        // Activation Screen
        AutoRoute(
          path: ActivationScreen.routeName,
          page: ActivationRoute.page,
        ),
        // Activation Reset Screen
        AutoRoute(
          path: ActivationResetScreen.routeName,
          page: ActivationResetRoute.page,
        ),
        // Forget Password Screen
        AutoRoute(
          path: ForgetPasswordScreen.routeName,
          page: ForgetPasswordRoute.page,
        ),
        // Forget Password Confirm Screen
        AutoRoute(
          path: ForgetPasswordConfirmScreen.routeName,
          page: ForgetPasswordConfirmRoute.page,
        ),
        // Forget Password Reset Screen
        AutoRoute(
          path: ForgetPasswordResetScreen.routeName,
          page: ForgetPasswordResetRoute.page,
        ),
        // Approval Screen
        AutoRoute(
          path: ApprovalScreen.routeName,
          page: ApprovalRoute.page,
        ),
        // ContactUs Screen
        AutoRoute(
          path: ContactUsScreen.routeName,
          page: ContactUsRoute.page,
        ),
        // Getting Started Screen
        AutoRoute(
          path: GettingStartedScreen.routeName,
          page: GettingStartedRoute.page,
        ),
        // Packages Screen
        AutoRoute(
          path: PackagesScreen.routeName,
          page: PackagesRoute.page,
        ),
        // Conversation Screen
        AutoRoute(
          path: ConversationScreen.routeName,
          page: ConversationRoute.page,
        ),
        // Main Screen
        AutoRoute(
          path: MainScreen.routeName,
          page: MainRoute.page,
          children: [
            // Chats Screen
            AutoRoute(
              path: ChatsScreen.routeName,
              page: ChatsRoute.page,
            ),
            // Calls Screen
            AutoRoute(
              path: CallsScreen.routeName,
              page: CallsRoute.page,
            ),
            // Contacts Screen
            AutoRoute(
              path: ContactsScreen.routeName,
              page: ContactsRouter.page,
              children: [
                // Contacts Screen Empty Route
                AutoRoute(
                  path: '',
                  page: ContactsRoute.page,
                ),
                // Search Screen
                AutoRoute(
                  path: SearchScreen.routeName,
                  page: SearchRoute.page,
                ),
              ],
            ),
            // Settings Screen
            AutoRoute(
              path: SettingsScreen.routeName,
              page: SettingsRouter.page,
              children: [
                // Settings Screen Empty Route
                AutoRoute(
                  path: '',
                  page: SettingsRoute.page,
                ),
                // Settings Languages Screen
                AutoRoute(
                  path: SettingsLanguagesScreen.routeName,
                  page: SettingsLanguagesRoute.page,
                ),
                // Settings Theme Screen
                AutoRoute(
                  path: SettingsThemeScreen.routeName,
                  page: SettingsThemeRoute.page,
                ),
                // Settings Delete Account Screen
                AutoRoute(
                  path: SettingsDeleteScreen.routeName,
                  page: SettingsDeleteRoute.page,
                ),
              ],
            ),
          ],
        ),
      ];
}
