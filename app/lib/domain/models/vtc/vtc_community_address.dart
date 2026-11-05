/// Where a community's DID says it lives: the web host its DID resolves at
/// and, for a `did:webvh`, the fingerprint (SCID) its DID log is bound to.
///
/// Both come from the DID alone, never from what the community says about
/// itself, so a member can compare them with what the community publishes
/// elsewhere.
class VtcCommunityAddress {
  /// Creates a [VtcCommunityAddress].
  const VtcCommunityAddress({required this.host, this.fingerprint});

  /// Reads [did], or returns null when it is no `did:webvh` or `did:web`
  /// with a host.
  ///
  /// Only splits the DID, which the scan already checked. A host may carry
  /// a port (`%3A`); any other percent escape is refused, so a host cannot
  /// read as another once decoded.
  static VtcCommunityAddress? of(String did) {
    final segments = did.split(':');
    if (segments.length < 3 || segments.first != 'did') return null;

    final (encodedHost, fingerprint) = switch (segments[1]) {
      'webvh' when segments.length >= 4 => (segments[3], segments[2]),
      'web' => (segments[2], null),
      _ => (null, null),
    };
    if (encodedHost == null || fingerprint == '') return null;

    final host = encodedHost.toLowerCase().replaceAll('%3a', ':');
    if (host.isEmpty || host.contains('%')) return null;
    return VtcCommunityAddress(host: host, fingerprint: fingerprint);
  }

  /// The host the DID resolves at, lower case, with its port when it has
  /// one.
  final String host;

  /// The SCID of a `did:webvh`; null for a `did:web`, which has none.
  final String? fingerprint;

  /// [fingerprint] in groups of four, to read out and compare.
  String? get groupedFingerprint {
    final value = fingerprint;
    if (value == null) return null;
    return [
      for (var start = 0; start < value.length; start += _groupLength)
        value.substring(start, (start + _groupLength).clamp(0, value.length)),
    ].join(' ');
  }

  static const _groupLength = 4;

  /// Whether [website] is on [host], or one is a subdomain of the other,
  /// with or without `www.`. A parent needs a dot, so a top-level domain
  /// alone matches nothing.
  ///
  /// A hint only: with no public-suffix list, sibling subdomains do not
  /// match, and a lookalike domain is not caught.
  bool sharesDomainWith(Uri website) {
    final ours = _withoutWww(host.split(':').first);
    final theirs = _withoutWww(website.host.toLowerCase());
    if (ours.isEmpty || theirs.isEmpty) return false;
    return ours == theirs ||
        _isSubdomain(ours, of: theirs) ||
        _isSubdomain(theirs, of: ours);
  }

  static bool _isSubdomain(String host, {required String of}) =>
      of.contains('.') && host.endsWith('.$of');

  static String _withoutWww(String host) =>
      host.startsWith('www.') ? host.substring(4) : host;
}
