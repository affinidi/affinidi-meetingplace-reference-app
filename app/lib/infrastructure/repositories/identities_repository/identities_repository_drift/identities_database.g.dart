// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identities_database.dart';

// ignore_for_file: type=lint
class $IdentitiesTableTable extends IdentitiesTable
    with TableInfo<$IdentitiesTableTable, IdentityRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentitiesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuid,
  );
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<String> did = GeneratedColumn<String>(
    'did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profilePicMeta = const VerificationMeta(
    'profilePic',
  );
  @override
  late final GeneratedColumn<String> profilePic = GeneratedColumn<String>(
    'profile_pic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardColorMeta = const VerificationMeta(
    'cardColor',
  );
  @override
  late final GeneratedColumn<String> cardColor = GeneratedColumn<String>(
    'card_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    did,
    displayName,
    profilePic,
    cardColor,
    isPrimary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identities_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdentityRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('did')) {
      context.handle(
        _didMeta,
        did.isAcceptableOrUnknown(data['did']!, _didMeta),
      );
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('profile_pic')) {
      context.handle(
        _profilePicMeta,
        profilePic.isAcceptableOrUnknown(data['profile_pic']!, _profilePicMeta),
      );
    }
    if (data.containsKey('card_color')) {
      context.handle(
        _cardColorMeta,
        cardColor.isAcceptableOrUnknown(data['card_color']!, _cardColorMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IdentityRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      did: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}did'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      profilePic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_pic'],
      ),
      cardColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_color'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $IdentitiesTableTable createAlias(String alias) {
    return $IdentitiesTableTable(attachedDatabase, alias);
  }
}

