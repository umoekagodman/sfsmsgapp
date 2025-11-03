import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';          // <-- NEW
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../routes/router.gr.dart';
import '../../widgets/language_dialog.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  bool _logoPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            // ───── TOP BAR: DM LOGO (left) + LANGUAGE (right) ─────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // DM LOGO
                  GestureDetector(
                    onTapDown: (_) => setState(() => _logoPressed = true),
                    onTapUp: (_) => setState(() => _logoPressed = false),
                    onTapCancel: () => setState(() => _logoPressed = false),
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: _DMLogo(isPressed: _logoPressed),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Language switcher
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const LanguageSelectionDialog(),
                    ),
                    icon: Icon(
                      Icons.translate,
                      color: isDark ? Colors.white70 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ───── WELCOME IMAGE ─────
            Expanded(
              flex: 3,
              child: Image.asset(
                "assets/images/welcome_image.png",
                fit: BoxFit.contain,
              ),
            ),

            // ───── TEXT + CTA ─────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr("Chat with strangers"),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(
                          "Ask them for anything right away - don't be shy! Speak your mind. Stay connected"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C5CE7), Color(0xFF00D2FF)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        onPressed: () =>
                            context.router.replaceAll([const SignInRoute()]),
                        icon: const Icon(Icons.arrow_forward, size: 20),
                        label: Text(
                          tr("Start Chatting"),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────── DM LOGO WIDGET ────────────────────────
class _DMLogo extends StatelessWidget {
  final bool isPressed;
  const _DMLogo({required this.isPressed});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(.45),
                  blurRadius: 12,
                  spreadRadius: 4,
                )
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _DMLogoPainter(dark: dark, pressed: isPressed),
      ),
    );
  }
}

// ──────────────────────── CUSTOM PAINTER ────────────────────────
class _DMLogoPainter extends CustomPainter {
  final bool dark;
  final bool pressed;

  _DMLogoPainter({required this.dark, required this.pressed});

  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Offset center = Offset(r, r);

    // ---- Gradient background circles ----
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        colors: pressed
            ? const [Color(0xFF00D2FF), Color(0xFF3A7BD5)]
            : const [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: r));

    // left circle (D)
    canvas.drawCircle(Offset(r * 0.72, r), r * 0.78, bgPaint);
    // right circle (M) – white
    canvas.drawCircle(
        Offset(r * 1.28, r), r * 0.78, bgPaint..color = Colors.white);

    // ---- Letters ----
    final TextPainter tpD = TextPainter(textDirection: TextDirection.ltr);
    tpD.text = const TextSpan(
      text: 'D',
      style: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -2,
      ),
    );
    tpD.layout();
    tpD.paint(canvas, Offset(r * 0.72 - tpD.width / 2, r - tpD.height / 2));

    final TextPainter tpM = TextPainter(textDirection: TextDirection.ltr);
    tpM.text = const TextSpan(
      text: 'M',
      style: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        color: Color(0xFF3A7BD5),
        letterSpacing: -1,
      ),
    );
    tpM.layout();
    tpM.paint(canvas, Offset(r * 1.28 - tpM.width / 2, r - tpM.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
