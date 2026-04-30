import 'package:copy_with_extension/copy_with_extension.dart';

part 'credentials_screen_state.g.dart';

@CopyWith()
class CredentialsScreenState {
  const CredentialsScreenState({
    this.hasCredentials = false,
  });

  final bool hasCredentials;
}
