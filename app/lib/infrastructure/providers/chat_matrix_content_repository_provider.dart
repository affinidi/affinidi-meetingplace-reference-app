import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';

part 'chat_matrix_content_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<MatrixContentRepository> chatMatrixContentRepository(Ref ref) async {
  final evnvironment = ref.read(environmentProvider);
  return MatrixContentRepository(homeserverUrl: evnvironment.matrixHomeserver);
}
