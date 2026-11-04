import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/vta_enrolment_offer.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/vtc/vta_enrolment_client.dart';
import 'vtc_service.dart';

/// Where linking the member's VTA stands.
enum VtaLinkStatus {
  /// The stored link is being read.
  loading,

  /// No VTA is linked.
  unlinked,

  /// A manager key waits for the VTA's administrator to grant it.
  pending,

  /// The VTA granted the manager key all the phone needs.
  active,
}

/// Why a step of linking failed.
enum VtaLinkFailure {
  /// The text entered is not a DID.
  invalidDid,

  /// A VTA is already linked or being linked.
  alreadyLinked,

  /// The VTA's DID does not resolve.
  didNotResolved,

  /// The VTA's DID names no DIDComm mediator to reach it through.
  noDidcomm,

  /// The VTA cannot be reached.
  unreachable,

  /// The VTA's answer did not verify.
  badAnswer,

  /// The scanned or pasted text is not a readable enrolment offer.
  offerMalformed,

  /// The enrolment offer is of a version the app does not read.
  offerUnsupported,

  /// The enrolment offer's host is not reached over HTTPS.
  offerInsecure,

  /// The enrolment offer has expired.
  offerExpired,

  /// The enrolment offer was already used.
  offerUsed,

  /// The VTA host refused this phone's key.
  enrolmentRejected,

  /// The VTA host answered with another code than this phone's.
  codeMismatch,

  /// The VTA host cannot be reached.
  hostUnreachable;

  /// The failure [error] from linking stands for.
  static VtaLinkFailure of(Object error) => switch (error) {
    InvalidVtaDidException() => invalidDid,
    VtaAlreadyLinkedException() => alreadyLinked,
    InvalidVtaEnrolmentOfferException(:final problem) => switch (problem) {
      VtaEnrolmentOfferProblem.malformed => offerMalformed,
      VtaEnrolmentOfferProblem.unsupportedVersion => offerUnsupported,
      VtaEnrolmentOfferProblem.insecureUrl => offerInsecure,
      VtaEnrolmentOfferProblem.expired => offerExpired,
    },
    VtaEnrolmentException(:final problem) => switch (problem) {
      VtaEnrolmentProblem.expired => offerExpired,
      VtaEnrolmentProblem.alreadyUsed => offerUsed,
      VtaEnrolmentProblem.rejected => enrolmentRejected,
      VtaEnrolmentProblem.codeMismatch => codeMismatch,
      VtaEnrolmentProblem.unreachable => hostUnreachable,
    },
    MeetingPlaceVtcSDKException(:final code) => switch (code) {
      MeetingPlaceVtcSDKErrorCode.didResolutionFailed => didNotResolved,
      MeetingPlaceVtcSDKErrorCode.signInNotOffered => noDidcomm,
      MeetingPlaceVtcSDKErrorCode.invalidProof ||
      MeetingPlaceVtcSDKErrorCode.invalidDocument => badAnswer,
      _ => unreachable,
    },
    _ => unreachable,
  };
}

/// How an enrolment through the VTA host ended without a link.
enum VtaEnrolmentOutcome {
  /// The VTA admin refused this phone on the host.
  refused,

  /// The offer expired before the VTA admin granted this phone.
  expired,
}

/// The VTA link as the app knows it: shared by the router and every view of
/// the link.
class VtaLinkState {
  /// Creates a [VtaLinkState].
  const VtaLinkState({
    this.status = VtaLinkStatus.loading,
    this.vtaDid,
    this.managerDid,
    this.isPolling = false,
    this.hasTimedOut = false,
    this.isAdminOnly = false,
    this.checkFailure,
    this.enrolmentCode,
    this.enrolmentExpiresAt,
    this.enrolmentOutcome,
  });

  /// Where linking stands.
  final VtaLinkStatus status;

  /// DID of the linked VTA, once a link is pending or active.
  final String? vtaDid;

  /// DID of the manager key the VTA's administrator grants.
  final String? managerDid;

  /// Whether the phone is checking for the grant on its own.
  final bool isPolling;

  /// Whether the phone stopped checking for the grant after
  /// [VtaLinkTiming.window].
  final bool hasTimedOut;

  /// Whether the VTA granted the admin role but not `persona-holder` yet.
  final bool isAdminOnly;

  /// Why the last check for the grant failed, if it did.
  final VtaLinkFailure? checkFailure;

  /// The code to compare with the VTA host's, while a link started by an
  /// enrolment offer waits for the grant.
  final String? enrolmentCode;

