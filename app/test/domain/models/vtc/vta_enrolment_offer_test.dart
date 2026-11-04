import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vta_enrolment_offer.dart';

import '../../../fakes/fake_vta_host.dart';

void main() {
  final now = DateTime.utc(2026, 11, 4, 12);
  final exp = now.add(const Duration(minutes: 5));

  Map<String, dynamic> offer() => {
    'v': 1,
    't': 'vta-enrol',
    'vta': 'did:webvh:QmVta:vta.example',
    'label': 'Lab host',
    'url': FakeVtaHost.url,
    'n': FakeVtaHost.nonce,
    'exp': exp.millisecondsSinceEpoch ~/ 1000,
  };

  VtaEnrolmentOffer parse(String text, {bool allowHttp = false}) =>
      VtaEnrolmentOffer.parse(text, now: now, allowHttp: allowHttp);

  Matcher refusedAs(VtaEnrolmentOfferProblem problem) => throwsA(
    isA<InvalidVtaEnrolmentOfferException>().having(
      (e) => e.problem,
      'problem',
      problem,
    ),
  );

  group('vtaEnrolmentCode', () {
    test('matches the host test vector', () {
      expect(
        vtaEnrolmentCode('AAAAAAAAAAAAAAAAAAAAAA', 'did:peer:2.Vz6MkTEST'),
        'N4SP-X7H6',
      );
    });

    test('changes with the DID', () {
      expect(
        vtaEnrolmentCode(FakeVtaHost.nonce, 'did:key:z6MkA'),
        isNot(vtaEnrolmentCode(FakeVtaHost.nonce, 'did:key:z6MkB')),
      );
    });
  });

  group('VtaEnrolmentOffer.parse', () {
    test('reads a Keyring v1 offer', () {
      final read = parse(FakeVtaHost.encodeLink(offer()));

      expect(read.vtaDid, 'did:webvh:QmVta:vta.example');
      expect(read.label, 'Lab host');
      expect(read.url, FakeVtaHost.url);
      expect(read.nonce, FakeVtaHost.nonce);
      expect(read.expiresAt, exp);
    });

    test('reads padded and percent-encoded links, and trailing params', () {
      final payload = base64Url.encode(
        utf8.encode(jsonEncode(offer()..['label'] = 'Lab')),
      );
      expect(payload, endsWith('='));
      final padded = VtaEnrolmentOffer.linkPrefix + payload;
      final encoded =
          VtaEnrolmentOffer.linkPrefix + payload.replaceAll('=', '%3D');

      expect(parse(padded).nonce, FakeVtaHost.nonce);
      expect(parse('$encoded&x=1').nonce, FakeVtaHost.nonce);
    });

    test('refuses text that is not an enrolment link', () {
      expect(
        () => parse('did:webvh:QmVta:vta.example'),
        refusedAs(VtaEnrolmentOfferProblem.malformed),
      );
      expect(
        () => parse('${VtaEnrolmentOffer.linkPrefix}not*base64'),
        refusedAs(VtaEnrolmentOfferProblem.malformed),
      );
      expect(
        () => parse(
          VtaEnrolmentOffer.linkPrefix +
              base64Url.encode(utf8.encode('[1]')).replaceAll('=', ''),
        ),
        refusedAs(VtaEnrolmentOfferProblem.malformed),
      );
    });

    test('refuses an offer of another version', () {
      expect(
        () => parse(FakeVtaHost.encodeLink(offer()..['v'] = 2)),
        refusedAs(VtaEnrolmentOfferProblem.unsupportedVersion),
      );
    });

    for (final (name, change)
        in <(String, void Function(Map<String, dynamic>))>[
          ('another type', (o) => o['t'] = 'vetting'),
          ('no VTA', (o) => o.remove('vta')),
          ('a VTA that is no DID', (o) => o['vta'] = 'my agent'),
          ('a short nonce', (o) => o['n'] = 'abc'),
          ('a nonce outside base64url', (o) => o['n'] = 'AAAAAAAAAAAAAAAA/+'),
          ('an expiry that is no integer', (o) => o['exp'] = '1'),
          (
            'a URL with credentials',
            (o) => o['url'] = 'https://a:b@host.example',
          ),
          ('a URL of another scheme', (o) => o['url'] = 'ftp://host.example'),
          ('a URL without host', (o) => o['url'] = 'https:///offers'),
          ('a label too long', (o) => o['label'] = 'x' * 201),
          (
            'an expiry days ahead',
            (o) => o['exp'] =
                now.add(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000,
          ),
        ]) {
      test('refuses an offer with $name', () {
        final changed = offer();
        change(changed);

        expect(
          () => parse(FakeVtaHost.encodeLink(changed)),
          refusedAs(VtaEnrolmentOfferProblem.malformed),
        );
      });
    }

    test('refuses an expired offer', () {
      expect(
        () => VtaEnrolmentOffer.parse(
          FakeVtaHost.encodeLink(offer()),
          now: exp.add(const Duration(seconds: 1)),
        ),
        refusedAs(VtaEnrolmentOfferProblem.expired),
      );
    });

    test('refuses a plain HTTP host, except in dev builds', () {
      final link = FakeVtaHost.encodeLink(
        offer()..['url'] = 'http://localhost:8190/api/offers/n',
      );

      expect(
        () => parse(link),
        refusedAs(VtaEnrolmentOfferProblem.insecureUrl),
      );
      expect(parse(link, allowHttp: true).url, startsWith('http://'));
    });

    test('strips control characters from the label', () {
      final read = parse(
        FakeVtaHost.encodeLink(offer()..['label'] = 'Lab\nhost\u0007'),
      );

      expect(read.label, 'Lab host');
    });
  });
}
