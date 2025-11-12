import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/repositories/contacts_repository.dart';

part 'contacts_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ContactsRepository> contactsRepository(Ref ref) async {
  throw UnimplementedError(
      '''Please configure the application by providing an ContactsRepository implementation in ProviderScope overrides.''');
}
