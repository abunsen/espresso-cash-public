import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../../../config.dart';
import '../../../../../core/accounts/bl/accounts_bloc.dart';
import '../../../../../core/presentation/utils.dart';
import '../../../../../di.dart';
import '../../../../../features/incoming_split_key_payments/bl/iskp_repository.dart';
import '../../../../../features/legal/flow.dart';
import '../../../../../features/outgoing_direct_payments/bl/repository.dart';
import '../../../../../features/outgoing_split_key_payments/bl/repository.dart';
import '../../../../../features/payment_request/bl/repository.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../ui/colors.dart';
import '../../../../../ui/dialogs.dart';
import '../../../../routes.dart';
import 'profile_button.dart';

part 'danger_section.dart';
part 'edit_profile_section.dart';
part 'share_section.dart';
part 'version_section.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    Key? key,
    required this.title,
    required this.actions,
    this.color = CpColors.lightGreyBackground,
  }) : super(key: key);

  final String title;
  final List<Widget> actions;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          child: Material(
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: actions,
            ),
          ),
        ),
      );
}
