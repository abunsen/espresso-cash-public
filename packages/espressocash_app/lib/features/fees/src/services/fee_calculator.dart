import 'dart:math';

import 'package:espressocash_api/espressocash_api.dart';
import 'package:injectable/injectable.dart';
import 'package:solana/solana.dart';

import '../../../../core/amount.dart';
import '../../../../core/currency.dart';
import '../../../ramp/models/ramp_partner.dart';
import '../../../tokens/token.dart';
import '../../models/fee_type.dart';

@injectable
class FeeCalculator {
  const FeeCalculator(this._cryptopleaseClient, this._solanaClient);

  final CryptopleaseClient _cryptopleaseClient;
  final SolanaClient _solanaClient;

  Future<CryptoAmount> call(FeeType type) => _cryptopleaseClient.getFees().then(
        (fees) async {
          switch (type) {
            case FeeTypeDirect(:final address):
              return await _hasUsdcAta(address)
                  ? fees.directPayment.ataExists
                  : fees.directPayment.ataDoesNotExist;
            case FeeTypeLink():
              return fees.escrowPayment;
            case FeeTypeWithdraw(:final amount, :final partner, :final address):
              final percentageFee = switch (partner) {
                RampPartner.scalex => fees.withdrawFeePercentage.scalex,
                RampPartner.coinflow => fees.withdrawFeePercentage.coinflow,
                RampPartner.guardarian => fees.withdrawFeePercentage.guardarian,
                RampPartner.rampNetwork =>
                  fees.withdrawFeePercentage.rampNetwork,
                RampPartner.kado => fees.withdrawFeePercentage.kado,
              };
              final percentageFeeAmount = (amount * percentageFee).ceil();

              final accountCreationFeeAmount = address == null
                  ? 0
                  : await _hasUsdcAta(address)
                      ? fees.directPayment.ataExists
                      : fees.directPayment.ataDoesNotExist;

              return max(percentageFeeAmount, accountCreationFeeAmount);
          }
        },
      ).then((fee) => CryptoAmount(value: fee, cryptoCurrency: Currency.usdc));

  Future<bool> _hasUsdcAta(Ed25519HDPublicKey address) =>
      _solanaClient.hasAssociatedTokenAccount(
        owner: address,
        mint: Token.usdc.publicKey,
      );
}
