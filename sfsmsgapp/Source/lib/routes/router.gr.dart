// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i25;
import 'package:flutter/material.dart' as _i26;
import 'package:sngine_messenger/routes/router.dart' as _i7;
import 'package:sngine_messenger/screens/activation/activation_screen.dart'
    as _i2;
import 'package:sngine_messenger/screens/activation_reset/activation_reset_screen.dart'
    as _i1;
import 'package:sngine_messenger/screens/approval/approval_screen.dart' as _i3;
import 'package:sngine_messenger/screens/calls/calls_screen.dart' as _i4;
import 'package:sngine_messenger/screens/chats/chats_screen.dart' as _i5;
import 'package:sngine_messenger/screens/contact_us/contact_us_screen.dart'
    as _i6;
import 'package:sngine_messenger/screens/contacts/contacts_screen.dart' as _i8;
import 'package:sngine_messenger/screens/conversation/conversation_screen.dart'
    as _i9;
import 'package:sngine_messenger/screens/forget_password/forget_password_screen.dart'
    as _i12;
import 'package:sngine_messenger/screens/forget_password_confirm/forget_password_confirm_screen.dart'
    as _i10;
import 'package:sngine_messenger/screens/forget_password_reset/forget_password_reset_screen.dart'
    as _i11;
import 'package:sngine_messenger/screens/getting_started/getting_started_screen.dart'
    as _i13;
import 'package:sngine_messenger/screens/main/main_screen.dart' as _i14;
import 'package:sngine_messenger/screens/packages/packages_screen.dart' as _i15;
import 'package:sngine_messenger/screens/search/search_screen.dart' as _i16;
import 'package:sngine_messenger/screens/settings/settings_screen.dart' as _i19;
import 'package:sngine_messenger/screens/settings_delete/settings_delete_screen.dart'
    as _i17;
import 'package:sngine_messenger/screens/settings_languages/settings_languages_screen.dart'
    as _i18;
import 'package:sngine_messenger/screens/settings_theme/settings_theme_screen.dart'
    as _i20;
import 'package:sngine_messenger/screens/sign_in/sign_in_screen.dart' as _i21;
import 'package:sngine_messenger/screens/sign_up/sign_up_screen.dart' as _i22;
import 'package:sngine_messenger/screens/splash/splash_screen.dart' as _i23;
import 'package:sngine_messenger/screens/two_factor_auth/two_factor_auth_screen.dart'
    as _i24;

/// generated route for
/// [_i1.ActivationResetScreen]
class ActivationResetRoute extends _i25.PageRouteInfo<void> {
  const ActivationResetRoute({List<_i25.PageRouteInfo>? children})
    : super(ActivationResetRoute.name, initialChildren: children);

  static const String name = 'ActivationResetRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i1.ActivationResetScreen();
    },
  );
}

/// generated route for
/// [_i2.ActivationScreen]
class ActivationRoute extends _i25.PageRouteInfo<void> {
  const ActivationRoute({List<_i25.PageRouteInfo>? children})
    : super(ActivationRoute.name, initialChildren: children);

  static const String name = 'ActivationRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i2.ActivationScreen();
    },
  );
}

/// generated route for
/// [_i3.ApprovalScreen]
class ApprovalRoute extends _i25.PageRouteInfo<void> {
  const ApprovalRoute({List<_i25.PageRouteInfo>? children})
    : super(ApprovalRoute.name, initialChildren: children);

  static const String name = 'ApprovalRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i3.ApprovalScreen();
    },
  );
}

/// generated route for
/// [_i4.CallsScreen]
class CallsRoute extends _i25.PageRouteInfo<void> {
  const CallsRoute({List<_i25.PageRouteInfo>? children})
    : super(CallsRoute.name, initialChildren: children);

  static const String name = 'CallsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i4.CallsScreen();
    },
  );
}

/// generated route for
/// [_i5.ChatsScreen]
class ChatsRoute extends _i25.PageRouteInfo<void> {
  const ChatsRoute({List<_i25.PageRouteInfo>? children})
    : super(ChatsRoute.name, initialChildren: children);

  static const String name = 'ChatsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i5.ChatsScreen();
    },
  );
}

/// generated route for
/// [_i6.ContactUsScreen]
class ContactUsRoute extends _i25.PageRouteInfo<void> {
  const ContactUsRoute({List<_i25.PageRouteInfo>? children})
    : super(ContactUsRoute.name, initialChildren: children);

  static const String name = 'ContactUsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i6.ContactUsScreen();
    },
  );
}

/// generated route for
/// [_i7.ContactsRouterPage]
class ContactsRouter extends _i25.PageRouteInfo<void> {
  const ContactsRouter({List<_i25.PageRouteInfo>? children})
    : super(ContactsRouter.name, initialChildren: children);

