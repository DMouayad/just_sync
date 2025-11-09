import 'package:drift/drift.dart';

import 'package:just_sync/src/models/query_spec.dart';

import 'utc_datetime_converter.dart';

/// An interface implemented by user-defined Drift databases.
///
/// By implementing this interface, you signal that your database includes the
/// [SyncPointsTable] and [PendingOpsTable] tables, and the Drift generator will
/// automatically create the necessary getters, fulfilling the interface contract.
///
/// ### Example
///
/// ```dart
/// import 'package:just_sync/just_sync.dart';
///
/// @DataClassName('MyData')
/// class MyDataTable extends Table with JustSyncTableMixin {
///   // ... your table definition ...
/// }
///
/// @DriftDatabase(tables: [MyDataTable, SyncPointsTable, PendingOpsTable])
/// class MyDatabase extends _$MyDatabase implements IDriftDatabase {
///   // ... your database constructor ...
/// }
/// ```
abstract class IDriftDatabase extends GeneratedDatabase {
  IDriftDatabase(super.executor);

  SyncPointsTable get syncPointsTable;
  PendingOpsTable get pendingOpsTable;
}

@DataClassName('SyncPoint')
class SyncPointsTable extends Table {
  TextColumn get scopeName => text()();
  TextColumn get scopeKeys => text()();
  DateTimeColumn get lastSyncedAt => dateTime().map(UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {scopeName, scopeKeys};
}

@DataClassName('PendingOp')
class PendingOpsTable extends Table {
  TextColumn get id => text()();
  TextColumn get scopeName => text()();
  TextColumn get scopeKeys => text()();
  IntColumn get opType => intEnum<PendingOpType>()();
  TextColumn get entityId => text()();
  TextColumn get payload => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().map(UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
