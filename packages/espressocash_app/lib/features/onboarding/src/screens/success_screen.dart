import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../../gen/assets.gen.dart';
import '../../../../../../l10n/l10n.dart';
import '../../../../../../ui/button.dart';
import '../../../../../../ui/content_padding.dart';
import '../../../../../../ui/theme.dart';
import '../../../../routes.gr.dart';

@RoutePage()
class OnboardingSuccessScreen extends StatelessWidget {
  const OnboardingSuccessScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  static const route = OnboardingSuccessRoute.new;

  @override
  Widget build(BuildContext context) => CpTheme.black(
        child: Scaffold(
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Assets.images.sendManualBg.image(
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              CpContentPadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.icons.successCheck2.svg(width: 103, height: 103),
                    const SizedBox(height: 42),
                    Text(
                      context.l10n.backupPhrase_lblSuccessMessage1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.23,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.backupPhrase_lblSuccessMessage2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.19,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CpButton(
                size: CpButtonSize.big,
                width: double.infinity,
                text: context.l10n.onboardingNoticeFinishSetup,
                onPressed: onDone,
              ),
            ),
          ),
        ),
      );
}
