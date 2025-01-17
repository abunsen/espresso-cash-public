import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../l10n/l10n.dart';
import '../../../routes.gr.dart';
import '../../../ui/button.dart';
import '../../../ui/icon_button.dart';
import '../../../ui/text_field.dart';
import '../../../ui/theme.dart';
import '../../blockchain/models/blockchain.dart';
import '../../qr_scanner/widgets/build_context_ext.dart';
import '../../wallet_flow/widgets/pay_page.dart';
import 'network_picker_screen.dart';

typedef ODPInputResponse = void Function(Blockchain network, String address);

@RoutePage()
class ODPInputScreen extends StatefulWidget {
  const ODPInputScreen({super.key, required this.onSubmit});

  final ODPInputResponse onSubmit;

  static const route = ODPInputRoute.new;

  @override
  State<ODPInputScreen> createState() => _ODPInputScreenState();
}

class _ODPInputScreenState extends State<ODPInputScreen> {
  late final TextEditingController _walletAddressController =
      TextEditingController();

  Blockchain _selectedNetwork = Blockchain.solana;
  final bool _showNetworkPicker = Blockchain.values.length > 1;

  bool get _isValid =>
      _selectedNetwork.validateAddress(_walletAddressController.text);

  void _handleSubmitted() => widget.onSubmit(
        _selectedNetwork,
        _walletAddressController.text,
      );

  void _handleOnNetworkTap() => context.router.push(
        NetworkPickerScreen.route(
          initial: _selectedNetwork,
          onSubmitted: (network) {
            context.router.pop();
            setState(() => _selectedNetwork = network);
          },
        ),
      );

  Future<void> _handleOnQrScan() async {
    final code = await context.launchQrForAddress();

    if (code == null) return;
    if (!mounted) return;

    setState(() {
      _walletAddressController.text = code;
    });
  }

  @override
  void dispose() {
    _walletAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PayPage(
        title: context.l10n.walletSendToAddressTitle,
        headerBackground: Assets.images.sendManualBg,
        headerContent: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Text(
                '${context.l10n.walletNetworks}:',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: const ShapeDecoration(
                color: Colors.black,
                shape: StadiumBorder(),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                onTap: _showNetworkPicker ? _handleOnNetworkTap : null,
                title: Text(
                  _selectedNetwork.displayName,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: _showNetworkPicker
                    ? const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Colors.white,
                        size: 34,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
        content: SafeArea(
          top: false,
          minimum: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 27),
              const _OthersTitle(),
              const SizedBox(height: 5),
              _WalletTextField(
                controller: _walletAddressController,
                onQrScan: _handleOnQrScan,
              ),
              const Spacer(),
              ListenableBuilder(
                listenable: _walletAddressController,
                builder: (context, child) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: CpButton(
                    text: context.l10n.next,
                    onPressed: _isValid ? _handleSubmitted : null,
                    size: CpButtonSize.big,
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _WalletTextField extends StatelessWidget {
  const _WalletTextField({
    required this.controller,
    required this.onQrScan,
  });

  final TextEditingController controller;
  final VoidCallback onQrScan;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: CpTextField(
          controller: controller,
          placeholder: context.l10n.walletAddressFieldHint,
          backgroundColor: const Color(0xFF4D4B4C),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          textColor: Colors.white,
          fontSize: 16,
          suffix: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: CpIconButton(
              onPressed: onQrScan,
              icon: Assets.icons.qrScanner.svg(color: Colors.white),
              variant: CpIconButtonVariant.black,
            ),
          ),
          multiLine: true,
        ),
      );
}

class _OthersTitle extends StatelessWidget {
  const _OthersTitle();

  @override
  Widget build(BuildContext context) => Text(
        '${context.l10n.walletAddress}:',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: CpTheme.of(context).primaryTextColor,
        ),
      );
}
