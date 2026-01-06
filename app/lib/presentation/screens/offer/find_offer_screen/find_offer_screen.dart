import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/string_list_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../../infrastructure/services/camera_service/camera_service.dart';
import '../../../../navigation/navigator.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../../widgets/identity_picker/identity_picker.dart';
import '../../../widgets/offer_banner.dart';
import 'find_offer_screen_controller.dart';

class FindOfferScreen extends HookConsumerWidget {
  const FindOfferScreen({
    super.key,
    this.identityId,
  });

  final String? identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mnemonicWordTextController = useTextEditingController();
    final provider = findOfferScreenControllerProvider;
    final controller = ref.read(provider.notifier);
    final cacheManager = ref.read(cacheManagerProvider);

    final env = ref.read(environmentProvider);
    final identities = ref.watch(provider.select((state) => state.identities));
    final selectedIdentity =
        ref.watch(provider.select((state) => state.selectedIdentity));

    useEffect(
      () {
        if (!context.mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.initialize();
        });

        return null;
      },
      [],
    );

    void findOffer(String mnemonic) async {
      if (!context.mounted) return;

      FocusManager.instance.primaryFocus?.unfocus();

      final trimmed = mnemonic.trim();
      var success = false;
      await ref
          .read(controller.findOfferLoadingController.notifier)
          .start(() async {
        await controller.findOffer(trimmed);
        success = true;
      });

      if (!context.mounted) return;
      if (success) {
        await ref.read(navigatorProvider).push(
              AcceptOfferRoute(
                mnemonic: trimmed,
                identityId: selectedIdentity!.id,
              ).location,
            );
      }
    }

    String cleanTextMnemonic(String mnemonic) {
      return mnemonic.split(' ').nonEmpty.join(' ');
    }

    void onDidReceiveQrData(String? data) {
      if (!context.mounted) return;
      if (data == null) return;
      if (data.startsWith(env.marketplaceQrPrefix)) {
        final mnemonic = data.replaceFirst(env.marketplaceQrPrefix, '');
        mnemonicWordTextController.text = cleanTextMnemonic(mnemonic);
        findOffer(data.replaceFirst(env.marketplaceQrPrefix, ''));
        return;
      }

      mnemonicWordTextController.text = cleanTextMnemonic(data);
    }

    const double maxWidth = 900;
    final width = MediaQuery.sizeOf(context).width;
    final inset = width > maxWidth ? (width - maxWidth) / 2 : 20.0;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.claimOfferTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(inset, 0, inset, 20),
            child: Column(
              spacing: 20,
              children: [
                ModalAsyncLoadingStatus(
                  controller.findOfferLoadingController,
                  loadingMessage: context.l10n.searching,
                ),
                const OfferBanner(),
                Text(
                  context.l10n.connectWithPersonAiServiceBusiness,
                  style: context.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (identities.isNotEmpty)
                  IdentityPicker(
                    key: const ValueKey('find_offer_identity_picker'),
                    identities: identities,
                    displayMode: true,
                    initialCardIndex: selectedIdentity != null
                        ? identities.indexOf(selectedIdentity)
                        : 0,
                    onSelectedIdentity: controller.selectIdentity,
                    cacheManager: cacheManager,
                  ),
                Text(
                  context.l10n.findPersonAiBusinessDescription,
                  style: context.textTheme.bodyMedium,
                ),
                Row(
                  spacing: 8,
                  children: [
                    _QrButton(onDidReceiveQrData: onDidReceiveQrData),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          if (!context.mounted) return;
                          findOffer(value);
                        },
                        onEditingComplete: () {}, // prevent closing keyboard
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9!\-_a-zA-Z\s]'),
                          ),
                        ],
                        textCapitalization: TextCapitalization.none,
                        textAlign: TextAlign.center,
                        controller: mnemonicWordTextController,
                        decoration: context.roundedInputDecoration.copyWith(
                          hintText: context.l10n.enterPassphrase,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.cancel,
                          size: 40,
                          color: context.colorScheme.primary,
                        ),
                        onPressed: () {
                          if (!context.mounted) return;
                          mnemonicWordTextController.clear();
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  child: Text(
                    context.l10n.generalSearch,
                  ),
                  onPressed: () {
                    if (!context.mounted) return;
                    findOffer(mnemonicWordTextController.text);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QrButton extends ConsumerWidget {
  _QrButton({
    required void Function(String? data) onDidReceiveQrData,
  }) : _onDidReceiveQrData = onDidReceiveQrData;

  final void Function(String? data) _onDidReceiveQrData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCameraAvailable = ref.watch(
      cameraServiceProvider.select((state) => state.isAvailable ?? false),
    );

    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.qr_code_scanner,
          size: 24,
          color: context.colorScheme.primary,
        ),
        onPressed: !isCameraAvailable
            ? null
            : () async {
                if (!context.mounted) return;

                final data = await QrCodePicker.show(context: context);
                _onDidReceiveQrData(data);
              },
      ),
    );
  }
}
