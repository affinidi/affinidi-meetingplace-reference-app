import 'package:drift/drift.dart';

String buildInsertSql({
  required String tableName,
  required Iterable<String> columnNames,
}) {
  final columns = columnNames.toList(growable: false);
  final placeholders = List.filled(columns.length, '?').join(', ');

  return 'INSERT INTO $tableName (${columns.join(', ')}) '
      'VALUES ($placeholders)';
}

String buildUpdateSql({
  required String tableName,
  required Iterable<String> columnNames,
  required String whereClause,
}) {
  final columns = columnNames.toList(growable: false);
  final assignments = columns.map((column) => '$column = ?').join(', ');

  return 'UPDATE $tableName SET $assignments WHERE $whereClause';
}

List<Variable> variablesFromExpressions(Map<String, Expression> values) {
  return values.entries
      .map((entry) {
        final expression = entry.value;
        if (expression is Variable) {
          return expression;
        }

        throw StateError(
          'Expected a Variable expression for "${entry.key}", '
          'got ${expression.runtimeType}.',
        );
      })
      .toList(growable: false);
}
