import 'package:auto_route/auto_route.dart';
import 'package:dfunc/dfunc.dart';
import 'package:flutter/material.dart';

import '../../../core/presentation/format_amount.dart';
import '../../../core/presentation/utils.dart';
import '../../../di.dart';
import '../../../l10n/device_locale.dart';
import '../../../l10n/l10n.dart';
import '../../../routes.gr.dart';
import '../../transactions/services/create_transaction_link.dart';
import '../../transactions/widgets/transfer_error.dart';
import '../../transactions/widgets/transfer_progress.dart';
import '../../transactions/widgets/transfer_success.dart';
import '../data/repository.dart';
import '../models/outgoing_direct_payment.dart';
import '../widgets/extensions.dart';

@RoutePage()
class ODPDetailsScreen extends StatefulWidget {
  const ODPDetailsScreen({
    super.key,
    required this.id,
  });

  static const route = ODPDetailsRoute.new;

  final String id;

  @override
  State<ODPDetailsScreen> createState() => _ODPDetailsScreenState();
}

class _ODPDetailsScreenState extends State<ODPDetailsScreen> {
  late final Stream<OutgoingDirectPayment> _payment;

  @override
  void initState() {
    super.initState();
    _payment = sl<ODPRepository>().watch(widget.id);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<OutgoingDirectPayment>(
        stream: _payment,
        builder: (context, snapshot) {
          final payment = snapshot.data;

          return payment == null
              ? TransferProgress(onBack: () => context.router.pop())
              : payment.status.maybeMap(
                  success: (status) => TransferSuccess(
                    onBack: () => context.router.pop(),
                    onOkPressed: () => context.router.pop(),
                    statusContent: context.l10n.outgoingTransferSuccess(
                      payment.amount.format(DeviceLocale.localeOf(context)),
                    ),
                    onMoreDetailsPressed: () {
                      final link = status.txId
                          .let(createTransactionLink)
                          .let(Uri.parse)
                          .toString();
                      context.openLink(link);
                    },
                  ),
                  txFailure: (it) => TransferError(
                    onBack: () => context.router.pop(),
                    onRetry: () => context.retryODP(paymentId: payment.id),
                    reason: it.reason,
                  ),
                  orElse: () => TransferProgress(
                    onBack: () => context.router.pop(),
                  ),
                );
        },
      );
}