  static const String name = 'ContactsRouter';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i7.ContactsRouterPage();
    },
  );
}

/// generated route for
/// [_i8.ContactsScreen]
class ContactsRoute extends _i25.PageRouteInfo<ContactsRouteArgs> {
  ContactsRoute({_i26.Key? key, List<_i25.PageRouteInfo>? children})
    : super(
        ContactsRoute.name,
        args: ContactsRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'ContactsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContactsRouteArgs>(
        orElse: () => const ContactsRouteArgs(),
      );
      return _i8.ContactsScreen(key: args.key);
    },
  );
}

class ContactsRouteArgs {
  const ContactsRouteArgs({this.key});

  final _i26.Key? key;

  @override
  String toString() {
    return 'ContactsRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.ConversationScreen]
class ConversationRoute extends _i25.PageRouteInfo<ConversationRouteArgs> {
  ConversationRoute({
    _i26.Key? key,
    String? conversationId,
    String? userId,
    Map<String, dynamic>? user,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         ConversationRoute.name,
         args: ConversationRouteArgs(
           key: key,
           conversationId: conversationId,
           userId: userId,
           user: user,
         ),
         initialChildren: children,
       );

  static const String name = 'ConversationRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ConversationRouteArgs>(
        orElse: () => const ConversationRouteArgs(),
      );
      return _i9.ConversationScreen(
        key: args.key,
        conversationId: args.conversationId,
        userId: args.userId,
        user: args.user,
      );
    },
  );
}

class ConversationRouteArgs {
  const ConversationRouteArgs({
    this.key,
    this.conversationId,
    this.userId,
    this.user,
  });

  final _i26.Key? key;

  final String? conversationId;

  final String? userId;

  final Map<String, dynamic>? user;

  @override
  String toString() {
    return 'ConversationRouteArgs{key: $key, conversationId: $conversationId, userId: $userId, user: $user}';
  }
}

/// generated route for
/// [_i10.ForgetPasswordConfirmScreen]
class ForgetPasswordConfirmRoute
    extends _i25.PageRouteInfo<ForgetPasswordConfirmRouteArgs> {
  ForgetPasswordConfirmRoute({
    _i26.Key? key,
    required String email,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         ForgetPasswordConfirmRoute.name,
         args: ForgetPasswordConfirmRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'ForgetPasswordConfirmRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForgetPasswordConfirmRouteArgs>();
      return _i10.ForgetPasswordConfirmScreen(key: args.key, email: args.email);
    },
  );
}

class ForgetPasswordConfirmRouteArgs {
  const ForgetPasswordConfirmRouteArgs({this.key, required this.email});

  final _i26.Key? key;

  final String email;

  @override
  String toString() {
    return 'ForgetPasswordConfirmRouteArgs{key: $key, email: $email}';
  }
}

/// generated route for
/// [_i11.ForgetPasswordResetScreen]
class ForgetPasswordResetRoute
    extends _i25.PageRouteInfo<ForgetPasswordResetRouteArgs> {
  ForgetPasswordResetRoute({
    _i26.Key? key,
    required String email,
    required String resetKey,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         ForgetPasswordResetRoute.name,
         args: ForgetPasswordResetRouteArgs(
           key: key,
           email: email,
           resetKey: resetKey,
         ),
         initialChildren: children,
       );

  static const String name = 'ForgetPasswordResetRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForgetPasswordResetRouteArgs>();
      return _i11.ForgetPasswordResetScreen(
        key: args.key,
        email: args.email,
        resetKey: args.resetKey,
      );
    },
  );
}

class ForgetPasswordResetRouteArgs {
  const ForgetPasswordResetRouteArgs({
    this.key,
    required this.email,
    required this.resetKey,
  });

  final _i26.Key? key;

  final String email;

  final String resetKey;

  @override
  String toString() {
    return 'ForgetPasswordResetRouteArgs{key: $key, email: $email, resetKey: $resetKey}';
  }
}

/// generated route for
/// [_i12.ForgetPasswordScreen]
class ForgetPasswordRoute extends _i25.PageRouteInfo<void> {
  const ForgetPasswordRoute({List<_i25.PageRouteInfo>? children})
    : super(ForgetPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgetPasswordRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i12.ForgetPasswordScreen();
    },
  );
}

/// generated route for
/// [_i13.GettingStartedScreen]
class GettingStartedRoute extends _i25.PageRouteInfo<void> {
  const GettingStartedRoute({List<_i25.PageRouteInfo>? children})
    : super(GettingStartedRoute.name, initialChildren: children);

  static const String name = 'GettingStartedRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i13.GettingStartedScreen();
    },
  );
}

