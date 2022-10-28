import 'package:freezed_annotation/freezed_annotation.dart';

import '../outgoing_direct_payments/bl/outgoing_direct_payment.dart';
import '../outgoing_split_key_payments/bl/outgoing_split_key_payment.dart';

part 'pending_activity.freezed.dart';

@freezed
class PendingActivity with _$PendingActivity {
  const factory PendingActivity.outgoingPaymentRequest({
    required String id,
    required DateTime created,
  }) = OPRPendingActivity;

  const factory PendingActivity.outgoingDirectPayment({
    required String id,
    required DateTime created,
    required OutgoingDirectPayment data,
  }) = ODPPendingActivity;

  const factory PendingActivity.outgoingSplitKeyPayment({
    required String id,
    required DateTime created,
    required OutgoingSplitKeyPayment data,
  }) = OSKPPendingActivity;
}
