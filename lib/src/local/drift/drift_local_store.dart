import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import 'package:just_sync/src/core/store_interfaces.dart';
import 'package:just_sync/src/local/drift/database_interface.dart';
import 'package:just_sync/src/models/query_spec.dart';
import 'package:just_sync/src/models/sync_scope.dart';
import 'package:just_sync/src/models/traits.dart';

abstract class DriftModel<Id> extends drift.DataClass
    implements HasId<Id>, HasUpdatedAt {}

abstract class DriftLocalStore<
  DB extends IDriftDatabase,
  T extends DriftModel<Id>,
  Id
>
    implements LocalStore<T, Id> {
  const DriftLocalStore(this.db);

  final DB db;

  @override
  bool get supportsSoftDelete => T is SupportsSoftDelete;

  // == Abstract conversion functions to be implemented by the concrete adapter ==
  T fromJson(Map<String, dynamic> json);
  Id idFromString(String id);
  String idToString(Id id);
  // == Abstract properties and methods to be implemented by concrete class ==
  drift.TableInfo get table;
  drift.GeneratedColumn resolveColumn(String fieldName);
  drift.Insertable<T> toInsertCompanion(T model, SyncScope scope);
  drift.Insertable<T> toUpdateCompanion(T model);
  drift.Insertable<T> toSoftDeleteCompanion();

  @override
  Future<T?> getById(Id id) async {
    final query = db.select(table)
      ..where((t) => resolveColumn('id').equals(idToString(id)));
    return await query.getSingleOrNull();
  }

  @override
  Future<void> upsertMany(SyncScope scope, List<T> items) async {
    final companions = items
        .map((item) => toInsertCompanion(item, scope))
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
  Future<void> deleteMany(SyncScope scope, List<Id> ids) async {
    if (ids.isEmpty) return;

    final idColumn = resolveColumn('id');
    // This assumes the ID column type is compatible with what `idToString` produces.
    final stringIds = ids.map(idToString).toList();

    // Build the `where` clause for the IDs within the given scope.
    buildWhereClause() {
      final scopeNameCol = resolveColumn('scopeName');
      final scopeKeysCol = resolveColumn('scopeKeys');

      final scopeFilter =
          buildFilter(
            scopeNameCol,
            FilterOp(
              field: 'scopeName',
              op: FilterOperator.eq,
              value: scope.name,
            ),
          ) &
          buildFilter(
            scopeKeysCol,
            FilterOp(
              field: 'scopeKeys',
              op: FilterOperator.eq,
              value: jsonEncode(scope.keys),
            ),
          );

      // This assumes the ID column can be filtered as a string.
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
    SyncScope scope,
    QuerySpec spec,
    List<T> newValues,
  ) async {
    if (newValues.isEmpty) return 0;

    final query = db.update(table);

    // Apply scope
    final scopeNameCol = resolveColumn('scopeName');
    final scopeKeysCol = resolveColumn('scopeKeys');
    query.where(
      (_) =>
          buildFilter(
            scopeNameCol,
            FilterOp(
              field: 'scopeName',
              op: FilterOperator.eq,
              value: scope.name,
            ),
          ) &
          buildFilter(
            scopeKeysCol,
            FilterOp(
              field: 'scopeKeys',
              op: FilterOperator.eq,
              value: jsonEncode(scope.keys),
            ),
          ),
    );

    // Apply QuerySpec filters
    drift.Expression<bool>? filter;
    for (final f in spec.filters) {
      final newFilter = buildFilter(resolveColumn(f.field), f);
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
  Future<int> deleteWhere(SyncScope scope, QuerySpec spec) async {
    buildWhereClause() {
      // Apply scope
      final scopeNameCol = resolveColumn('scopeName');
      final scopeKeysCol = resolveColumn('scopeKeys');
      drift.Expression<bool> combinedFilter =
          buildFilter(
            scopeNameCol,
            FilterOp(
              field: 'scopeName',
              op: FilterOperator.eq,
              value: scope.name,
            ),
          ) &
          buildFilter(
            scopeKeysCol,
            FilterOp(
              field: 'scopeKeys',
              op: FilterOperator.eq,
              value: jsonEncode(scope.keys),
            ),
          );

      // Apply QuerySpec filters
      drift.Expression<bool>? specFilter;
      for (final f in spec.filters) {
        final newFilter = buildFilter(resolveColumn(f.field), f);
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

  // == Concrete implementations of query methods ==

  @override
  Future<List<T>> query(SyncScope scope) {
    return queryWith(scope, const QuerySpec());
  }

  @override
  Future<List<T>> querySince(SyncScope scope, DateTime since) {
    return queryWith(
      scope,
      QuerySpec(
        filters: [
          FilterOp(field: 'updatedAt', op: FilterOperator.gt, value: since),
        ],
      ),
    );
  }

  @override
  Future<List<T>> queryWith(SyncScope scope, QuerySpec spec) async {
    final query = db.select(table);

    // Apply scope
    // This assumes the table has scopeName and scopeKeys columns, which is
    // enforced by the JustSyncModel and JustSyncTable mixin conventions.
    final scopeNameCol = resolveColumn('scopeName');
    final scopeKeysCol = resolveColumn('scopeKeys');
    query.where(
      (_) =>
          buildFilter(
            scopeNameCol,
            FilterOp(
              field: 'scopeName',
              op: FilterOperator.eq,
              value: scope.name,
            ),
          ) &
          buildFilter(
            scopeKeysCol,
            FilterOp(
              field: 'scopeKeys',
              op: FilterOperator.eq,
              value: jsonEncode(scope.keys),
            ),
          ),
    );

    // Apply QuerySpec filters
    drift.Expression<bool>? filter;
    for (final f in spec.filters) {
      final newFilter = buildFilter(resolveColumn(f.field), f);
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
        final col = resolveColumn(o.field);
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

  // == Concrete implementations of generic LocalStore methods ==

  drift.TableInfo<drift.Table, dynamic> get _syncPoints =>
      db.allTables.firstWhere((t) => t.actualTableName == 'sync_points');

  drift.TableInfo<drift.Table, dynamic> get _pendingOps =>
      db.allTables.firstWhere((t) => t.actualTableName == 'pending_ops');

  @override
  Future<DateTime?> getSyncPoint(SyncScope scope) async {
    final query = db.select(_syncPoints)
      ..where(
        (t) =>
            db.syncPoints.scopeName.equals(scope.name) &
            db.syncPoints.scopeKeys.equals(jsonEncode(scope.keys)),
      );
    final result = await query.getSingleOrNull();

    return result?.lastSyncedAt;
  }

  @override
  Future<void> saveSyncPoint(SyncScope scope, DateTime timestamp) async {
    await db.customInsert(
      'INSERT OR REPLACE INTO ${_syncPoints.actualTableName} (scope_name, scope_keys, last_synced_at) VALUES (?, ?, ?)',
      variables: [
        drift.Variable(scope.name),
        drift.Variable(jsonEncode(scope.keys)),
        drift.Variable(timestamp),
      ],
    );
  }

  @override
  Future<List<PendingOp<T, Id>>> getPendingOps(SyncScope scope) async {
    final query = db.select(_pendingOps)
      ..where(
        (t) =>
            db.pendingOps.scopeName.equals(scope.name) &
            db.pendingOps.scopeKeys.equals(jsonEncode(scope.keys)),
      );
    final rows = await query.get();

    return rows
        // row is a [PendingOp] type generated by Drift but only accessible by
        // the package user.
        .map((row) {
          return PendingOp(
            id: idFromString(row.entityId),
            opId: row.id,
            scope: scope,
            type: row.opType,
            payload: row.payload is String
                ? fromJson(jsonDecode(row.payload))
                : null,
            updatedAt: row.updatedAt,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> enqueuePendingOp(PendingOp<T, Id> op) async {
    await db.customInsert(
      'INSERT INTO ${_pendingOps.actualTableName} (${_pendingOps.columnsByName.keys.join(', ')}) VALUES (?, ?, ?, ?, ?, ?, ?)',
      // order must be the same as column order in the table [PendingOp]
      variables: [
        drift.Variable(op.opId),
        drift.Variable(op.scope.name),
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
  Future<void> clearPendingOps(SyncScope scope, List<String> opIds) async {
    await (db.delete(
      _pendingOps,
    )..where((t) => db.pendingOps.id.isIn(opIds))).go();
  }

  drift.Expression<bool> buildFilter(drift.GeneratedColumn column, FilterOp f) {
    final value = f.value;

    // Handle null checks first, as they don't need a value.
    if (f.op == FilterOperator.isNull) return column.isNull();
    if (f.op == FilterOperator.isNotNull) return column.isNotNull();

    // For all other operators, a value is required.
    if (value == null) {
      throw ArgumentError('Filter value cannot be null for operator ${f.op}');
    }

    // === Type-aware expression building ===

    // String columns
    if (column is drift.Column<String>) {
      final col = column as drift.Column<String>;
      final val = value.toString();

      switch (f.op) {
        case FilterOperator.eq:
          return col.equals(val);
        case FilterOperator.neq:
          return col.equals(val).not();
        case FilterOperator.like:
          return col.like('%$val%');
        case FilterOperator.contains:
          return col.like('%$val%');
        case FilterOperator.inList:
          final valList = (value as Iterable?)?.map((v) => v.toString());
          if (valList == null) {
            throw ArgumentError(
              'inList requires an Iterable for String column',
            );
          }
          return col.isIn(valList);
        default:
          throw ArgumentError('Unsupported operator ${f.op} for String column');
      }
    }

    // Integer columns
    if (column is drift.Column<int>) {
      final col = column as drift.Column<int>;
      final val = value is int ? value : int.parse(value.toString());

      switch (f.op) {
        case FilterOperator.eq:
          return col.equals(val);
        case FilterOperator.neq:
          return col.equals(val).not();
        case FilterOperator.gt:
          return col.isBiggerThanValue(val);
        case FilterOperator.gte:
          return col.isBiggerOrEqualValue(val);
        case FilterOperator.lt:
          return col.isSmallerThanValue(val);
        case FilterOperator.lte:
          return col.isSmallerOrEqualValue(val);
        case FilterOperator.inList:
          final valList = (value as Iterable?)?.map(
            (v) => v is int ? v : int.parse(v.toString()),
          );
          if (valList == null) {
            throw ArgumentError('inList requires an Iterable for int column');
          }
          return col.isIn(valList);
        default:
          throw ArgumentError('Unsupported operator ${f.op} for int column');
      }
    }

    // DateTime columns
    if (column is drift.Column<DateTime>) {
      final col = column as drift.DateTimeColumn;
      final val = value is DateTime ? value : DateTime.parse(value.toString());

      switch (f.op) {
        case FilterOperator.eq:
          return col.equals(val);
        case FilterOperator.neq:
          return col.equals(val).not();
        case FilterOperator.gt:
          return col.isBiggerThanValue(val);
        case FilterOperator.gte:
          return col.isBiggerOrEqualValue(val);
        case FilterOperator.lt:
          return col.isSmallerThanValue(val);
        case FilterOperator.lte:
          return col.isSmallerOrEqualValue(val);
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