/// generated route for
/// [_i14.MainScreen]
class MainRoute extends _i25.PageRouteInfo<MainRouteArgs> {
  MainRoute({_i26.Key? key, List<_i25.PageRouteInfo>? children})
    : super(
        MainRoute.name,
        args: MainRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'MainRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainRouteArgs>(
        orElse: () => const MainRouteArgs(),
      );
      return _i14.MainScreen(key: args.key);
    },
  );
}

class MainRouteArgs {
  const MainRouteArgs({this.key});

  final _i26.Key? key;

  @override
  String toString() {
    return 'MainRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i15.PackagesScreen]
class PackagesRoute extends _i25.PageRouteInfo<void> {
  const PackagesRoute({List<_i25.PageRouteInfo>? children})
    : super(PackagesRoute.name, initialChildren: children);

  static const String name = 'PackagesRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i15.PackagesScreen();
    },
  );
}

/// generated route for
/// [_i16.SearchScreen]
class SearchRoute extends _i25.PageRouteInfo<void> {
  const SearchRoute({List<_i25.PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i16.SearchScreen();
    },
  );
}

/// generated route for
/// [_i17.SettingsDeleteScreen]
class SettingsDeleteRoute extends _i25.PageRouteInfo<void> {
  const SettingsDeleteRoute({List<_i25.PageRouteInfo>? children})
    : super(SettingsDeleteRoute.name, initialChildren: children);

  static const String name = 'SettingsDeleteRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i17.SettingsDeleteScreen();
    },
  );
}

/// generated route for
/// [_i18.SettingsLanguagesScreen]
class SettingsLanguagesRoute extends _i25.PageRouteInfo<void> {
  const SettingsLanguagesRoute({List<_i25.PageRouteInfo>? children})
    : super(SettingsLanguagesRoute.name, initialChildren: children);

  static const String name = 'SettingsLanguagesRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i18.SettingsLanguagesScreen();
    },
  );
}

/// generated route for
/// [_i7.SettingsRouterPage]
class SettingsRouter extends _i25.PageRouteInfo<void> {
  const SettingsRouter({List<_i25.PageRouteInfo>? children})
    : super(SettingsRouter.name, initialChildren: children);

  static const String name = 'SettingsRouter';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i7.SettingsRouterPage();
    },
  );
}

/// generated route for
/// [_i19.SettingsScreen]
class SettingsRoute extends _i25.PageRouteInfo<void> {
  const SettingsRoute({List<_i25.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i19.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i20.SettingsThemeScreen]
class SettingsThemeRoute extends _i25.PageRouteInfo<void> {
  const SettingsThemeRoute({List<_i25.PageRouteInfo>? children})
    : super(SettingsThemeRoute.name, initialChildren: children);

  static const String name = 'SettingsThemeRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i20.SettingsThemeScreen();
    },
  );
}

/// generated route for
/// [_i21.SignInScreen]
class SignInRoute extends _i25.PageRouteInfo<void> {
  const SignInRoute({List<_i25.PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i21.SignInScreen();
    },
  );
}

/// generated route for
/// [_i22.SignUpScreen]
class SignUpRoute extends _i25.PageRouteInfo<void> {
  const SignUpRoute({List<_i25.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i22.SignUpScreen();
    },
  );
}

/// generated route for
/// [_i23.SplashScreen]
class SplashRoute extends _i25.PageRouteInfo<void> {
  const SplashRoute({List<_i25.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      return const _i23.SplashScreen();
    },
  );
}

/// generated route for
/// [_i24.TwoFactorAuthScreen]
class TwoFactorAuthRoute extends _i25.PageRouteInfo<TwoFactorAuthRouteArgs> {
  TwoFactorAuthRoute({
    _i26.Key? key,
    required String userId,
    required String method,
    List<_i25.PageRouteInfo>? children,
  }) : super(
         TwoFactorAuthRoute.name,
         args: TwoFactorAuthRouteArgs(key: key, userId: userId, method: method),
         initialChildren: children,
       );

  static const String name = 'TwoFactorAuthRoute';

  static _i25.PageInfo page = _i25.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TwoFactorAuthRouteArgs>();
      return _i24.TwoFactorAuthScreen(
        key: args.key,
        userId: args.userId,
        method: args.method,
      );
    },
  );
}

class TwoFactorAuthRouteArgs {
  const TwoFactorAuthRouteArgs({
    this.key,
    required this.userId,
    required this.method,
  });

  final _i26.Key? key;

  final String userId;

  final String method;

  @override
  String toString() {
    return 'TwoFactorAuthRouteArgs{key: $key, userId: $userId, method: $method}';
  }
}