  /// When the VTA host stops accepting a grant, while [enrolmentCode] is
  /// shown.
  final DateTime? enrolmentExpiresAt;

  /// How the last enrolment ended, when it ended without a link.
  final VtaEnrolmentOutcome? enrolmentOutcome;

  /// Whether the pending link was started by an enrolment offer.
  bool get isEnrolment => enrolmentCode != null;

  /// The `pnm` command that grants the manager key, while pending.
  String get grantCommand {
    final did = managerDid;
    return did == null ? '' : VtaLink.grantCommand(did);
  }

  VtaLinkState _copyWith({
    VtaLinkStatus? status,
    bool? isPolling,
    bool? hasTimedOut,
    bool? isAdminOnly,
    VtaLinkFailure? checkFailure,
    bool clearCheckFailure = false,
  }) => VtaLinkState(
    status: status ?? this.status,
    vtaDid: vtaDid,
    managerDid: managerDid,
    isPolling: isPolling ?? this.isPolling,
    hasTimedOut: hasTimedOut ?? this.hasTimedOut,
    isAdminOnly: isAdminOnly ?? this.isAdminOnly,
    checkFailure: clearCheckFailure ? null : checkFailure ?? this.checkFailure,
    enrolmentCode: status == VtaLinkStatus.active ? null : enrolmentCode,
    enrolmentExpiresAt: status == VtaLinkStatus.active
        ? null
        : enrolmentExpiresAt,
  );
}

/// How often and how long the phone checks for the grant.
class VtaLinkTiming {
  /// Creates a [VtaLinkTiming].
  const VtaLinkTiming({
    this.interval = const Duration(seconds: 6),
    this.window = const Duration(minutes: 10),
  });

  /// Time between two checks.
  final Duration interval;

  /// How long the phone keeps checking before the member must ask again.
  final Duration window;
}

/// Provides the [VtaLinkTiming].
final vtaLinkTimingProvider = Provider<VtaLinkTiming>(
  (ref) => const VtaLinkTiming(),
  name: 'vtaLinkTimingProvider',
);

/// Keeps the state of the VTA link and, while it is pending, checks for the
/// grant on its own: every [VtaLinkTiming.interval] for
/// [VtaLinkTiming.window], paused while the app is in the background.
///
/// Knows nothing of screens: views act through their controller, and the
/// app tells it when it goes to the background. Logs the type of a failure
/// only; never a DID, key or document.
class VtaLinkService extends Notifier<VtaLinkState> {
  late final VtcService _service = ref.read(vtcServiceProvider);
  late final VtaLinkTiming _timing = ref.read(vtaLinkTimingProvider);

  Timer? _timer;
  DateTime? _deadline;
  bool _isInBackground = false;
  bool _isChecking = false;
  Future<void>? _loaded;

  @override
  VtaLinkState build() {
    ref.onDispose(_cancelTimer);
    _loaded = _load();
    return const VtaLinkState();
  }

  /// Completes once the stored link has been read.
  Future<void> ensureLoaded() => _loaded ?? Future.value();

  /// Starts linking the VTA [text] names: an enrolment link from the VTA
  /// host, or the VTA's DID.
  ///
  /// Throws as [VtcService.startEnrolment] or [VtcService.startLink] does;
  /// [VtaLinkFailure.of] names why.
  Future<void> link(String text) async {
    if (VtaEnrolmentOffer.isLink(text)) {
      await _service.startEnrolment(text);
    } else {
      await _service.startLink(text);
    }
    await _load();
  }

  /// Checks for the grant now and, while pending, checks again for another
  /// [VtaLinkTiming.window].
  Future<void> checkAgain() async {
    if (state.status != VtaLinkStatus.pending) return;
    _startPolling();
    await _check();
  }

  /// Cancels a pending link or removes the active one: forgets the manager
  /// key, the link and everything cached from the VTA.
  Future<void> remove() async {
    _stopPolling();
    try {
      await _service.unlink();
    } finally {
      await _load();
    }
  }

  /// Pauses checking while the app is in the background, and resumes it
  /// when the app returns.
  void setInBackground(bool isInBackground) {
    if (_isInBackground == isInBackground) return;
    _isInBackground = isInBackground;
    if (isInBackground) {
      _cancelTimer();
    } else if (_deadline != null && state.status == VtaLinkStatus.pending) {
      _schedule();
      unawaited(_check());
    }
  }

