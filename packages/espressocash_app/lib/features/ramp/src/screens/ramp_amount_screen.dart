import 'package:auto_route/auto_route.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/amount.dart';
import '../../../../core/currency.dart';
import '../../../../core/presentation/format_amount.dart';
import '../../../../l10n/device_locale.dart';
import '../../../../l10n/l10n.dart';
import '../../../../routes.gr.dart';
import '../../../../ui/amount_keypad/amount_keypad.dart';
import '../../../../ui/app_bar.dart';
import '../../../../ui/back_button.dart';
import '../../../../ui/button.dart';
import '../../../../ui/colors.dart';
import '../../../../ui/theme.dart';
import '../../models/ramp_partner.dart';
import '../models/ramp_type.dart';

typedef AmountCalculator = ({Amount amount, String? rate}) Function(
  Amount amount,
);
typedef FeeCalculator = CryptoAmount Function(Amount amount);

@RoutePage()
class RampAmountScreen extends StatefulWidget {
  const RampAmountScreen({
    super.key,
    required this.onSubmitted,
    required this.minAmount,
    required this.currency,
    required this.calculateEquivalent,
    required this.type,
    required this.calculateFee,
    required this.partner,
    this.partnerFeeLabel,
  });

  static const route = RampAmountRoute.new;

  final ValueSetter<Amount> onSubmitted;
  final Decimal minAmount;
  final Currency currency;
  final AmountCalculator? calculateEquivalent;
  final RampType type;
  final RampPartner partner;
  final FeeCalculator? calculateFee;
  final String? partnerFeeLabel;

  @override
  State<RampAmountScreen> createState() => _RampAmountScreenState();
}

class _RampAmountScreenState extends State<RampAmountScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Amount get _amount {
    final text = _controller.text;
    final value = Decimal.tryParse(text);

    return value == null
        ? Amount(value: 0, currency: widget.currency)
        : Amount(
            value: widget.currency.decimalToInt(value),
            currency: widget.currency,
          );
  }

  @override
  Widget build(BuildContext context) => CpTheme.dark(
        child: Scaffold(
          backgroundColor: CpColors.darkBackground,
          appBar: CpAppBar(
            leading: const CpBackButton(),
            title: Text(
              switch (widget.type) {
                RampType.onRamp => context.l10n.ramp_btnAddCash,
                RampType.offRamp => context.l10n.ramp_btnCashOut,
              }
                  .toUpperCase(),
            ),
          ),
          body: SafeArea(
            top: false,
            minimum: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, value, child) => _EnteredAmount(
                      enteredText: value.text,
                      currency: widget.currency,
                    ),
                  ),
                ),
                const SizedBox(height: 27),
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, value, child) => _InfoLabel(
                    amount: _amount,
                    calculateEquivalent: widget.calculateEquivalent,
                    minAmount: widget.minAmount,
                    currency: widget.currency,
                    type: widget.type,
                    partner: widget.partner,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AmountKeypad(
                      controller: _controller,
                      maxDecimals: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, value, child) => _FeeLabel(
                    feeCalculator: widget.calculateFee,
                    partnerFeeLabel: widget.partnerFeeLabel,
                    amount: _amount,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      final amount = _amount;

                      return CpButton(
                        width: double.infinity,
                        text: context.l10n.next,
                        onPressed: amount.decimal >= widget.minAmount
                            ? () => widget.onSubmitted(amount)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _FeeLabel extends StatelessWidget {
  const _FeeLabel({
    required this.feeCalculator,
    required this.partnerFeeLabel,
    required this.amount,
  });

  final String? partnerFeeLabel;
  final FeeCalculator? feeCalculator;
  final Amount amount;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (partnerFeeLabel case final partnerFeeLabel?)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                partnerFeeLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.19,
                ),
              ),
            ),
          if (feeCalculator case final feeCalculator?)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: _FeeCalculator(
                calculateFee: feeCalculator,
                amount: amount,
              ),
            ),
          const SizedBox(height: 12),
        ],
      );
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel({
    required this.amount,
    required this.minAmount,
    required this.currency,
    required this.calculateEquivalent,
    required this.type,
    required this.partner,
  });

  final Amount amount;
  final Decimal minAmount;
  final Currency currency;
  final AmountCalculator? calculateEquivalent;
  final RampType type;
  final RampPartner partner;

  @override
  Widget build(BuildContext context) {
    context.l10n.minAmountToOffRamp(
      Amount(
        value: currency.decimalToInt(minAmount),
        currency: currency,
      ).format(context.locale, roundInteger: true),
    );

    Widget? child;
    if (amount.decimal < minAmount || calculateEquivalent == null) {
      final amount = Amount(
        value: currency.decimalToInt(minAmount),
        currency: currency,
      ).format(context.locale, roundInteger: true);

      child = Text(
        switch (type) {
          RampType.onRamp => context.l10n.minAmountToOnRamp(amount),
          RampType.offRamp => context.l10n.minAmountToOffRamp(amount),
        }
            .toUpperCase(),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      );
    } else if (calculateEquivalent case final calculateEquivalent?) {
      child = _Calculator(
        calculateEquivalent: calculateEquivalent,
        amount: amount,
        partner: partner,
      );
    }

    return child == null
        ? const SizedBox(height: 55)
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 55,
            width: double.infinity,
            decoration: const ShapeDecoration(
              shape: StadiumBorder(),
              color: Colors.black,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: DefaultTextStyle(
                style: const TextStyle(fontSize: 15),
                child: child,
              ),
            ),
          );
  }
}

