/// A test credential this app can issue to one of the member's identities
/// and import into their VTA, to try joining a community by credential
/// without a real issuer.
class MockCredentialTemplate {
  /// Creates a [MockCredentialTemplate].
  const MockCredentialTemplate({
    required this.id,
    required this.title,
    required this.type,
    required this.claims,
  });

  /// Its id within the catalog.
  final String id;

  /// What it is called, as shown to the member.
  final String title;

  /// Its VC type beside `VerifiableCredential`, which a community's way in
  /// selects it by.
  final String type;

  /// The subject claims it makes, beside the subject's id.
  final Map<String, Object> claims;
}

/// The test credentials this app can issue.
const mockCredentialTemplates = [
  MockCredentialTemplate(
    id: 'membership',
    title: 'Club membership',
    type: 'MembershipCredential',
    claims: {'memberOf': 'Example Chess Club'},
  ),
  MockCredentialTemplate(
    id: 'employee',
    title: 'Employee',
    type: 'EmployeeCredential',
    claims: {'employer': 'Example Corp', 'role': 'Engineer'},
  ),
  MockCredentialTemplate(
    id: 'student',
    title: 'Student',
    type: 'StudentCredential',
    claims: {'school': 'Example University'},
  ),
  MockCredentialTemplate(
    id: 'age-over-18',
    title: 'Over 18',
    type: 'AgeOver18Credential',
    claims: {'ageOver': 18},
  ),
];
