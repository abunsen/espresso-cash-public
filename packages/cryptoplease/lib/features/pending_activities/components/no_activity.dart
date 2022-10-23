import 'package:auto_route/auto_route.dart';
import 'package:cryptoplease/app/routes.dart';
import 'package:cryptoplease/gen/assets.gen.dart';
import 'package:cryptoplease/l10n/l10n.dart';
import 'package:cryptoplease/ui/button.dart';
import 'package:flutter/material.dart';

class NoActivity extends StatelessWidget {
  const NoActivity({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.logoIcon.image(height: 101),
            const SizedBox(height: 21),
            Text(context.l10n.noActivity),
            const SizedBox(height: 105),
            CpButton(
              text: context.l10n.requestOrSendPayment,
              width: double.infinity,
              size: CpButtonSize.big,
              onPressed: () => context.router.navigate(const WalletFlowRoute()),
            )
          ],
        ),
      );
}
