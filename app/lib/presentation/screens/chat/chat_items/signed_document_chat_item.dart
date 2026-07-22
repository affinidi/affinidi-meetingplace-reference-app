part of '../chat_screen.dart';

class _SignedDocumentChatItem extends ConsumerStatefulWidget {
  const _SignedDocumentChatItem({required this.data});

  final Map<String, dynamic> data;

  static Map<String, dynamic>? matchPlainMessage(chat.ChatItem item) {
    if (item is! chat.Message) return null;
    try {
      final decoded = jsonDecode(item.value);
      if (decoded is! Map<String, dynamic>) return null;
      final type = decoded['type'] as String? ?? '';
      if (type.contains('signed-document')) return decoded;
    } catch (_) {}
    return null;
  }

  @override
  ConsumerState<_SignedDocumentChatItem> createState() =>
      _SignedDocumentChatItemState();
}

class _SignedDocumentChatItemState
    extends ConsumerState<_SignedDocumentChatItem> {
  bool _detailsExpanded = false;
  bool _auditExpanded = false;
  bool _auditLoading = false;
  Map<String, dynamic>? _auditEntry;
  String? _auditError;
  bool _verifying = false;
  bool? _verificationResult;
  String? _verificationError;
  int _verifyStep = 0;

  static const _verifySteps = [
    'Canonicalizing document with JCS (RFC 8785)...',
    'Computing SHA-256 hash of document...',
    'Canonicalizing proof configuration...',
    'Computing SHA-256 hash of proof...',
    'Resolving DID to obtain public key...',
    'Verifying Ed25519 signature...',
  ];

  @override
  Widget build(BuildContext context) {
    final payload = widget.data['payload'] as Map<String, dynamic>? ?? {};
    final proof = widget.data['proof'] as Map<String, dynamic>? ?? {};
    final title = payload['title'] as String? ?? 'Untitled Document';
    final issuer = widget.data['issuer'] as String? ?? '';
    final issuerName = widget.data['issuerName'] as String?;
    final proofType = proof['type'] as String? ?? '';
    final cryptosuite = proof['cryptosuite'] as String? ?? '';
    final proofCreated = proof['created'] as String? ?? '';

    final shortIssuer = issuer.length > 24
        ? '${issuer.substring(0, 12)}...${issuer.substring(issuer.length - 8)}'
        : issuer;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 2,
          colors: [
            Color.fromARGB(255, 36, 76, 56),
            Color.fromARGB(255, 18, 31, 24),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, color: Colors.greenAccent, size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.greenAccent,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Signed',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'by $shortIssuer',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: Colors.white38,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '$proofType · $cryptosuite',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          if (proofCreated.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Signed at $proofCreated',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          _buildVerifyButton(),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _detailsExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _detailsExpanded ? 'Hide details' : 'More details',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          if (_detailsExpanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(widget.data),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _toggleAuditDetails,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _auditExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _auditExpanded
                      ? 'Hide trust task details'
                      : 'Trust task details',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          if (_auditExpanded) ...[
            const SizedBox(height: 8),
            if (_auditLoading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white38,
                  ),
                ),
              )
            else if (_auditError != null)
              Text(
                _auditError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
              )
            else if (_auditEntry != null)
              _buildAuditDetails(_auditEntry!)
            else
              const Text(
                'No audit entry found',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
          if (issuerName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Signed by Agent using context "$issuerName"',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    if (_verifying) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _verifySteps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (i < _verifyStep)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 14,
                      )
                    else if (i == _verifyStep)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.greenAccent,
                        ),
                      )
                    else
                      const Icon(
                        Icons.circle_outlined,
                        color: Colors.white12,
                        size: 14,
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        i <= _verifyStep
                            ? _verifySteps[i]
                            : _verifySteps[i].replaceAll('...', ''),
                        style: TextStyle(
                          color: i < _verifyStep
                              ? Colors.greenAccent.withValues(alpha: 0.7)
                              : i == _verifyStep
                                  ? Colors.white70
                                  : Colors.white24,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    if (_verificationResult != null) {
      final isValid = _verificationResult!;
      final proof = widget.data['proof'] as Map<String, dynamic>? ?? {};
      final verificationMethod = proof['verificationMethod'] as String? ?? '';
      final cryptosuite = proof['cryptosuite'] as String? ?? '';
      final proofPurpose = proof['proofPurpose'] as String? ?? '';
      final created = proof['created'] as String? ?? '';
      final issuer = widget.data['issuer'] as String? ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isValid ? Colors.greenAccent : Colors.redAccent)
              .withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isValid ? Colors.greenAccent : Colors.redAccent)
                .withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isValid ? Icons.verified_user : Icons.gpp_bad,
                  color: isValid ? Colors.greenAccent : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isValid
                      ? 'Cryptographic Signature Verified'
                      : 'Signature Verification Failed',
                  style: TextStyle(
                    color: isValid ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (isValid) ...[
              const SizedBox(height: 10),
              _verifyDetailRow('Cryptosuite', cryptosuite),
              _verifyDetailRow('Purpose', proofPurpose),
              _verifyDetailRow('Signer', _truncateDid(issuer)),
              _verifyDetailRow(
                'Key',
                _truncateDid(verificationMethod),
              ),
              if (created.isNotEmpty)
                _verifyDetailRow('Signed at', created),
              const SizedBox(height: 6),
              const Text(
                'The document has not been tampered with and was signed '
                'by the holder of the private key.',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
            if (_verificationError != null) ...[
              const SizedBox(height: 6),
              Text(
                _verificationError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 10),
              ),
            ],
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _verifySignature,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, color: Colors.greenAccent, size: 18),
            SizedBox(width: 8),
            Text(
              'Verify Signature',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifyDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifySignature() async {
    setState(() {
      _verifying = true;
      _verifyStep = 0;
    });

    try {
      final proof = widget.data['proof'] as Map<String, dynamic>? ?? {};
      final verificationMethod = proof['verificationMethod'] as String? ?? '';
      final verifierDid = verificationMethod.contains('#')
          ? verificationMethod.substring(0, verificationMethod.indexOf('#'))
          : verificationMethod;

      for (var i = 0; i < _verifySteps.length - 1; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        setState(() => _verifyStep = i + 1);
      }

      final verifier = DataIntegrityEddsaJcsVerifier(
        verifierDid: verifierDid,
      );
      final result = await verifier.verify(widget.data);

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _verifying = false;
          _verificationResult = result.isValid;
          _verificationError =
              result.isValid ? null : result.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _verificationResult = false;
          _verificationError = e.toString();
        });
      }
    }
  }

  void _toggleAuditDetails() {
    setState(() => _auditExpanded = !_auditExpanded);
    if (_auditExpanded && _auditEntry == null && !_auditLoading) {
      _fetchAuditDetails();
    }
  }

  Future<void> _fetchAuditDetails() async {
    setState(() {
      _auditLoading = true;
      _auditError = null;
    });

    try {
      final signingService = ref.read(signingServiceProvider.notifier);
      final logs = await signingService.getSigningAuditLogs();
      final match = _findMatchingAuditEntry(logs);
      if (mounted) {
        setState(() {
          _auditEntry = match;
          _auditLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _auditError = 'Failed to load: $e';
          _auditLoading = false;
        });
      }
    }
  }

  Map<String, dynamic>? _findMatchingAuditEntry(
    List<Map<String, dynamic>> entries,
  ) {
    final proof = widget.data['proof'] as Map<String, dynamic>? ?? {};
    final proofCreated = proof['created'] as String? ?? '';
    final envelopeId = widget.data['id'] as String?;

    for (final entry in entries) {
      final detail = entry['detail'] as Map<String, dynamic>?;
      if (detail != null && envelopeId != null) {
        if (detail['envelope_id'] == envelopeId) return entry;
      }
    }

    if (proofCreated.isEmpty) return entries.isNotEmpty ? entries.first : null;

    final proofTime = DateTime.tryParse(proofCreated);
    if (proofTime == null) return entries.isNotEmpty ? entries.first : null;

    Map<String, dynamic>? closest;
    var minDiff = Duration.zero;
    for (final entry in entries) {
      final ts = entry['timestamp'];
      DateTime? entryTime;
      if (ts is int) {
        entryTime = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
      } else if (ts is String) {
        entryTime = DateTime.tryParse(ts);
      }
      if (entryTime == null) continue;
      final diff = proofTime.difference(entryTime).abs();
      if (closest == null || diff < minDiff) {
        closest = entry;
        minDiff = diff;
      }
    }

    return closest;
  }

  Widget _buildAuditDetails(Map<String, dynamic> entry) {
    final detail = entry['detail'] as Map<String, dynamic>?;
    final items = <MapEntry<String, String>>[
      MapEntry('Operation', entry['action'] as String? ?? 'unknown'),
      MapEntry('Actor', _truncateDid(entry['actor'] as String? ?? '')),
      MapEntry('Outcome', entry['outcome'] as String? ?? ''),
      if (entry['resource'] != null)
        MapEntry('Vault Entry', entry['resource'] as String),
      if (entry['context_id'] != null)
        MapEntry('Context', entry['context_id'] as String),
      if (entry['channel'] != null)
        MapEntry('Channel', entry['channel'] as String),
      if (detail != null) ...[
        if (detail['envelope_id'] != null)
          MapEntry('Envelope ID', detail['envelope_id'] as String),
        if (detail['envelope_type'] != null)
          MapEntry('Envelope Type', detail['envelope_type'] as String),
        if (detail['envelope_recipient'] != null)
          MapEntry(
            'Recipient',
            _truncateDid(detail['envelope_recipient'] as String),
          ),
      ],
    ];

    final ts = entry['timestamp'];
    String? timestamp;
    if (ts is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(
        ts * 1000,
        isUtc: true,
      ).toIso8601String();
    } else if (ts is String) {
      timestamp = ts;
    }
    if (timestamp != null) {
      items.add(MapEntry('Timestamp', timestamp));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      item.key,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SelectableText(
                      item.value,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _truncateDid(String did) {
    if (did.length <= 32) return did;
    return '${did.substring(0, 16)}...${did.substring(did.length - 12)}';
  }
}
