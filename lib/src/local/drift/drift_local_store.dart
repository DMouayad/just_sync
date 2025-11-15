import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import 'package:just_sync/src/core/store_interfaces.dart';
import 'package:just_sync/src/local/drift/database_interface.dart';
import 'package:just_sync/src/models/pending_op.dart';
import 'package:just_sync/src/models/query_spec.dart';
import 'package:just_sync/src/models/sync_scope.dart';
import 'package:just_sync/src/models/traits.dart';

/// Marker interface for models that are Drift DataClasses and implement
/// [HasId] and [HasUpdatedAt].
///
/// Your generated Drift `DataClass` should implement this interface using
/// the `implementing` argument in the `@DataClassName` annotation.
///
/// Example:
/// ```dart
/// @DataClassName(
///   'MyModel',
///   implementing: [DriftModel<String>, SupportsSoftDelete],
/// )
/// class MyTable extends Table with DriftSyncTableMixin { ... }
/// ```
abstract interface class DriftModel<Id> implements HasId<Id>, HasUpdatedAt {
  Map<String, dynamic> toJson();
}

/// A concrete implementation of [LocalStore] for Drift databases.
///
/// Instead of extending this class, you should instantiate it with the required
/// configuration for your specific data model and Drift table.
class DriftLocalStore<DB extends IDriftDatabase, T extends DriftModel<Id>, Id>
    implements LocalStore<T, Id> {
  @override
  final String scopeName;
  final DB db;
  final drift.TableInfo table;
  final Id Function(String stringId) idFromString;
  final String Function(Id id) idToString;
  final T Function(Map<String, dynamic>) fromJson;
  final drift.Insertable<T> Function(T model, SyncScopeKeys scopeKeys)
  toInsertCompanion;
  final drift.Insertable<T> Function(T model) toUpdateCompanion;
  final drift.Insertable<T> Function() toSoftDeleteCompanion;

  const DriftLocalStore(
    this.db, {
    required this.scopeName,
    required this.table,
    required this.idFromString,
    required this.idToString,
    required this.fromJson,
    required this.toInsertCompanion,
    required this.toUpdateCompanion,
    required this.toSoftDeleteCompanion,
  });

  @override
  bool get supportsSoftDelete => table.columnsByName.containsKey('deleted_at');

  String _toSnakeCase(String text) {
    return text
        .replaceAllMapped(RegExp('(?<=[a-z])[A-Z]'), (m) => '_${m.group(0)}')
        .toLowerCase();
  }

  drift.GeneratedColumn _resolveColumn(String fieldName) {
    final column = table.columnsByName[_toSnakeCase(fieldName)];
    if (column == null) {
      throw ArgumentError(
        'Column $fieldName not found in table ${table.actualTableName}',
      );
    }
    return column;
  }

  @override
  Future<T?> getById(Id id) async {
    final query = db.select(table)
      ..where((t) => _resolveColumn('id').equals(idToString(id)));

    if (supportsSoftDelete) {
      query.where((t) => _resolveColumn('deletedAt').isNull());
    }

    return await query.getSingleOrNull();
  }

  @override
  Future<void> upsertMany(SyncScopeKeys scopeKeys, List<T> items) async {
    final companions = items
        .map((item) => toInsertCompanion(item, scopeKeys))
        .toList();
    if (companions.isEmpty) return;

    await db.batch((batch) {
      batch.insertAll(
        table,
        companions,
        mode: drift.InsertMode.insertOrReplace,
      );
    });
  }

  @override
  Future<void> deleteMany(SyncScopeKeys scopeKeys, List<Id> ids) async {
    if (ids.isEmpty) return;

    final idColumn = _resolveColumn('id');
    // This assumes the ID column type is compatible with what `idToString` produces.
    final stringIds = ids.map(idToString).toList();

    buildWhereClause() {
      final scopeNameCol = _resolveColumn('scopeName');
      final scopeKeysCol = _resolveColumn('scopeKeys');

      final scopeFilter =
          buildFilter(scopeNameCol, QueryFilter.eq('scopeName', scopeName)) &
          buildFilter(
            scopeKeysCol,
            QueryFilter.eq('scopeKeys', scopeKeys.toJson()),
          );

      final idFilter = idColumn.isIn(stringIds);

      return (_) => scopeFilter & idFilter;
    }

    if (supportsSoftDelete) {
      final companion = toSoftDeleteCompanion();
      await (db.update(table)..where(buildWhereClause())).write(companion);
    } else {
      await (db.delete(table)..where(buildWhereClause())).go();
    }
  }

  @override
  Future<int> updateWhere(
    SyncScopeKeys scopeKeys,
    QuerySpec spec,
    List<T> newValues,
  ) async {
    if (newValues.isEmpty) return 0;

    final query = db.update(table);

    // Apply scope
    final scopeNameCol = _resolveColumn('scopeName');
    final scopeKeysCol = _resolveColumn('scopeKeys');
    query.where(
      (_) =>
          buildFilter(scopeNameCol, QueryFilter.eq('scopeName', scopeName)) &
          buildFilter(
            scopeKeysCol,
            QueryFilter.eq('scopeKeys', scopeKeys.toJson()),
          ),
    );

    // Exclude soft-deleted items from updates
    if (supportsSoftDelete) {
      query.where((t) => _resolveColumn('deletedAt').isNull());
    }

    // Apply QuerySpec filters
    drift.Expression<bool>? filter;
    for (final f in spec.filters) {
      final newFilter = buildFilter(_resolveColumn(f.field), f);
      if (filter == null) {
        filter = newFilter;
      } else {
        filter = filter & newFilter;
      }
    }
    if (filter != null) {
      query.where((_) => filter!);
    }

    final companion = toUpdateCompanion(newValues.first);
    return await query.write(companion);
  }

  @override
  Future<int> deleteWhere(SyncScopeKeys scopeKeys, QuerySpec spec) async {
    buildWhereClause() {
      final scopeNameCol = _resolveColumn('scopeName');
      final scopeKeysCol = _resolveColumn('scopeKeys');
      drift.Expression<bool> combinedFilter =
          buildFilter(scopeNameCol, QueryFilter.eq('scopeName', scopeName)) &
          buildFilter(
            scopeKeysCol,
            QueryFilter.eq('scopeKeys', scopeKeys.toJson()),
          );

      // Apply QuerySpec filters
      drift.Expression<bool>? specFilter;
      for (final f in spec.filters) {
        final newFilter = buildFilter(_resolveColumn(f.field), f);
        if (specFilter == null) {
          specFilter = newFilter;
        } else {
          specFilter = specFilter & newFilter;
        }
      }

      if (specFilter != null) {
        combinedFilter = combinedFilter & specFilter;
      }
      return (_) => combinedFilter;
    }

    if (supportsSoftDelete) {
      final companion = toSoftDeleteCompanion();
      return await (db.update(
        table,
      )..where(buildWhereClause())).write(companion);
    } else {
      return await (db.delete(table)..where(buildWhereClause())).go();
    }
  }

  @override
  Future<List<T>> query(SyncScopeKeys scopeKeys) {
    return queryWith(scopeKeys, const QuerySpec());
  }

  @override
  Future<List<T>> querySince(SyncScopeKeys scopeKeys, DateTime since) {
    return queryWith(
      scopeKeys,
      QuerySpec(filters: [QueryFilter.gt('updatedAt', since)]),
    );
  }

  @override
  Future<List<T>> queryWith(SyncScopeKeys scopeKeys, QuerySpec spec) async {
    final query = db.select(table);

    // Apply scope
    final scopeNameCol = _resolveColumn('scopeName');
    final scopeKeysCol = _resolveColumn('scopeKeys');
    query.where(
      (_) =>
          buildFilter(scopeNameCol, QueryFilter.eq('scopeName', scopeName)) &
          buildFilter(
            scopeKeysCol,
            QueryFilter.eq('scopeKeys', scopeKeys.toJson()),
          ),
    );

    // Exclude soft-deleted items
    if (supportsSoftDelete) {
      query.where((t) => _resolveColumn('deletedAt').isNull());
    }

    // Apply QuerySpec filters
    drift.Expression<bool>? filter;
    for (final f in spec.filters) {
      final newFilter = buildFilter(_resolveColumn(f.field), f);
      if (filter == null) {
        filter = newFilter;
      } else {
        filter = filter & newFilter;
      }
    }
    if (filter != null) {
      query.where((_) => filter!);
    }

    // Apply ordering
    query.orderBy(
      spec.orderBy.map((o) {
        final col = _resolveColumn(o.field);
        final mode = o.descending
            ? drift.OrderingMode.desc
            : drift.OrderingMode.asc;
        return (t) => drift.OrderingTerm(expression: col, mode: mode);
      }).toList(),
    );

    // Apply pagination
    if (spec.limit != null) {
      query.limit(spec.limit!, offset: spec.offset);
    }

    final results = await query.get();
    return results.map((row) => row as T).toList(growable: false);
  }

  @override
  Future<DateTime?> getSyncPoint(SyncScopeKeys scopeKeys) async {
    final query = db.select(db.syncPoints)
      ..where(
        (t) =>
            t.scopeName.equals(scopeName) &
            t.scopeKeys.equals(scopeKeys.toJson()),
      );
    final result = await query.getSingleOrNull();
    return result?.lastSyncedAt;
  }

  @override
  Future<void> saveSyncPoint(
    SyncScopeKeys scopeKeys,
    DateTime timestamp,
  ) async {
    await db.customInsert(
      'INSERT OR REPLACE INTO ${db.syncPoints.actualTableName} (scope_name, scope_keys, last_synced_at) VALUES (?, ?, ?)',
      variables: [
        drift.Variable(scopeName),
        drift.Variable(scopeKeys.toJson()),
        drift.Variable(timestamp),
      ],
    );
  }

  @override
  Future<List<PendingOp<T, Id>>> getPendingOps(SyncScopeKeys scopeKeys) async {
    final query = db.select(db.pendingOps)
      ..where(
        (t) =>
            t.scopeName.equals(scopeName) &
            t.scopeKeys.equals(scopeKeys.toJson()),
      );
    final rows = await query.get();

    return rows
        // row is a [PendingOp] type generated by Drift but only accessible by
        // the package user.
        .map((row) {
          return PendingOp(
            id: idFromString(row.entityId),
            opId: row.id,
            scope: SyncScope(scopeName, scopeKeys),
            type: row.opType,
            payload: row.payload != null
                ? fromJson(jsonDecode(row.payload!))
                : null,
            updatedAt: row.updatedAt,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> enqueuePendingOp(PendingOp<T, Id> op) async {
    await db.customInsert(
      'INSERT INTO ${db.pendingOps.actualTableName} (id, scope_name, scope_keys, op_type, entity_id, payload, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      variables: [
        drift.Variable(op.opId),
        drift.Variable(scopeName),
        drift.Variable(jsonEncode(op.scope.keys)),
        drift.Variable(op.type.index),
        drift.Variable(idToString(op.id)),
        drift.Variable(
          op.payload != null ? jsonEncode((op.payload as T).toJson()) : null,
        ),
        drift.Variable(op.updatedAt),
      ],
    );
  }

  @override
  Future<void> clearPendingOps(
    SyncScopeKeys scopeKeys,
    List<String> opIds,
  ) async {
    await (db.delete(db.pendingOps)..where((t) => t.id.isIn(opIds))).go();
  }

  drift.Expression<bool> buildFilter(
    drift.GeneratedColumn column,
    QueryFilter f,
  ) {
    final value = f.value;

    if (f.op == FilterOperator.isNull) return column.isNull();
    if (f.op == FilterOperator.isNotNull) return column.isNotNull();

    if (value == null) {
      throw ArgumentError('Filter value cannot be null for operator ${f.op}');
    }

    // === Type-aware expression building ===

    // String columns
    if (column is drift.Column<String>) {
      final col = column as drift.Column<String>;
      // final val = value.toString();
      String valueToString() => value.toString();
      switch (f.op) {
        case FilterOperator.eq:
          return col.equals(valueToString());
        case FilterOperator.neq:
          return col.equals(valueToString()).not();
        case FilterOperator.like:
          return col.like('%${valueToString()}%');
        case FilterOperator.contains:
          return col.like('%${valueToString()}%');
        case FilterOperator.inList:
          if (value is! Iterable) {
            throw ArgumentError('inList requires an Iterable of String');
          }
          final List<String> list = value
              .map((e) => e is String ? e : e.toString())
              .toList();
          return col.isIn(list);
        default:
          throw ArgumentError('Unsupported operator ${f.op} for String column');
      }
    }

    // Integer columns
    if (column is drift.Column<int>) {
      final col = column as drift.Column<int>;

      int valueToInt() => int.parse(value.toString());

      switch (f.op) {
        case FilterOperator.eq:
          return col.equals(valueToInt());
        case FilterOperator.neq:
          return col.equals(valueToInt()).not();
        case FilterOperator.gt:
          return col.isBiggerThanValue(valueToInt());
        case FilterOperator.gte:
          return col.isBiggerOrEqualValue(valueToInt());
        case FilterOperator.lt:
          return col.isSmallerThanValue(valueToInt());
        case FilterOperator.lte:
          return col.isSmallerOrEqualValue(valueToInt());
        case FilterOperator.inList:
          if (value is! Iterable) {
            throw ArgumentError('inList requires an Iterable of int');
          }
          final List<int> list = value
              .map((e) => e is int ? e : int.parse(e.toString()))
              .toList();
          return col.isIn(list);
        default:
          throw ArgumentError('Unsupported operator ${f.op} for int column');
      }
    }

    // DateTime columns
    if (column is drift.Column<DateTime>) {
      final col = column as drift.DateTimeColumn;
      DateTime valueToDateTime(dynamic value) =>
          value is DateTime ? value : DateTime.parse(value.toString());
      switch (f.op) {
        case FilterOperator.eq:
          return col.equals(valueToDateTime(value));
        case FilterOperator.neq:
          return col.equals(valueToDateTime(value)).not();
        case FilterOperator.gt:
          return col.isBiggerThanValue(valueToDateTime(value));
        case FilterOperator.gte:
          return col.isBiggerOrEqualValue(valueToDateTime(value));
        case FilterOperator.lt:
          return col.isSmallerThanValue(valueToDateTime(value));
        case FilterOperator.lte:
          return col.isSmallerOrEqualValue(valueToDateTime(value));
        case FilterOperator.betweenDateTime:
          if (value is! List<DateTime> || value.length != 2) {
            throw ArgumentError('between requires a list of 2 DateTime values');
          }
          return col.isBetweenValues(value[0], value[1]);
        case FilterOperator.inList:
          final valList = (value as Iterable?)?.map(
            (v) => v is DateTime ? v : DateTime.parse(v.toString()),
          );
          if (valList == null) {
            throw ArgumentError(
              'inList requires an Iterable for DateTime column',
            );
          }
          return col.isIn(valList);
        case FilterOperator.sameDate:
          final val = valueToDateTime(value);

          return col.year.equals(val.year) &
              col.month.equals(val.month) &
              col.day.equals(val.day);
        case FilterOperator.sameMonth:
          final val = valueToDateTime(value);
          return col.year.equals(val.year) & col.month.equals(val.month);
        case FilterOperator.sameYear:
          return col.year.equals(valueToDateTime(value).year);

        case FilterOperator.betweenDate:
          if (value is! List<DateTime> || value.length != 2) {
            throw ArgumentError('between requires a list of 2 DateTime values');
          }
          final val1 = value[0];
          final val2 = value[1];
          final start = DateTime.utc(val1.year, val1.month, val1.day);
          final end = DateTime.utc(
            val2.year,
            val2.month,
            val2.day,
            23,
            59,
            59,
            999,
          );
          return col.isBetweenValues(start, end);
        case FilterOperator.between:
          throw ArgumentError(
            'Use betweenDateTime or betweenDate for DateTime columns',
          );
        default:
          throw ArgumentError(
            'Unsupported operator ${f.op} for DateTime column',
          );
      }
    }

    // Boolean columns
    if (column is drift.Column<bool>) {
      final val = value is bool
          ? value
          : (value.toString().toLowerCase() == 'true');

      switch (f.op) {
        case FilterOperator.eq:
          return column.equals(val);
        case FilterOperator.neq:
          return column.equals(val).not();
        default:
          throw ArgumentError(
            'Unsupported operator ${f.op} for bool column. Only eq and neq are supported.',
          );
      }
    }

    throw UnsupportedError(
      'Column type ${column.runtimeType} is not yet supported by buildFilter.',
    );
  }
}
