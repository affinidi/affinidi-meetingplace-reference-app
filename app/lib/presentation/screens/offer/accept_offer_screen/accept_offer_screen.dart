import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/extensions/widget_ref_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../../widgets/contact_card_view.dart';
import '../../../widgets/form_rows/form_card.dart';
import '../../../widgets/identity_picker/identity_picker.dart';
import '../../../widgets/offer_banner.dart';
import '../../../widgets/profile_picture.dart';
import 'accept_offer_screen_controller.dart';

class AcceptOfferScreen extends ConsumerWidget {
  AcceptOfferScreen({
    super.key,
    required String mnemonic,
    required String identityId,
  })  : _mnemonic = mnemonic,
        _identityId = identityId;

  final String _mnemonic;
  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    ref.keepAround(provider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.acceptOfferTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Loader(mnemonic: _mnemonic),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(mnemonic: _mnemonic),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          _PublisherAlias(mnemonic: _mnemonic),
                          _OfferName(mnemonic: _mnemonic),
                          Text(
                            context.l10n.offerDetailsDescription,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ErrorSection(mnemonic: _mnemonic),
                    _ContactDetailsPanel(mnemonic: _mnemonic),
                    const SizedBox(height: 20),
                    _AliasPicker(
                      mnemonic: _mnemonic,
                      identityId: _identityId,
                    ),
                  ],
                ),
              ),
            ),
            _ActionBar(mnemonic: _mnemonic),
          ],
        ),
      ),
    );
  }
}

class _Loader extends ConsumerWidget {
  _Loader({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final controller = ref.read(provider.notifier);
    final l10n = context.l10n;

    final alias = ref
        .watch(provider.select((state) => state.offer?.contactCard.firstName));

    return ModalAsyncLoadingStatus(
      controller.acceptOfferLoadingController,
      loadingMessage: l10n.connecting,
      successMessage: alias != null ? l10n.requestToConnect(alias) : null,
      successMessageStyle: LoadingMessageStyle.progress,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        const Column(
          children: [
            OfferBanner(),
            SizedBox(
              height: 110,
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          child: _ProfilePicture(mnemonic: _mnemonic),
        ),
      ],
    );
  }
}

class _ProfilePicture extends ConsumerWidget {
  _ProfilePicture({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final cacheManager = ref.read(cacheManagerProvider);
    final profileImage = ref.watch(
      provider.select(
        (state) => state.offer?.contactCard.image(cacheManager: cacheManager),
      ),
    );

    return ProfilePicture(image: profileImage);
  }
}

class _PublisherAlias extends ConsumerWidget {
  _PublisherAlias({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final alias = ref
        .watch(provider.select((state) => state.offer?.contactCard.firstName));

    if (alias?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Text(
      alias!,
      style: context.textTheme.headlineLarge,
      textAlign: TextAlign.center,
    );
  }
}

class _OfferName extends ConsumerWidget {
  const _OfferName({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final offerName =
        ref.watch(provider.select((state) => state.offer?.offerName));

    if (offerName?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Text(
      offerName!,
      style:
          context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}

class _ErrorSection extends ConsumerWidget {
  _ErrorSection({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final error = ref.watch(provider.select((state) => state.error));

    if (error == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ColoredBox(
        color: context.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            context.l10n.error(error),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ContactDetailsPanel extends StatelessWidget {
  _ContactDetailsPanel({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: context.l10n.offerDetailsHeader,
      child: _ContactCardView(mnemonic: _mnemonic),
    );
  }
}

class _ContactCardView extends ConsumerWidget {
  _ContactCardView({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final card =
        ref.watch(provider.select((state) => state.offer?.contactCard));

    if (card == null) {
      return const SizedBox.shrink();
    }

    return SdkContactCardView(card: card);
  }
}

class _AliasPicker extends HookConsumerWidget {
  _AliasPicker({
    required String mnemonic,
    required String identityId,
  })  : _mnemonic = mnemonic,
        _identityId = identityId;

  final String _mnemonic;
  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final controller = ref.read(provider.notifier);
    final identities = ref.watch(provider.select((state) => state.identities));
    final initialCardIndex =
        identities.indexWhere((element) => element.id == _identityId);
    final cacheManager = ref.read(cacheManagerProvider);

    useEffect(
      () {
        if (!context.mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.initialize(_identityId);
        });

        return null;
      },
      [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormCard(
          title: context.l10n.aliasPickerTitle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: IdentityPicker(
              key: const ValueKey('accept_offer_identity_picker'),
              identities: identities,
              displayMode: true,
              initialCardIndex: initialCardIndex,
              onSelectedIdentity: controller.selectIdentity,
              cacheManager: cacheManager,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            context.l10n.aliasPickerDescription,
            style: context.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends ConsumerWidget {
  _ActionBar({required String mnemonic}) : _mnemonic = mnemonic;

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final controller = ref.read(provider.notifier);
    final hasErrors =
        ref.watch(provider.select((state) => state.error != null));

    void clearSelectedOffer() async {
      if (!context.mounted) return;

      await controller.clearSelectedOffer();
      if (!context.mounted) return;
      context.pop();
    }

    void acceptOffer() async {
      if (!context.mounted) return;

      await controller.acceptOffer();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 12,
        spacing: 12,
        children: [
          ElevatedButton(
            style: context.destructiveElevatedButtonStyle,
            child: Text(context.l10n.generalCancel),
            onPressed: clearSelectedOffer,
          ),
          ElevatedButton(
            child: Text(context.l10n.generalConnect),
            onPressed: hasErrors ? null : acceptOffer,
          ),
        ],
      ),
    );
  }
}