  Future<void> _load() async {
    final linkedVta = await _service.linkedVta();
    final managerDid = await _service.managerDid();
    if (!ref.mounted) return;
    if (linkedVta == null) {
      _stopPolling();
      state = const VtaLinkState(status: VtaLinkStatus.unlinked);
      return;
    }
    final enrolment = linkedVta.isGranted ? null : linkedVta.enrolment;
    state = VtaLinkState(
      status: linkedVta.isGranted
          ? VtaLinkStatus.active
          : VtaLinkStatus.pending,
      vtaDid: linkedVta.vtaDid,
      managerDid: managerDid,
      enrolmentCode: enrolment?.code,
      enrolmentExpiresAt: enrolment?.expiresAt,
    );
    if (state.status == VtaLinkStatus.pending) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    _deadline = DateTime.now().add(_timing.window);
    state = state._copyWith(isPolling: true, hasTimedOut: false);
    if (!_isInBackground) _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer.periodic(_timing.interval, (_) => unawaited(_check()));
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _stopPolling() {
    _cancelTimer();
    _deadline = null;
    if (state.isPolling) state = state._copyWith(isPolling: false);
  }

  Future<void> _check() async {
    if (_isChecking || state.status != VtaLinkStatus.pending) return;
    final deadline = _deadline;
    if (deadline != null && DateTime.now().isAfter(deadline)) {
      _stopPolling();
      state = state._copyWith(hasTimedOut: true);
      return;
    }

    _isChecking = true;
    try {
      final enrolment = state.isEnrolment ? await _checkEnrolment() : null;
      if (!ref.mounted || state.status != VtaLinkStatus.pending) return;
      if (enrolment == VtaEnrolmentStatus.refused ||
          enrolment == VtaEnrolmentStatus.expired) {
        await _endEnrolment(enrolment!);
        return;
      }

      // The VTA, not the host, says whether the key is granted.
      final access = await _service.checkGrant();
      if (!ref.mounted || state.status != VtaLinkStatus.pending) return;
      if (access != null && access.isGranted) {
        _stopPolling();
        state = state._copyWith(
          status: VtaLinkStatus.active,
          isAdminOnly: false,
          clearCheckFailure: true,
        );
      } else if (_hasEnrolmentLapsed(enrolment, access)) {
        await _endEnrolment(VtaEnrolmentStatus.expired);
      } else {
        state = state._copyWith(
          isAdminOnly: access?.isAdmin ?? false,
          clearCheckFailure: true,
        );
      }
    } on MeetingPlaceVtcSDKException catch (error, stackTrace) {
      // Checked again on the next tick.
      if (!ref.mounted) return;
      ref
          .read(appLoggerProvider)
          .error(
            'Checking the VTA grant failed: ${error.code.name}',
            stackTrace: stackTrace,
            name: 'VtaLinkService',
          );
      state = state._copyWith(checkFailure: VtaLinkFailure.of(error));
    } finally {
      _isChecking = false;
    }
  }

  /// Where the enrolment stands on the VTA host, or null when the host
  /// cannot be reached: the VTA is asked all the same.
  Future<VtaEnrolmentStatus?> _checkEnrolment() async {
    try {
      return await _service.checkEnrolment();
    } on VtaEnrolmentException catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .error(
            'Checking the VTA enrolment failed: ${error.problem.name}',
            stackTrace: stackTrace,
            name: 'VtaLinkService',
          );
      return null;
    }
  }

  /// Whether the offer expired with no grant: past its expiry, the host
  /// granted nothing it reported and the VTA grants no admin role.
  bool _hasEnrolmentLapsed(VtaEnrolmentStatus? enrolment, VtaAccess? access) {
    final expiresAt = state.enrolmentExpiresAt;
    return expiresAt != null &&
        clock.now().isAfter(expiresAt) &&
        enrolment != VtaEnrolmentStatus.granted &&
        !(access?.isAdmin ?? false);
  }

  /// Forgets the link the enrolment started, and says how it ended.
  Future<void> _endEnrolment(VtaEnrolmentStatus status) async {
    _stopPolling();
    await _service.unlink();
    if (!ref.mounted) return;
    state = VtaLinkState(
      status: VtaLinkStatus.unlinked,
      enrolmentOutcome: status == VtaEnrolmentStatus.refused
          ? VtaEnrolmentOutcome.refused
          : VtaEnrolmentOutcome.expired,
    );
  }
}

/// Provides the [VtaLinkService], for the life of the app.
final vtaLinkServiceProvider = NotifierProvider<VtaLinkService, VtaLinkState>(
  VtaLinkService.new,
  name: 'vtaLinkServiceProvider',
);
