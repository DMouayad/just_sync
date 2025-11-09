// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_database.dart';

// ignore_for_file: type=lint
class $MockTableTable extends MockTable
    with TableInfo<$MockTableTable, TestModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MockTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeNameMeta = const VerificationMeta(
    'scopeName',
  );
  @override
  late final GeneratedColumn<String> scopeName = GeneratedColumn<String>(
    'scope_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeKeysMeta = const VerificationMeta(
    'scopeKeys',
  );
  @override
  late final GeneratedColumn<String> scopeKeys = GeneratedColumn<String>(
    'scope_keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAt =
      GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MockTableTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime> deletedAt =
      GeneratedColumn<DateTime>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($MockTableTable.$converterdeletedAtn);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(''),
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(0),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    scopeName,
    scopeKeys,
    updatedAt,
    deletedAt,
    id,
    title,
    status,
    count,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mock_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_name')) {
      context.handle(
        _scopeNameMeta,
        scopeName.isAcceptableOrUnknown(data['scope_name']!, _scopeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeNameMeta);
    }
    if (data.containsKey('scope_keys')) {
      context.handle(
        _scopeKeysMeta,
        scopeKeys.isAcceptableOrUnknown(data['scope_keys']!, _scopeKeysMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeKeysMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestModel(
      scopeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_name'],
      )!,
      scopeKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_keys'],
      )!,
      updatedAt: $MockTableTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $MockTableTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  $MockTableTable createAlias(String alias) {
    return $MockTableTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterupdatedAt =
      UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterdeletedAt =
      UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class TestModel extends DataClass
    implements Insertable<TestModel>, DriftModel<String>, SupportsSoftDelete {
  final String scopeName;
  final String scopeKeys;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String title;
  final String status;
  final int count;
  final String? tags;
  const TestModel({
    required this.scopeName,
    required this.scopeKeys,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.title,
    required this.status,
    required this.count,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_name'] = Variable<String>(scopeName);
    map['scope_keys'] = Variable<String>(scopeKeys);
    {
      map['updated_at'] = Variable<DateTime>(
        $MockTableTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(
        $MockTableTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    return map;
  }

  MockTableCompanion toCompanion(bool nullToAbsent) {
    return MockTableCompanion(
      scopeName: Value(scopeName),
      scopeKeys: Value(scopeKeys),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      title: Value(title),
      status: Value(status),
      count: Value(count),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory TestModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestModel(
      scopeName: serializer.fromJson<String>(json['scopeName']),
      scopeKeys: serializer.fromJson<String>(json['scopeKeys']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      count: serializer.fromJson<int>(json['count']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeName': serializer.toJson<String>(scopeName),
      'scopeKeys': serializer.toJson<String>(scopeKeys),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'count': serializer.toJson<int>(count),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  TestModel copyWith({
    String? scopeName,
    String? scopeKeys,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? title,
    String? status,
    int? count,
    Value<String?> tags = const Value.absent(),
  }) => TestModel(
    scopeName: scopeName ?? this.scopeName,
    scopeKeys: scopeKeys ?? this.scopeKeys,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    title: title ?? this.title,
    status: status ?? this.status,
    count: count ?? this.count,
    tags: tags.present ? tags.value : this.tags,
  );
  TestModel copyWithCompanion(MockTableCompanion data) {
    return TestModel(
      scopeName: data.scopeName.present ? data.scopeName.value : this.scopeName,
      scopeKeys: data.scopeKeys.present ? data.scopeKeys.value : this.scopeKeys,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      count: data.count.present ? data.count.value : this.count,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestModel(')
          ..write('scopeName: $scopeName, ')
          ..write('scopeKeys: $scopeKeys, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('count: $count, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    scopeName,
    scopeKeys,
    updatedAt,
    deletedAt,
    id,
    title,
    status,
    count,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestModel &&
          other.scopeName == this.scopeName &&
          other.scopeKeys == this.scopeKeys &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.title == this.title &&
          other.status == this.status &&
          other.count == this.count &&
          other.tags == this.tags);
}

class MockTableCompanion extends UpdateCompanion<TestModel> {
  final Value<String> scopeName;
  final Value<String> scopeKeys;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> title;
  final Value<String> status;
  final Value<int> count;
  final Value<String?> tags;
  final Value<int> rowid;
  const MockTableCompanion({
    this.scopeName = const Value.absent(),
    this.scopeKeys = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.count = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MockTableCompanion.insert({
    required String scopeName,
    required String scopeKeys,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String title,
    this.status = const Value.absent(),
    this.count = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scopeName = Value(scopeName),
       scopeKeys = Value(scopeKeys),
       updatedAt = Value(updatedAt),
       id = Value(id),
       title = Value(title);
  static Insertable<TestModel> custom({
    Expression<String>? scopeName,
    Expression<String>? scopeKeys,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? status,
    Expression<int>? count,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeName != null) 'scope_name': scopeName,
      if (scopeKeys != null) 'scope_keys': scopeKeys,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (count != null) 'count': count,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MockTableCompanion copyWith({
    Value<String>? scopeName,
    Value<String>? scopeKeys,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? title,
    Value<String>? status,
    Value<int>? count,
    Value<String?>? tags,
    Value<int>? rowid,
  }) {
    return MockTableCompanion(
      scopeName: scopeName ?? this.scopeName,
      scopeKeys: scopeKeys ?? this.scopeKeys,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      count: count ?? this.count,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeName.present) {
      map['scope_name'] = Variable<String>(scopeName.value);
    }
    if (scopeKeys.present) {
      map['scope_keys'] = Variable<String>(scopeKeys.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(
        $MockTableTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(
        $MockTableTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MockTableCompanion(')
          ..write('scopeName: $scopeName, ')
          ..write('scopeKeys: $scopeKeys, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('count: $count, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPointsTable extends SyncPoints
    with TableInfo<$SyncPointsTable, SyncPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeNameMeta = const VerificationMeta(
    'scopeName',
  );
  @override
  late final GeneratedColumn<String> scopeName = GeneratedColumn<String>(
    'scope_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeKeysMeta = const VerificationMeta(
    'scopeKeys',
  );
  @override
  late final GeneratedColumn<String> scopeKeys = GeneratedColumn<String>(
    'scope_keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> lastSyncedAt =
      GeneratedColumn<DateTime>(
        'last_synced_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SyncPointsTable.$converterlastSyncedAt);
  @override
  List<GeneratedColumn> get $columns => [scopeName, scopeKeys, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_name')) {
      context.handle(
        _scopeNameMeta,
        scopeName.isAcceptableOrUnknown(data['scope_name']!, _scopeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeNameMeta);
    }
    if (data.containsKey('scope_keys')) {
      context.handle(
        _scopeKeysMeta,
        scopeKeys.isAcceptableOrUnknown(data['scope_keys']!, _scopeKeysMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeKeysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scopeName, scopeKeys};
  @override
  SyncPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPoint(
      scopeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_name'],
      )!,
      scopeKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_keys'],
      )!,
      lastSyncedAt: $SyncPointsTable.$converterlastSyncedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_synced_at'],
        )!,
      ),
    );
  }

  @override
  $SyncPointsTable createAlias(String alias) {
    return $SyncPointsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterlastSyncedAt =
      UtcDateTimeConverter();
}

class SyncPoint extends DataClass implements Insertable<SyncPoint> {
  final String scopeName;
  final String scopeKeys;
  final DateTime lastSyncedAt;
  const SyncPoint({
    required this.scopeName,
    required this.scopeKeys,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_name'] = Variable<String>(scopeName);
    map['scope_keys'] = Variable<String>(scopeKeys);
    {
      map['last_synced_at'] = Variable<DateTime>(
        $SyncPointsTable.$converterlastSyncedAt.toSql(lastSyncedAt),
      );
    }
    return map;
  }

  SyncPointsCompanion toCompanion(bool nullToAbsent) {
    return SyncPointsCompanion(
      scopeName: Value(scopeName),
      scopeKeys: Value(scopeKeys),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory SyncPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPoint(
      scopeName: serializer.fromJson<String>(json['scopeName']),
      scopeKeys: serializer.fromJson<String>(json['scopeKeys']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeName': serializer.toJson<String>(scopeName),
      'scopeKeys': serializer.toJson<String>(scopeKeys),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  SyncPoint copyWith({
    String? scopeName,
    String? scopeKeys,
    DateTime? lastSyncedAt,
  }) => SyncPoint(
    scopeName: scopeName ?? this.scopeName,
    scopeKeys: scopeKeys ?? this.scopeKeys,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  SyncPoint copyWithCompanion(SyncPointsCompanion data) {
    return SyncPoint(
      scopeName: data.scopeName.present ? data.scopeName.value : this.scopeName,
      scopeKeys: data.scopeKeys.present ? data.scopeKeys.value : this.scopeKeys,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPoint(')
          ..write('scopeName: $scopeName, ')
          ..write('scopeKeys: $scopeKeys, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scopeName, scopeKeys, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPoint &&
          other.scopeName == this.scopeName &&
          other.scopeKeys == this.scopeKeys &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncPointsCompanion extends UpdateCompanion<SyncPoint> {
  final Value<String> scopeName;
  final Value<String> scopeKeys;
  final Value<DateTime> lastSyncedAt;
  final Value<int> rowid;
  const SyncPointsCompanion({
    this.scopeName = const Value.absent(),
    this.scopeKeys = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncPointsCompanion.insert({
    required String scopeName,
    required String scopeKeys,
    required DateTime lastSyncedAt,
    this.rowid = const Value.absent(),
  }) : scopeName = Value(scopeName),
       scopeKeys = Value(scopeKeys),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<SyncPoint> custom({
    Expression<String>? scopeName,
    Expression<String>? scopeKeys,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeName != null) 'scope_name': scopeName,
      if (scopeKeys != null) 'scope_keys': scopeKeys,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncPointsCompanion copyWith({
    Value<String>? scopeName,
    Value<String>? scopeKeys,
    Value<DateTime>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncPointsCompanion(
      scopeName: scopeName ?? this.scopeName,
      scopeKeys: scopeKeys ?? this.scopeKeys,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeName.present) {
      map['scope_name'] = Variable<String>(scopeName.value);
    }
    if (scopeKeys.present) {
      map['scope_keys'] = Variable<String>(scopeKeys.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(
        $SyncPointsTable.$converterlastSyncedAt.toSql(lastSyncedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPointsCompanion(')
          ..write('scopeName: $scopeName, ')
          ..write('scopeKeys: $scopeKeys, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOpsTable extends PendingOps
    with TableInfo<$PendingOpsTable, PendingOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeNameMeta = const VerificationMeta(
    'scopeName',
  );
  @override
  late final GeneratedColumn<String> scopeName = GeneratedColumn<String>(
    'scope_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeKeysMeta = const VerificationMeta(
    'scopeKeys',
  );
  @override
  late final GeneratedColumn<String> scopeKeys = GeneratedColumn<String>(
    'scope_keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PendingOpType, int> opType =
      GeneratedColumn<int>(
        'op_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<PendingOpType>($PendingOpsTable.$converteropType);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAt =
      GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PendingOpsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scopeName,
    scopeKeys,
    opType,
    entityId,
    payload,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scope_name')) {
      context.handle(
        _scopeNameMeta,
        scopeName.isAcceptableOrUnknown(data['scope_name']!, _scopeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeNameMeta);
    }
    if (data.containsKey('scope_keys')) {
      context.handle(
        _scopeKeysMeta,
        scopeKeys.isAcceptableOrUnknown(data['scope_keys']!, _scopeKeysMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeKeysMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scopeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_name'],
      )!,
      scopeKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_keys'],
      )!,
      opType: $PendingOpsTable.$converteropType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}op_type'],
        )!,
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      updatedAt: $PendingOpsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $PendingOpsTable createAlias(String alias) {
    return $PendingOpsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PendingOpType, int, int> $converteropType =
      const EnumIndexConverter<PendingOpType>(PendingOpType.values);
  static TypeConverter<DateTime, DateTime> $converterupdatedAt =
      UtcDateTimeConverter();
}

class PendingOp extends DataClass implements Insertable<PendingOp> {
  final String id;
  final String scopeName;
  final String scopeKeys;
  final PendingOpType opType;
  final String entityId;
  final String? payload;
  final DateTime updatedAt;
  const PendingOp({
    required this.id,
    required this.scopeName,
    required this.scopeKeys,
    required this.opType,
    required this.entityId,
    this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scope_name'] = Variable<String>(scopeName);
    map['scope_keys'] = Variable<String>(scopeKeys);
    {
      map['op_type'] = Variable<int>(
        $PendingOpsTable.$converteropType.toSql(opType),
      );
    }
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    {
      map['updated_at'] = Variable<DateTime>(
        $PendingOpsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  PendingOpsCompanion toCompanion(bool nullToAbsent) {
    return PendingOpsCompanion(
      id: Value(id),
      scopeName: Value(scopeName),
      scopeKeys: Value(scopeKeys),
      opType: Value(opType),
      entityId: Value(entityId),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory PendingOp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOp(
      id: serializer.fromJson<String>(json['id']),
      scopeName: serializer.fromJson<String>(json['scopeName']),
      scopeKeys: serializer.fromJson<String>(json['scopeKeys']),
      opType: $PendingOpsTable.$converteropType.fromJson(
        serializer.fromJson<int>(json['opType']),
      ),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String?>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scopeName': serializer.toJson<String>(scopeName),
      'scopeKeys': serializer.toJson<String>(scopeKeys),
      'opType': serializer.toJson<int>(
        $PendingOpsTable.$converteropType.toJson(opType),
      ),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String?>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PendingOp copyWith({
    String? id,
    String? scopeName,
    String? scopeKeys,
    PendingOpType? opType,
    String? entityId,
    Value<String?> payload = const Value.absent(),
    DateTime? updatedAt,
  }) => PendingOp(
    id: id ?? this.id,
    scopeName: scopeName ?? this.scopeName,
    scopeKeys: scopeKeys ?? this.scopeKeys,
    opType: opType ?? this.opType,
    entityId: entityId ?? this.entityId,
    payload: payload.present ? payload.value : this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PendingOp copyWithCompanion(PendingOpsCompanion data) {
    return PendingOp(
      id: data.id.present ? data.id.value : this.id,
      scopeName: data.scopeName.present ? data.scopeName.value : this.scopeName,
      scopeKeys: data.scopeKeys.present ? data.scopeKeys.value : this.scopeKeys,
      opType: data.opType.present ? data.opType.value : this.opType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOp(')
          ..write('id: $id, ')
          ..write('scopeName: $scopeName, ')
          ..write('scopeKeys: $scopeKeys, ')
          ..write('opType: $opType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scopeName,
    scopeKeys,
    opType,
    entityId,
    payload,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOp &&
          other.id == this.id &&
          other.scopeName == this.scopeName &&
          other.scopeKeys == this.scopeKeys &&
          other.opType == this.opType &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class PendingOpsCompanion extends UpdateCompanion<PendingOp> {
  final Value<String> id;
  final Value<String> scopeName;
  final Value<String> scopeKeys;
  final Value<PendingOpType> opType;
  final Value<String> entityId;
  final Value<String?> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PendingOpsCompanion({
    this.id = const Value.absent(),
    this.scopeName = const Value.absent(),
    this.scopeKeys = const Value.absent(),
    this.opType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingOpsCompanion.insert({
    required String id,
    required String scopeName,
    required String scopeKeys,
    required PendingOpType opType,
    required String entityId,
    this.payload = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scopeName = Value(scopeName),
       scopeKeys = Value(scopeKeys),
       opType = Value(opType),
       entityId = Value(entityId),
       updatedAt = Value(updatedAt);
  static Insertable<PendingOp> custom({
    Expression<String>? id,
    Expression<String>? scopeName,
    Expression<String>? scopeKeys,
    Expression<int>? opType,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scopeName != null) 'scope_name': scopeName,
      if (scopeKeys != null) 'scope_keys': scopeKeys,
      if (opType != null) 'op_type': opType,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingOpsCompanion copyWith({
    Value<String>? id,
    Value<String>? scopeName,
    Value<String>? scopeKeys,
    Value<PendingOpType>? opType,
    Value<String>? entityId,
    Value<String?>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PendingOpsCompanion(
      id: id ?? this.id,
      scopeName: scopeName ?? this.scopeName,
      scopeKeys: scopeKeys ?? this.scopeKeys,
      opType: opType ?? this.opType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scopeName.present) {
      map['scope_name'] = Variable<String>(scopeName.value);
    }
    if (scopeKeys.present) {
      map['scope_keys'] = Variable<String>(scopeKeys.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<int>(
        $PendingOpsTable.$converteropType.toSql(opType.value),
      );
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(
        $PendingOpsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpsCompanion(')
          ..write('id: $id, ')
          ..write('scopeName: $scopeName, ')
          ..write('scopeKeys: $scopeKeys, ')
          ..write('opType: $opType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TestDatabase extends GeneratedDatabase {
  _$TestDatabase(QueryExecutor e) : super(e);
  $TestDatabaseManager get managers => $TestDatabaseManager(this);
  late final $MockTableTable mockTable = $MockTableTable(this);
  late final $SyncPointsTable syncPoints = $SyncPointsTable(this);
  late final $PendingOpsTable pendingOps = $PendingOpsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mockTable,
    syncPoints,
    pendingOps,
  ];
}

typedef $$MockTableTableCreateCompanionBuilder =
    MockTableCompanion Function({
      required String scopeName,
      required String scopeKeys,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String title,
      Value<String> status,
      Value<int> count,
      Value<String?> tags,
      Value<int> rowid,
    });
typedef $$MockTableTableUpdateCompanionBuilder =
    MockTableCompanion Function({
      Value<String> scopeName,
      Value<String> scopeKeys,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> title,
      Value<String> status,
      Value<int> count,
      Value<String?> tags,
      Value<int> rowid,
    });

class $$MockTableTableFilterComposer
    extends Composer<_$TestDatabase, $MockTableTable> {
  $$MockTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeName => $composableBuilder(
    column: $table.scopeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeKeys => $composableBuilder(
    column: $table.scopeKeys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, DateTime> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MockTableTableOrderingComposer
    extends Composer<_$TestDatabase, $MockTableTable> {
  $$MockTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeName => $composableBuilder(
    column: $table.scopeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeKeys => $composableBuilder(
    column: $table.scopeKeys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MockTableTableAnnotationComposer
    extends Composer<_$TestDatabase, $MockTableTable> {
  $$MockTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeName =>
      $composableBuilder(column: $table.scopeName, builder: (column) => column);

  GeneratedColumn<String> get scopeKeys =>
      $composableBuilder(column: $table.scopeKeys, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $$MockTableTableTableManager
    extends
        RootTableManager<
          _$TestDatabase,
          $MockTableTable,
          TestModel,
          $$MockTableTableFilterComposer,
          $$MockTableTableOrderingComposer,
          $$MockTableTableAnnotationComposer,
          $$MockTableTableCreateCompanionBuilder,
          $$MockTableTableUpdateCompanionBuilder,
          (
            TestModel,
            BaseReferences<_$TestDatabase, $MockTableTable, TestModel>,
          ),
          TestModel,
          PrefetchHooks Function()
        > {
  $$MockTableTableTableManager(_$TestDatabase db, $MockTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MockTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MockTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MockTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scopeName = const Value.absent(),
                Value<String> scopeKeys = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MockTableCompanion(
                scopeName: scopeName,
                scopeKeys: scopeKeys,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                title: title,
                status: status,
                count: count,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scopeName,
                required String scopeKeys,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String title,
                Value<String> status = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MockTableCompanion.insert(
                scopeName: scopeName,
                scopeKeys: scopeKeys,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                title: title,
                status: status,
                count: count,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MockTableTableProcessedTableManager =
    ProcessedTableManager<
      _$TestDatabase,
      $MockTableTable,
      TestModel,
      $$MockTableTableFilterComposer,
      $$MockTableTableOrderingComposer,
      $$MockTableTableAnnotationComposer,
      $$MockTableTableCreateCompanionBuilder,
      $$MockTableTableUpdateCompanionBuilder,
      (TestModel, BaseReferences<_$TestDatabase, $MockTableTable, TestModel>),
      TestModel,
      PrefetchHooks Function()
    >;
typedef $$SyncPointsTableCreateCompanionBuilder =
    SyncPointsCompanion Function({
      required String scopeName,
      required String scopeKeys,
      required DateTime lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SyncPointsTableUpdateCompanionBuilder =
    SyncPointsCompanion Function({
      Value<String> scopeName,
      Value<String> scopeKeys,
      Value<DateTime> lastSyncedAt,
      Value<int> rowid,
    });

class $$SyncPointsTableFilterComposer
    extends Composer<_$TestDatabase, $SyncPointsTable> {
  $$SyncPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeName => $composableBuilder(
    column: $table.scopeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeKeys => $composableBuilder(
    column: $table.scopeKeys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime>
  get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$SyncPointsTableOrderingComposer
    extends Composer<_$TestDatabase, $SyncPointsTable> {
  $$SyncPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeName => $composableBuilder(
    column: $table.scopeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeKeys => $composableBuilder(
    column: $table.scopeKeys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncPointsTableAnnotationComposer
    extends Composer<_$TestDatabase, $SyncPointsTable> {
  $$SyncPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeName =>
      $composableBuilder(column: $table.scopeName, builder: (column) => column);

  GeneratedColumn<String> get scopeKeys =>
      $composableBuilder(column: $table.scopeKeys, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get lastSyncedAt =>
      $composableBuilder(
        column: $table.lastSyncedAt,
        builder: (column) => column,
      );
}

class $$SyncPointsTableTableManager
    extends
        RootTableManager<
          _$TestDatabase,
          $SyncPointsTable,
          SyncPoint,
          $$SyncPointsTableFilterComposer,
          $$SyncPointsTableOrderingComposer,
          $$SyncPointsTableAnnotationComposer,
          $$SyncPointsTableCreateCompanionBuilder,
          $$SyncPointsTableUpdateCompanionBuilder,
          (
            SyncPoint,
            BaseReferences<_$TestDatabase, $SyncPointsTable, SyncPoint>,
          ),
          SyncPoint,
          PrefetchHooks Function()
        > {
  $$SyncPointsTableTableManager(_$TestDatabase db, $SyncPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scopeName = const Value.absent(),
                Value<String> scopeKeys = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPointsCompanion(
                scopeName: scopeName,
                scopeKeys: scopeKeys,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scopeName,
                required String scopeKeys,
                required DateTime lastSyncedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncPointsCompanion.insert(
                scopeName: scopeName,
                scopeKeys: scopeKeys,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$TestDatabase,
      $SyncPointsTable,
      SyncPoint,
      $$SyncPointsTableFilterComposer,
      $$SyncPointsTableOrderingComposer,
      $$SyncPointsTableAnnotationComposer,
      $$SyncPointsTableCreateCompanionBuilder,
      $$SyncPointsTableUpdateCompanionBuilder,
      (SyncPoint, BaseReferences<_$TestDatabase, $SyncPointsTable, SyncPoint>),
      SyncPoint,
      PrefetchHooks Function()
    >;
typedef $$PendingOpsTableCreateCompanionBuilder =
    PendingOpsCompanion Function({
      required String id,
      required String scopeName,
      required String scopeKeys,
      required PendingOpType opType,
      required String entityId,
      Value<String?> payload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PendingOpsTableUpdateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<String> id,
      Value<String> scopeName,
      Value<String> scopeKeys,
      Value<PendingOpType> opType,
      Value<String> entityId,
      Value<String?> payload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PendingOpsTableFilterComposer
    extends Composer<_$TestDatabase, $PendingOpsTable> {
  $$PendingOpsTableFilterComposer({
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

  ColumnFilters<String> get scopeName => $composableBuilder(
    column: $table.scopeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeKeys => $composableBuilder(
    column: $table.scopeKeys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PendingOpType, PendingOpType, int>
  get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$PendingOpsTableOrderingComposer
    extends Composer<_$TestDatabase, $PendingOpsTable> {
  $$PendingOpsTableOrderingComposer({
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

  ColumnOrderings<String> get scopeName => $composableBuilder(
    column: $table.scopeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeKeys => $composableBuilder(
    column: $table.scopeKeys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOpsTableAnnotationComposer
    extends Composer<_$TestDatabase, $PendingOpsTable> {
  $$PendingOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scopeName =>
      $composableBuilder(column: $table.scopeName, builder: (column) => column);

  GeneratedColumn<String> get scopeKeys =>
      $composableBuilder(column: $table.scopeKeys, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingOpType, int> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PendingOpsTableTableManager
    extends
        RootTableManager<
          _$TestDatabase,
          $PendingOpsTable,
          PendingOp,
          $$PendingOpsTableFilterComposer,
          $$PendingOpsTableOrderingComposer,
          $$PendingOpsTableAnnotationComposer,
          $$PendingOpsTableCreateCompanionBuilder,
          $$PendingOpsTableUpdateCompanionBuilder,
          (
            PendingOp,
            BaseReferences<_$TestDatabase, $PendingOpsTable, PendingOp>,
          ),
          PendingOp,
          PrefetchHooks Function()
        > {
  $$PendingOpsTableTableManager(_$TestDatabase db, $PendingOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scopeName = const Value.absent(),
                Value<String> scopeKeys = const Value.absent(),
                Value<PendingOpType> opType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOpsCompanion(
                id: id,
                scopeName: scopeName,
                scopeKeys: scopeKeys,
                opType: opType,
                entityId: entityId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scopeName,
                required String scopeKeys,
                required PendingOpType opType,
                required String entityId,
                Value<String?> payload = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingOpsCompanion.insert(
                id: id,
                scopeName: scopeName,
                scopeKeys: scopeKeys,
                opType: opType,
                entityId: entityId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$TestDatabase,
      $PendingOpsTable,
      PendingOp,
      $$PendingOpsTableFilterComposer,
      $$PendingOpsTableOrderingComposer,
      $$PendingOpsTableAnnotationComposer,
      $$PendingOpsTableCreateCompanionBuilder,
      $$PendingOpsTableUpdateCompanionBuilder,
      (PendingOp, BaseReferences<_$TestDatabase, $PendingOpsTable, PendingOp>),
      PendingOp,
      PrefetchHooks Function()
    >;

class $TestDatabaseManager {
  final _$TestDatabase _db;
  $TestDatabaseManager(this._db);
  $$MockTableTableTableManager get mockTable =>
      $$MockTableTableTableManager(_db, _db.mockTable);
  $$SyncPointsTableTableManager get syncPoints =>
      $$SyncPointsTableTableManager(_db, _db.syncPoints);
  $$PendingOpsTableTableManager get pendingOps =>
      $$PendingOpsTableTableManager(_db, _db.pendingOps);
}
