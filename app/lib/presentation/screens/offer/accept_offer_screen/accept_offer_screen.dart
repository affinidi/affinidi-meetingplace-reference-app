import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../../application/services/context_routing_service/context_routing_service.dart';
import '../../../../infrastructure/configuration/environment.dart';
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
    required this._mnemonic,
    required this._identityId,
  });

  final String _mnemonic;
  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    ref.keepAround(provider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.acceptOfferTitle)),
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
                    _AliasPicker(mnemonic: _mnemonic, identityId: _identityId),
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
  _Loader({required this._mnemonic});

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final controller = ref.read(provider.notifier);
    final l10n = context.l10n;

    final alias = ref.watch(
      provider.select((state) => state.offer?.contactCard.firstName),
    );

    return ModalAsyncLoadingStatus(
      controller.acceptOfferLoadingController,
      loadingMessage: l10n.connecting,
      successMessage: alias != null ? l10n.requestToConnect(alias) : null,
      successMessageStyle: LoadingMessageStyle.progress,
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this._mnemonic});

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final score = ref.watch(provider.select((state) => state.offer?.score));
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        const Column(children: [OfferBanner(), SizedBox(height: 110)]),
        Positioned(
          bottom: 0,
          child: _ProfilePictureWithScore(mnemonic: _mnemonic, score: score),
        ),
      ],
    );
  }
}

class _ProfilePictureWithScore extends ConsumerWidget {
  const _ProfilePictureWithScore({required this.mnemonic, required this.score});

  final String mnemonic;
  final int? score;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(mnemonic);
    final cacheManager = ref.read(cacheManagerProvider);
    final profileImage = ref.watch(
      provider.select(
        (state) => state.offer?.contactCard.image(cacheManager: cacheManager),
      ),
    );
    final colorScheme = context.colorScheme;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ProfilePicture(image: profileImage),
        if (score != null && score! > 0)
          Chip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 18,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.trustedBy(score!),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.primary,
          ),
      ],
    );
  }
}

class _PublisherAlias extends ConsumerWidget {
  _PublisherAlias({required this._mnemonic});

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final alias = ref.watch(
      provider.select((state) => state.offer?.contactCard.firstName),
    );

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
  const _OfferName({required this._mnemonic});

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final offerName = ref.watch(
      provider.select((state) => state.offer?.offerName),
    );

    if (offerName?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Text(
      offerName!,
      style: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ErrorSection extends ConsumerWidget {
  _ErrorSection({required this._mnemonic});

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
          child: Text(context.l10n.error(error), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _ContactDetailsPanel extends StatelessWidget {
  _ContactDetailsPanel({required this._mnemonic});

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
  _ContactCardView({required this._mnemonic});

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final card = ref.watch(
      provider.select((state) => state.offer?.contactCard),
    );

    if (card == null) {
      return const SizedBox.shrink();
    }

    return SdkContactCardView(card: card);
  }
}

class _AliasPicker extends HookConsumerWidget {
  _AliasPicker({required this._mnemonic, required this._identityId});

  final String _mnemonic;
  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final controller = ref.read(provider.notifier);
    final identities = ref.watch(provider.select((state) => state.identities));
    final initialCardIndex = identities.indexWhere(
      (element) => element.id == _identityId,
    );
    final cacheManager = ref.read(cacheManagerProvider);

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initialize(_identityId);
      });

      return null;
    }, []);

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
  _ActionBar({required this._mnemonic});

  final String _mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = acceptOfferScreenControllerProvider(_mnemonic);
    final controller = ref.read(provider.notifier);
    final hasErrors = ref.watch(
      provider.select((state) => state.error != null),
    );
    final offer = ref.watch(provider.select((state) => state.offer));

    Future<AgentContext?> selectAgentContext() {
      return showDialog<AgentContext>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Select agent context'),
          content: const Text(
            'Choose which Personal AI context this connection should use.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(AgentContext.work),
              child: Text(context.l10n.agentContextWorkAiLabel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(AgentContext.personal),
              child: Text(context.l10n.agentContextPersonalAiLabel),
            ),
          ],
        ),
      );
    }

    void clearSelectedOffer() async {
      if (!context.mounted) return;

      await controller.clearSelectedOffer();
      if (!context.mounted) return;
      context.pop();
    }

    void acceptOffer() async {
      if (!context.mounted) return;

      AgentContext? agentContext;
      if (offer != null &&
          offer.type == ConnectionOfferType.meetingPlaceInvitation &&
          offer.contactCard.type != 'ai-agent' &&
          ref.read(environmentProvider).personalAiEnabled) {
        agentContext = await selectAgentContext();
        if (agentContext == null) return;
      }

      await controller.acceptOffer(agentContext: agentContext);
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