class _EnteredAmount extends StatelessWidget {
  const _EnteredAmount({
    required this.currency,
    required this.enteredText,
  });

  final Currency currency;
  final String enteredText;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 82,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            enteredText.isEmpty
                ? context.l10n.enterAmount
                : '$enteredText ${currency.symbol}',
            style: TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.w700,
              color:
                  enteredText.isEmpty ? const Color(0xFF8F8F8F) : Colors.white,
            ),
          ),
        ),
      );
}

class _Calculator extends StatelessWidget {
  const _Calculator({
    required this.calculateEquivalent,
    required this.amount,
    required this.partner,
  });

  final AmountCalculator calculateEquivalent;
  final Amount amount;
  final RampPartner partner;

  @override
  Widget build(BuildContext context) {
    final equivalent = calculateEquivalent(amount);

    return Column(
      children: [
        if (partner == RampPartner.scalex)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: equivalent.amount
                      .format(context.locale, skipSymbol: true),
                ),
                TextSpan(
                  text: ' ${equivalent.amount.currency.symbol.toUpperCase()}',
                  style: const TextStyle(color: CpColors.yellowColor),
                ),
              ],
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          )
        else
          Text(
            context.l10n.rampAmountEquivalent(
              equivalent.amount.format(context.locale),
            ),
          ),
        if (equivalent.rate case final rate?)
          Text(
            rate,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.19,
            ),
          ),
      ],
    );
  }
}

class _FeeCalculator extends StatefulWidget {
  const _FeeCalculator({
    required this.calculateFee,
    required this.amount,
  });

  final FeeCalculator calculateFee;
  final Amount amount;

  @override
  State<_FeeCalculator> createState() => _FeeCalculatorState();
}

class _FeeCalculatorState extends State<_FeeCalculator> {
  late Amount _result;

  @override
  void initState() {
    super.initState();
    _result = widget.calculateFee(widget.amount);
  }

  @override
  void didUpdateWidget(covariant _FeeCalculator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.amount == widget.amount) return;

    _result = widget.calculateFee(widget.amount);
  }

  @override
  Widget build(BuildContext context) => Text(
        context.l10n.feeAmount(_result.format(context.locale)),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.19,
        ),
      );
}
