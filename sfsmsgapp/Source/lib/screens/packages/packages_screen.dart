import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Import App Files
import '../../states/system_state.dart';
import '../../utilities/functions.dart';

@RoutePage()
class PackagesScreen extends StatelessWidget {
  static const routeName = '/packages';

  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Pro Packages")),
      ),
      body: _Body(),
    );
  }
}

class _Body extends ConsumerWidget {
  _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final $system = ref.watch(systemProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            SvgPicture.asset(
              "assets/images/packages.svg",
              width: 300,
            ),
            SizedBox(height: 40),
            Text(
              tr("Choose the Plan That's Right for You"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              tr("Go to our website to see the plans and features and subscribe to the plan that's right for you"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                await launchURL($system['system_url']);
              },
              child: Text(tr("Go to our website")),
            ),
            SizedBox(height: 10),
            // refersh button
            TextButton(
              onPressed: () async {
                // ignore: unused_result
                await ref.refresh(systemConfigProvider.future);
                goHome(ref, context: context);
              },
              child: Text(tr("I updated my plan")),
            ),
          ],
        ),
      ),
    );
  }
}
