import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:solana/solana.dart';
import 'package:solana/solana_pay.dart';
import 'package:uuid/uuid.dart';

import '../../../core/amount.dart';
import '../../tokens/token.dart';
import '../data/repository.dart';
import '../models/payment_request.dart';

@injectable
class PaymentRequestService {
  const PaymentRequestService(this._repository);

  final PaymentRequestRepository _repository;

  Future<PaymentRequest> create({
    required Ed25519HDPublicKey recipient,
    required CryptoAmount tokenAmount,
    required String? label,
  }) async {
    final reference = (await Ed25519HDKeyPair.random()).publicKey;
    final Token token = tokenAmount.token;
    final Decimal amount = tokenAmount.decimal;

    final request = SolanaPayRequest(
      recipient: recipient,
      amount: amount,
      splToken: token == Token.sol ? null : token.publicKey,
      label: label,
      reference: [reference],
    );
    final id = const Uuid().v4();

    final paymentRequest = PaymentRequest(
      id: id,
      created: DateTime.now(),
      payRequest: request,
      dynamicLink: request.toUniversalLink().toString(),
      state: const PaymentRequestState.initial(),
    );
    await _repository.save(paymentRequest);

    return paymentRequest;
  }
}
