import 'dart:io' show Platform;

import 'package:flutter/material.dart';

// Third‑party
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App
import '../../../routes/router.gr.dart';
import '../../../states/system_state.dart';
import '../../../utilities/functions.dart';
import '../../../widgets/snackbars.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  //  SIGN‑IN LOGIC
  // ──────────────────────────────────────────────────────────────
  Future<void> _signIn() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final device = await getDeviceInfo();

      final resp = await sendAPIRequest(
        'auth/signin',
        method: 'POST',
        body: {
          'username_email': _usernameCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'device_name': device['name'] ?? '',
          'device_type': Platform.isAndroid ? 'A' : 'I',
          'device_os_version': device['systemVersion'] ?? '',
        },
      );

      // ── ALWAYS stop loading first ──
      if (!mounted) return;
      setState(() => _isLoading = false);

      // ── SUCCESS ──
      if (resp['statusCode'] == 200) {
        final data = resp['body']['data'];

        if (data['2FA'] != null) {
          context.router.push(TwoFactorAuthRoute(
            userId: data['user_id'],
            method: data['method'],
          ));
        } else {
          await setSharedPref('x-auth-token', data['token']);
          ref.read(userProvider.notifier).state = data['user'];
          goHome(ref, context: context);
        }
        return;
      }

      // ── ERROR FROM SERVER ──
      final msg = resp['body']['message']?.toString() ?? tr('Invalid credentials');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBarError(msg));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBarError(tr('Network error. Try again.')));
    }
  }

  // ──────────────────────────────────────────────────────────────
  //  UI
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // ── Username / Email ──
          TextFormField(
            controller: _usernameCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: tr('Email or Username'),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.email),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? tr('Enter valid email or username') : null,
          ),
          const SizedBox(height: 20),

          // ── Password ──
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: tr('Password'),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.password),
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? tr('Enter valid password') : null,
          ),
          const SizedBox(height: 10),

          // ── Forgotten password ──
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.router.push(const ForgetPasswordRoute()),
              child: Text(tr('Forgotten password?')),
            ),
          ),
          const SizedBox(height: 10),

          // ── Sign‑In button ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(tr('Sign In')),
            ),
          ),
        ],
      ),
    );
  }
}
