// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mediators_database.dart';

// ignore_for_file: type=lint
class $MediatorsTable extends Mediators
    with TableInfo<$MediatorsTable, Mediator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: const Uuid().v4,
  );
  static const VerificationMeta _mediatorNameMeta = const VerificationMeta(
    'mediatorName',
  );
  @override
  late final GeneratedColumn<String> mediatorName = GeneratedColumn<String>(
    'mediator_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediatorDidMeta = const VerificationMeta(
    'mediatorDid',
  );
  @override
  late final GeneratedColumn<String> mediatorDid = GeneratedColumn<String>(
    'mediator_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediatorType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MediatorType>($MediatorsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<MediatorStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MediatorStatus>($MediatorsTable.$converterstatus);
  static const VerificationMeta _createdTimeMeta = const VerificationMeta(
    'createdTime',
  );
  @override
  late final GeneratedColumn<String> createdTime = GeneratedColumn<String>(
    'created_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toIso8601String(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediatorName,
    mediatorDid,
    type,
    status,
    createdTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mediators';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mediator> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mediator_name')) {
      context.handle(
        _mediatorNameMeta,
        mediatorName.isAcceptableOrUnknown(
          data['mediator_name']!,
          _mediatorNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediatorNameMeta);
    }
    if (data.containsKey('mediator_did')) {
      context.handle(
        _mediatorDidMeta,
        mediatorDid.isAcceptableOrUnknown(
          data['mediator_did']!,
          _mediatorDidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediatorDidMeta);
    }
    if (data.containsKey('created_time')) {
      context.handle(
        _createdTimeMeta,
        createdTime.isAcceptableOrUnknown(
          data['created_time']!,
          _createdTimeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mediator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mediator(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediatorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mediator_name'],
      )!,
      mediatorDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mediator_did'],
      )!,
      type: $MediatorsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      status: $MediatorsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_time'],
      )!,
    );
  }

  @override
  $MediatorsTable createAlias(String alias) {
    return $MediatorsTable(attachedDatabase, alias);
  }

  static TypeConverter<MediatorType, int> $convertertype =
      const _MediatorTypeConverter();
  static TypeConverter<MediatorStatus, int> $converterstatus =
      const _MediatorStatusConverter();
}

