// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrc_database.dart';

// ignore_for_file: type=lint
class $VrcTableTable extends VrcTable with TableInfo<$VrcTableTable, VrcRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VrcTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vcMeta = const VerificationMeta('vc');
  @override
  late final GeneratedColumn<String> vc = GeneratedColumn<String>(
    'vc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _holderIdentityDidMeta = const VerificationMeta(
    'holderIdentityDid',
  );
  @override
  late final GeneratedColumn<String> holderIdentityDid =
      GeneratedColumn<String>(
        'holder_identity_did',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _issuerIdentityDidMeta = const VerificationMeta(
    'issuerIdentityDid',
  );
  @override
  late final GeneratedColumn<String> issuerIdentityDid =
      GeneratedColumn<String>(
        'issuer_identity_did',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
    'issued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vc,
    channelId,
    holderIdentityDid,
    issuerIdentityDid,
    issuedAt,
    verifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vrc_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VrcRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vc')) {
      context.handle(_vcMeta, vc.isAcceptableOrUnknown(data['vc']!, _vcMeta));
    } else if (isInserting) {
      context.missing(_vcMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('holder_identity_did')) {
      context.handle(
        _holderIdentityDidMeta,
        holderIdentityDid.isAcceptableOrUnknown(
          data['holder_identity_did']!,
          _holderIdentityDidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_holderIdentityDidMeta);
    }
    if (data.containsKey('issuer_identity_did')) {
      context.handle(
        _issuerIdentityDidMeta,
        issuerIdentityDid.isAcceptableOrUnknown(
          data['issuer_identity_did']!,
          _issuerIdentityDidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_issuerIdentityDidMeta);
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VrcRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VrcRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vc'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      holderIdentityDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holder_identity_did'],
      )!,
      issuerIdentityDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuer_identity_did'],
      )!,
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issued_at'],
      )!,
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
    );
  }

  @override
  $VrcTableTable createAlias(String alias) {
    return $VrcTableTable(attachedDatabase, alias);
  }
}