class IdentityRecord extends DataClass implements Insertable<IdentityRecord> {
  final String id;
  final String did;
  final String displayName;
  final String? profilePic;
  final String? cardColor;
  final bool isPrimary;
  const IdentityRecord({
    required this.id,
    required this.did,
    required this.displayName,
    this.profilePic,
    this.cardColor,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['did'] = Variable<String>(did);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || profilePic != null) {
      map['profile_pic'] = Variable<String>(profilePic);
    }
    if (!nullToAbsent || cardColor != null) {
      map['card_color'] = Variable<String>(cardColor);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  IdentitiesTableCompanion toCompanion(bool nullToAbsent) {
    return IdentitiesTableCompanion(
      id: Value(id),
      did: Value(did),
      displayName: Value(displayName),
      profilePic: profilePic == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePic),
      cardColor: cardColor == null && nullToAbsent
          ? const Value.absent()
          : Value(cardColor),
      isPrimary: Value(isPrimary),
    );
  }

  factory IdentityRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityRecord(
      id: serializer.fromJson<String>(json['id']),
      did: serializer.fromJson<String>(json['did']),
      displayName: serializer.fromJson<String>(json['displayName']),
      profilePic: serializer.fromJson<String?>(json['profilePic']),
      cardColor: serializer.fromJson<String?>(json['cardColor']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'did': serializer.toJson<String>(did),
      'displayName': serializer.toJson<String>(displayName),
      'profilePic': serializer.toJson<String?>(profilePic),
      'cardColor': serializer.toJson<String?>(cardColor),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  IdentityRecord copyWith({
    String? id,
    String? did,
    String? displayName,
    Value<String?> profilePic = const Value.absent(),
    Value<String?> cardColor = const Value.absent(),
    bool? isPrimary,
  }) => IdentityRecord(
    id: id ?? this.id,
    did: did ?? this.did,
    displayName: displayName ?? this.displayName,
    profilePic: profilePic.present ? profilePic.value : this.profilePic,
    cardColor: cardColor.present ? cardColor.value : this.cardColor,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  IdentityRecord copyWithCompanion(IdentitiesTableCompanion data) {
    return IdentityRecord(
      id: data.id.present ? data.id.value : this.id,
      did: data.did.present ? data.did.value : this.did,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      profilePic: data.profilePic.present
          ? data.profilePic.value
          : this.profilePic,
      cardColor: data.cardColor.present ? data.cardColor.value : this.cardColor,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentityRecord(')
          ..write('id: $id, ')
          ..write('did: $did, ')
          ..write('displayName: $displayName, ')
          ..write('profilePic: $profilePic, ')
          ..write('cardColor: $cardColor, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, did, displayName, profilePic, cardColor, isPrimary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityRecord &&
          other.id == this.id &&
          other.did == this.did &&
          other.displayName == this.displayName &&
          other.profilePic == this.profilePic &&
          other.cardColor == this.cardColor &&
          other.isPrimary == this.isPrimary);
}

class IdentitiesTableCompanion extends UpdateCompanion<IdentityRecord> {
  final Value<String> id;
  final Value<String> did;
  final Value<String> displayName;
  final Value<String?> profilePic;
  final Value<String?> cardColor;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const IdentitiesTableCompanion({
    this.id = const Value.absent(),
    this.did = const Value.absent(),
    this.displayName = const Value.absent(),
    this.profilePic = const Value.absent(),
    this.cardColor = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentitiesTableCompanion.insert({
    this.id = const Value.absent(),
    required String did,
    required String displayName,
    this.profilePic = const Value.absent(),
    this.cardColor = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : did = Value(did),
       displayName = Value(displayName);
  static Insertable<IdentityRecord> custom({
    Expression<String>? id,
    Expression<String>? did,
    Expression<String>? displayName,
    Expression<String>? profilePic,
    Expression<String>? cardColor,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (did != null) 'did': did,
      if (displayName != null) 'display_name': displayName,
      if (profilePic != null) 'profile_pic': profilePic,
      if (cardColor != null) 'card_color': cardColor,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentitiesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? did,
    Value<String>? displayName,
    Value<String?>? profilePic,
    Value<String?>? cardColor,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return IdentitiesTableCompanion(
      id: id ?? this.id,
      did: did ?? this.did,
      displayName: displayName ?? this.displayName,
      profilePic: profilePic ?? this.profilePic,
      cardColor: cardColor ?? this.cardColor,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (did.present) {
      map['did'] = Variable<String>(did.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (profilePic.present) {
      map['profile_pic'] = Variable<String>(profilePic.value);
    }
    if (cardColor.present) {
      map['card_color'] = Variable<String>(cardColor.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentitiesTableCompanion(')
          ..write('id: $id, ')
          ..write('did: $did, ')
          ..write('displayName: $displayName, ')
          ..write('profilePic: $profilePic, ')
          ..write('cardColor: $cardColor, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$IdentitiesDatabase extends GeneratedDatabase {
  _$IdentitiesDatabase(QueryExecutor e) : super(e);
  $IdentitiesDatabaseManager get managers => $IdentitiesDatabaseManager(this);
  late final $IdentitiesTableTable identitiesTable = $IdentitiesTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [identitiesTable];
}

typedef $$IdentitiesTableTableCreateCompanionBuilder =
    IdentitiesTableCompanion Function({
      Value<String> id,
      required String did,
      required String displayName,
      Value<String?> profilePic,
      Value<String?> cardColor,
      Value<bool> isPrimary,
      Value<int> rowid,
    });
typedef $$IdentitiesTableTableUpdateCompanionBuilder =
    IdentitiesTableCompanion Function({
      Value<String> id,
      Value<String> did,
      Value<String> displayName,
      Value<String?> profilePic,
      Value<String?> cardColor,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

class $$IdentitiesTableTableFilterComposer
    extends Composer<_$IdentitiesDatabase, $IdentitiesTableTable> {
  $$IdentitiesTableTableFilterComposer({
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

  ColumnFilters<String> get did => $composableBuilder(
    column: $table.did,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePic => $composableBuilder(
    column: $table.profilePic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardColor => $composableBuilder(
    column: $table.cardColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdentitiesTableTableOrderingComposer
    extends Composer<_$IdentitiesDatabase, $IdentitiesTableTable> {
  $$IdentitiesTableTableOrderingComposer({
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

  ColumnOrderings<String> get did => $composableBuilder(
    column: $table.did,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePic => $composableBuilder(
    column: $table.profilePic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardColor => $composableBuilder(
    column: $table.cardColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdentitiesTableTableAnnotationComposer
    extends Composer<_$IdentitiesDatabase, $IdentitiesTableTable> {
  $$IdentitiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profilePic => $composableBuilder(
    column: $table.profilePic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardColor =>
      $composableBuilder(column: $table.cardColor, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);
}

class $$IdentitiesTableTableTableManager
    extends
        RootTableManager<
          _$IdentitiesDatabase,
          $IdentitiesTableTable,
          IdentityRecord,
          $$IdentitiesTableTableFilterComposer,
          $$IdentitiesTableTableOrderingComposer,
          $$IdentitiesTableTableAnnotationComposer,
          $$IdentitiesTableTableCreateCompanionBuilder,
          $$IdentitiesTableTableUpdateCompanionBuilder,
          (
            IdentityRecord,
            BaseReferences<
              _$IdentitiesDatabase,
              $IdentitiesTableTable,
              IdentityRecord
            >,
          ),
          IdentityRecord,
          PrefetchHooks Function()
        > {
  $$IdentitiesTableTableTableManager(
    _$IdentitiesDatabase db,
    $IdentitiesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdentitiesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdentitiesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdentitiesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> did = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> profilePic = const Value.absent(),
                Value<String?> cardColor = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentitiesTableCompanion(
                id: id,
                did: did,
                displayName: displayName,
                profilePic: profilePic,
                cardColor: cardColor,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String did,
                required String displayName,
                Value<String?> profilePic = const Value.absent(),
                Value<String?> cardColor = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentitiesTableCompanion.insert(
                id: id,
                did: did,
                displayName: displayName,
                profilePic: profilePic,
                cardColor: cardColor,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdentitiesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$IdentitiesDatabase,
      $IdentitiesTableTable,
      IdentityRecord,
      $$IdentitiesTableTableFilterComposer,
      $$IdentitiesTableTableOrderingComposer,
      $$IdentitiesTableTableAnnotationComposer,
      $$IdentitiesTableTableCreateCompanionBuilder,
      $$IdentitiesTableTableUpdateCompanionBuilder,
      (
        IdentityRecord,
        BaseReferences<
          _$IdentitiesDatabase,
          $IdentitiesTableTable,
          IdentityRecord
        >,
      ),
      IdentityRecord,
      PrefetchHooks Function()
    >;

class $IdentitiesDatabaseManager {
  final _$IdentitiesDatabase _db;
  $IdentitiesDatabaseManager(this._db);
  $$IdentitiesTableTableTableManager get identitiesTable =>
      $$IdentitiesTableTableTableManager(_db, _db.identitiesTable);
}