class Mediator extends DataClass implements Insertable<Mediator> {
  final String id;
  final String mediatorName;
  final String mediatorDid;
  final MediatorType type;
  final MediatorStatus status;
  final String createdTime;
  const Mediator({
    required this.id,
    required this.mediatorName,
    required this.mediatorDid,
    required this.type,
    required this.status,
    required this.createdTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mediator_name'] = Variable<String>(mediatorName);
    map['mediator_did'] = Variable<String>(mediatorDid);
    {
      map['type'] = Variable<int>($MediatorsTable.$convertertype.toSql(type));
    }
    {
      map['status'] = Variable<int>(
        $MediatorsTable.$converterstatus.toSql(status),
      );
    }
    map['created_time'] = Variable<String>(createdTime);
    return map;
  }

  MediatorsCompanion toCompanion(bool nullToAbsent) {
    return MediatorsCompanion(
      id: Value(id),
      mediatorName: Value(mediatorName),
      mediatorDid: Value(mediatorDid),
      type: Value(type),
      status: Value(status),
      createdTime: Value(createdTime),
    );
  }

  factory Mediator.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mediator(
      id: serializer.fromJson<String>(json['id']),
      mediatorName: serializer.fromJson<String>(json['mediatorName']),
      mediatorDid: serializer.fromJson<String>(json['mediatorDid']),
      type: serializer.fromJson<MediatorType>(json['type']),
      status: serializer.fromJson<MediatorStatus>(json['status']),
      createdTime: serializer.fromJson<String>(json['createdTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediatorName': serializer.toJson<String>(mediatorName),
      'mediatorDid': serializer.toJson<String>(mediatorDid),
      'type': serializer.toJson<MediatorType>(type),
      'status': serializer.toJson<MediatorStatus>(status),
      'createdTime': serializer.toJson<String>(createdTime),
    };
  }

  Mediator copyWith({
    String? id,
    String? mediatorName,
    String? mediatorDid,
    MediatorType? type,
    MediatorStatus? status,
    String? createdTime,
  }) => Mediator(
    id: id ?? this.id,
    mediatorName: mediatorName ?? this.mediatorName,
    mediatorDid: mediatorDid ?? this.mediatorDid,
    type: type ?? this.type,
    status: status ?? this.status,
    createdTime: createdTime ?? this.createdTime,
  );
  Mediator copyWithCompanion(MediatorsCompanion data) {
    return Mediator(
      id: data.id.present ? data.id.value : this.id,
      mediatorName: data.mediatorName.present
          ? data.mediatorName.value
          : this.mediatorName,
      mediatorDid: data.mediatorDid.present
          ? data.mediatorDid.value
          : this.mediatorDid,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      createdTime: data.createdTime.present
          ? data.createdTime.value
          : this.createdTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mediator(')
          ..write('id: $id, ')
          ..write('mediatorName: $mediatorName, ')
          ..write('mediatorDid: $mediatorDid, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('createdTime: $createdTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mediatorName, mediatorDid, type, status, createdTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mediator &&
          other.id == this.id &&
          other.mediatorName == this.mediatorName &&
          other.mediatorDid == this.mediatorDid &&
          other.type == this.type &&
          other.status == this.status &&
          other.createdTime == this.createdTime);
}

class MediatorsCompanion extends UpdateCompanion<Mediator> {
  final Value<String> id;
  final Value<String> mediatorName;
  final Value<String> mediatorDid;
  final Value<MediatorType> type;
  final Value<MediatorStatus> status;
  final Value<String> createdTime;
  final Value<int> rowid;
  const MediatorsCompanion({
    this.id = const Value.absent(),
    this.mediatorName = const Value.absent(),
    this.mediatorDid = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.createdTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediatorsCompanion.insert({
    this.id = const Value.absent(),
    required String mediatorName,
    required String mediatorDid,
    required MediatorType type,
    required MediatorStatus status,
    this.createdTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mediatorName = Value(mediatorName),
       mediatorDid = Value(mediatorDid),
       type = Value(type),
       status = Value(status);
  static Insertable<Mediator> custom({
    Expression<String>? id,
    Expression<String>? mediatorName,
    Expression<String>? mediatorDid,
    Expression<int>? type,
    Expression<int>? status,
    Expression<String>? createdTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediatorName != null) 'mediator_name': mediatorName,
      if (mediatorDid != null) 'mediator_did': mediatorDid,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (createdTime != null) 'created_time': createdTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediatorsCompanion copyWith({
    Value<String>? id,
    Value<String>? mediatorName,
    Value<String>? mediatorDid,
    Value<MediatorType>? type,
    Value<MediatorStatus>? status,
    Value<String>? createdTime,
    Value<int>? rowid,
  }) {
    return MediatorsCompanion(
      id: id ?? this.id,
      mediatorName: mediatorName ?? this.mediatorName,
      mediatorDid: mediatorDid ?? this.mediatorDid,
      type: type ?? this.type,
      status: status ?? this.status,
      createdTime: createdTime ?? this.createdTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediatorName.present) {
      map['mediator_name'] = Variable<String>(mediatorName.value);
    }
    if (mediatorDid.present) {
      map['mediator_did'] = Variable<String>(mediatorDid.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $MediatorsTable.$convertertype.toSql(type.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $MediatorsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdTime.present) {
      map['created_time'] = Variable<String>(createdTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediatorsCompanion(')
          ..write('id: $id, ')
          ..write('mediatorName: $mediatorName, ')
          ..write('mediatorDid: $mediatorDid, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('createdTime: $createdTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MediatorsDatabase extends GeneratedDatabase {
  _$MediatorsDatabase(QueryExecutor e) : super(e);
  $MediatorsDatabaseManager get managers => $MediatorsDatabaseManager(this);
  late final $MediatorsTable mediators = $MediatorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [mediators];
}

typedef $$MediatorsTableCreateCompanionBuilder =
    MediatorsCompanion Function({
      Value<String> id,
      required String mediatorName,
      required String mediatorDid,
      required MediatorType type,
      required MediatorStatus status,
      Value<String> createdTime,
      Value<int> rowid,
    });
typedef $$MediatorsTableUpdateCompanionBuilder =
    MediatorsCompanion Function({
      Value<String> id,
      Value<String> mediatorName,
      Value<String> mediatorDid,
      Value<MediatorType> type,
      Value<MediatorStatus> status,
      Value<String> createdTime,
      Value<int> rowid,
    });

class $$MediatorsTableFilterComposer
    extends Composer<_$MediatorsDatabase, $MediatorsTable> {
  $$MediatorsTableFilterComposer({
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

  ColumnFilters<String> get mediatorName => $composableBuilder(
    column: $table.mediatorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediatorDid => $composableBuilder(
    column: $table.mediatorDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediatorType, MediatorType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MediatorStatus, MediatorStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get createdTime => $composableBuilder(
    column: $table.createdTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediatorsTableOrderingComposer
    extends Composer<_$MediatorsDatabase, $MediatorsTable> {
  $$MediatorsTableOrderingComposer({
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

  ColumnOrderings<String> get mediatorName => $composableBuilder(
    column: $table.mediatorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediatorDid => $composableBuilder(
    column: $table.mediatorDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdTime => $composableBuilder(
    column: $table.createdTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediatorsTableAnnotationComposer
    extends Composer<_$MediatorsDatabase, $MediatorsTable> {
  $$MediatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mediatorName => $composableBuilder(
    column: $table.mediatorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediatorDid => $composableBuilder(
    column: $table.mediatorDid,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MediatorType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediatorStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdTime => $composableBuilder(
    column: $table.createdTime,
    builder: (column) => column,
  );
}

class $$MediatorsTableTableManager
    extends
        RootTableManager<
          _$MediatorsDatabase,
          $MediatorsTable,
          Mediator,
          $$MediatorsTableFilterComposer,
          $$MediatorsTableOrderingComposer,
          $$MediatorsTableAnnotationComposer,
          $$MediatorsTableCreateCompanionBuilder,
          $$MediatorsTableUpdateCompanionBuilder,
          (
            Mediator,
            BaseReferences<_$MediatorsDatabase, $MediatorsTable, Mediator>,
          ),
          Mediator,
          PrefetchHooks Function()
        > {
  $$MediatorsTableTableManager(_$MediatorsDatabase db, $MediatorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediatorName = const Value.absent(),
                Value<String> mediatorDid = const Value.absent(),
                Value<MediatorType> type = const Value.absent(),
                Value<MediatorStatus> status = const Value.absent(),
                Value<String> createdTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediatorsCompanion(
                id: id,
                mediatorName: mediatorName,
                mediatorDid: mediatorDid,
                type: type,
                status: status,
                createdTime: createdTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String mediatorName,
                required String mediatorDid,
                required MediatorType type,
                required MediatorStatus status,
                Value<String> createdTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediatorsCompanion.insert(
                id: id,
                mediatorName: mediatorName,
                mediatorDid: mediatorDid,
                type: type,
                status: status,
                createdTime: createdTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$MediatorsDatabase,
      $MediatorsTable,
      Mediator,
      $$MediatorsTableFilterComposer,
      $$MediatorsTableOrderingComposer,
      $$MediatorsTableAnnotationComposer,
      $$MediatorsTableCreateCompanionBuilder,
      $$MediatorsTableUpdateCompanionBuilder,
      (
        Mediator,
        BaseReferences<_$MediatorsDatabase, $MediatorsTable, Mediator>,
      ),
      Mediator,
      PrefetchHooks Function()
    >;

class $MediatorsDatabaseManager {
  final _$MediatorsDatabase _db;
  $MediatorsDatabaseManager(this._db);
  $$MediatorsTableTableManager get mediators =>
      $$MediatorsTableTableManager(_db, _db.mediators);
}