class VrcRow extends DataClass implements Insertable<VrcRow> {
  final String id;
  final String vc;
  final String channelId;
  final String holderIdentityDid;
  final String issuerIdentityDid;
  final DateTime issuedAt;
  final DateTime? verifiedAt;
  const VrcRow({
    required this.id,
    required this.vc,
    required this.channelId,
    required this.holderIdentityDid,
    required this.issuerIdentityDid,
    required this.issuedAt,
    this.verifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vc'] = Variable<String>(vc);
    map['channel_id'] = Variable<String>(channelId);
    map['holder_identity_did'] = Variable<String>(holderIdentityDid);
    map['issuer_identity_did'] = Variable<String>(issuerIdentityDid);
    map['issued_at'] = Variable<DateTime>(issuedAt);
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    return map;
  }

  VrcTableCompanion toCompanion(bool nullToAbsent) {
    return VrcTableCompanion(
      id: Value(id),
      vc: Value(vc),
      channelId: Value(channelId),
      holderIdentityDid: Value(holderIdentityDid),
      issuerIdentityDid: Value(issuerIdentityDid),
      issuedAt: Value(issuedAt),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
    );
  }

  factory VrcRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VrcRow(
      id: serializer.fromJson<String>(json['id']),
      vc: serializer.fromJson<String>(json['vc']),
      channelId: serializer.fromJson<String>(json['channelId']),
      holderIdentityDid: serializer.fromJson<String>(json['holderIdentityDid']),
      issuerIdentityDid: serializer.fromJson<String>(json['issuerIdentityDid']),
      issuedAt: serializer.fromJson<DateTime>(json['issuedAt']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vc': serializer.toJson<String>(vc),
      'channelId': serializer.toJson<String>(channelId),
      'holderIdentityDid': serializer.toJson<String>(holderIdentityDid),
      'issuerIdentityDid': serializer.toJson<String>(issuerIdentityDid),
      'issuedAt': serializer.toJson<DateTime>(issuedAt),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
    };
  }

  VrcRow copyWith({
    String? id,
    String? vc,
    String? channelId,
    String? holderIdentityDid,
    String? issuerIdentityDid,
    DateTime? issuedAt,
    Value<DateTime?> verifiedAt = const Value.absent(),
  }) => VrcRow(
    id: id ?? this.id,
    vc: vc ?? this.vc,
    channelId: channelId ?? this.channelId,
    holderIdentityDid: holderIdentityDid ?? this.holderIdentityDid,
    issuerIdentityDid: issuerIdentityDid ?? this.issuerIdentityDid,
    issuedAt: issuedAt ?? this.issuedAt,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
  );
  VrcRow copyWithCompanion(VrcTableCompanion data) {
    return VrcRow(
      id: data.id.present ? data.id.value : this.id,
      vc: data.vc.present ? data.vc.value : this.vc,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      holderIdentityDid: data.holderIdentityDid.present
          ? data.holderIdentityDid.value
          : this.holderIdentityDid,
      issuerIdentityDid: data.issuerIdentityDid.present
          ? data.issuerIdentityDid.value
          : this.issuerIdentityDid,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VrcRow(')
          ..write('id: $id, ')
          ..write('vc: $vc, ')
          ..write('channelId: $channelId, ')
          ..write('holderIdentityDid: $holderIdentityDid, ')
          ..write('issuerIdentityDid: $issuerIdentityDid, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vc,
    channelId,
    holderIdentityDid,
    issuerIdentityDid,
    issuedAt,
    verifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VrcRow &&
          other.id == this.id &&
          other.vc == this.vc &&
          other.channelId == this.channelId &&
          other.holderIdentityDid == this.holderIdentityDid &&
          other.issuerIdentityDid == this.issuerIdentityDid &&
          other.issuedAt == this.issuedAt &&
          other.verifiedAt == this.verifiedAt);
}

class VrcTableCompanion extends UpdateCompanion<VrcRow> {
  final Value<String> id;
  final Value<String> vc;
  final Value<String> channelId;
  final Value<String> holderIdentityDid;
  final Value<String> issuerIdentityDid;
  final Value<DateTime> issuedAt;
  final Value<DateTime?> verifiedAt;
  final Value<int> rowid;
  const VrcTableCompanion({
    this.id = const Value.absent(),
    this.vc = const Value.absent(),
    this.channelId = const Value.absent(),
    this.holderIdentityDid = const Value.absent(),
    this.issuerIdentityDid = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VrcTableCompanion.insert({
    required String id,
    required String vc,
    required String channelId,
    required String holderIdentityDid,
    required String issuerIdentityDid,
    required DateTime issuedAt,
    this.verifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vc = Value(vc),
       channelId = Value(channelId),
       holderIdentityDid = Value(holderIdentityDid),
       issuerIdentityDid = Value(issuerIdentityDid),
       issuedAt = Value(issuedAt);
  static Insertable<VrcRow> custom({
    Expression<String>? id,
    Expression<String>? vc,
    Expression<String>? channelId,
    Expression<String>? holderIdentityDid,
    Expression<String>? issuerIdentityDid,
    Expression<DateTime>? issuedAt,
    Expression<DateTime>? verifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vc != null) 'vc': vc,
      if (channelId != null) 'channel_id': channelId,
      if (holderIdentityDid != null) 'holder_identity_did': holderIdentityDid,
      if (issuerIdentityDid != null) 'issuer_identity_did': issuerIdentityDid,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VrcTableCompanion copyWith({
    Value<String>? id,
    Value<String>? vc,
    Value<String>? channelId,
    Value<String>? holderIdentityDid,
    Value<String>? issuerIdentityDid,
    Value<DateTime>? issuedAt,
    Value<DateTime?>? verifiedAt,
    Value<int>? rowid,
  }) {
    return VrcTableCompanion(
      id: id ?? this.id,
      vc: vc ?? this.vc,
      channelId: channelId ?? this.channelId,
      holderIdentityDid: holderIdentityDid ?? this.holderIdentityDid,
      issuerIdentityDid: issuerIdentityDid ?? this.issuerIdentityDid,
      issuedAt: issuedAt ?? this.issuedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vc.present) {
      map['vc'] = Variable<String>(vc.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (holderIdentityDid.present) {
      map['holder_identity_did'] = Variable<String>(holderIdentityDid.value);
    }
    if (issuerIdentityDid.present) {
      map['issuer_identity_did'] = Variable<String>(issuerIdentityDid.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VrcTableCompanion(')
          ..write('id: $id, ')
          ..write('vc: $vc, ')
          ..write('channelId: $channelId, ')
          ..write('holderIdentityDid: $holderIdentityDid, ')
          ..write('issuerIdentityDid: $issuerIdentityDid, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VrcDatabase extends GeneratedDatabase {
  _$VrcDatabase(QueryExecutor e) : super(e);
  $VrcDatabaseManager get managers => $VrcDatabaseManager(this);
  late final $VrcTableTable vrcTable = $VrcTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [vrcTable];
}

typedef $$VrcTableTableCreateCompanionBuilder =
    VrcTableCompanion Function({
      required String id,
      required String vc,
      required String channelId,
      required String holderIdentityDid,
      required String issuerIdentityDid,
      required DateTime issuedAt,
      Value<DateTime?> verifiedAt,
      Value<int> rowid,
    });
typedef $$VrcTableTableUpdateCompanionBuilder =
    VrcTableCompanion Function({
      Value<String> id,
      Value<String> vc,
      Value<String> channelId,
      Value<String> holderIdentityDid,
      Value<String> issuerIdentityDid,
      Value<DateTime> issuedAt,
      Value<DateTime?> verifiedAt,
      Value<int> rowid,
    });

class $$VrcTableTableFilterComposer
    extends Composer<_$VrcDatabase, $VrcTableTable> {
  $$VrcTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vc => $composableBuilder(
    column: $table.vc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holderIdentityDid => $composableBuilder(
    column: $table.holderIdentityDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuerIdentityDid => $composableBuilder(
    column: $table.issuerIdentityDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VrcTableTableOrderingComposer
    extends Composer<_$VrcDatabase, $VrcTableTable> {
  $$VrcTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vc => $composableBuilder(
    column: $table.vc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holderIdentityDid => $composableBuilder(
    column: $table.holderIdentityDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuerIdentityDid => $composableBuilder(
    column: $table.issuerIdentityDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VrcTableTableAnnotationComposer
    extends Composer<_$VrcDatabase, $VrcTableTable> {
  $$VrcTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vc =>
      $composableBuilder(column: $table.vc, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get holderIdentityDid => $composableBuilder(
    column: $table.holderIdentityDid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issuerIdentityDid => $composableBuilder(
    column: $table.issuerIdentityDid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );
}

class $$VrcTableTableTableManager
    extends
        RootTableManager<
          _$VrcDatabase,
          $VrcTableTable,
          VrcRow,
          $$VrcTableTableFilterComposer,
          $$VrcTableTableOrderingComposer,
          $$VrcTableTableAnnotationComposer,
          $$VrcTableTableCreateCompanionBuilder,
          $$VrcTableTableUpdateCompanionBuilder,
          (VrcRow, BaseReferences<_$VrcDatabase, $VrcTableTable, VrcRow>),
          VrcRow,
          PrefetchHooks Function()
        > {
  $$VrcTableTableTableManager(_$VrcDatabase db, $VrcTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VrcTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VrcTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VrcTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vc = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<String> holderIdentityDid = const Value.absent(),
                Value<String> issuerIdentityDid = const Value.absent(),
                Value<DateTime> issuedAt = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VrcTableCompanion(
                id: id,
                vc: vc,
                channelId: channelId,
                holderIdentityDid: holderIdentityDid,
                issuerIdentityDid: issuerIdentityDid,
                issuedAt: issuedAt,
                verifiedAt: verifiedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vc,
                required String channelId,
                required String holderIdentityDid,
                required String issuerIdentityDid,
                required DateTime issuedAt,
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VrcTableCompanion.insert(
                id: id,
                vc: vc,
                channelId: channelId,
                holderIdentityDid: holderIdentityDid,
                issuerIdentityDid: issuerIdentityDid,
                issuedAt: issuedAt,
                verifiedAt: verifiedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VrcTableTableProcessedTableManager =
    ProcessedTableManager<
      _$VrcDatabase,
      $VrcTableTable,
      VrcRow,
      $$VrcTableTableFilterComposer,
      $$VrcTableTableOrderingComposer,
      $$VrcTableTableAnnotationComposer,
      $$VrcTableTableCreateCompanionBuilder,
      $$VrcTableTableUpdateCompanionBuilder,
      (VrcRow, BaseReferences<_$VrcDatabase, $VrcTableTable, VrcRow>),
      VrcRow,
      PrefetchHooks Function()
    >;

class $VrcDatabaseManager {
  final _$VrcDatabase _db;
  $VrcDatabaseManager(this._db);
  $$VrcTableTableTableManager get vrcTable =>
      $$VrcTableTableTableManager(_db, _db.vrcTable);
}
