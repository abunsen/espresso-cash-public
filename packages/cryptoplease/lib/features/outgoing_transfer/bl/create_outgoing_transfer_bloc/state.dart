part of 'bloc.dart';

@freezed
class FtCreateOutgoingTransferState with _$FtCreateOutgoingTransferState {
  const factory FtCreateOutgoingTransferState({
    required IList<Token> availableTokens,
    required OutgoingTransferType transferType,
    required CryptoAmount tokenAmount,
    required FiatAmount fiatAmount,
    required SplitKeyApiVersion apiVersion,
    Amount? maxFee,
    String? recipientAddress,
    String? memo,
    Iterable<Ed25519HDPublicKey>? reference,
    @Default(FlowInitial<Exception, OutgoingTransferId>())
        Flow<Exception, OutgoingTransferId> flow,
  }) = _FtCreateOutgoingTransferState;

  const FtCreateOutgoingTransferState._();

  CryptoAmount get fee => calculateFee(
        apiVersion,
        transferType,
        tokenAmount.currency.token.address,
      );

  Token get token => tokenAmount.currency.token;
}