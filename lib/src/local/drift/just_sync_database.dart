import 'package:drift/drift.dart';

import 'package:just_sync/src/store_interfaces.dart';
import 'utc_datetime_converter.dart';

/// An interface implemented by user-defined Drift databases.
///
/// By implementing this interface, you signal that your database includes the
/// [SyncPoints] and [PendingOps] tables, and the Drift generator will
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
/// @DriftDatabase(tables: [MyDataTable, SyncPoints, PendingOps])
/// class MyDatabase extends _$MyDatabase implements IJustSyncDatabase {
///   // ... your database constructor ...
/// }
/// ```
abstract class IJustSyncDatabase extends GeneratedDatabase {
  IJustSyncDatabase(super.executor);

  SyncPoints get syncPoints;
  PendingOps get pendingOps;
}

@DataClassName('SyncPoint')
class SyncPoints extends Table {
  TextColumn get scopeName => text()();
  TextColumn get scopeKeys => text()();
  DateTimeColumn get lastSyncedAt => dateTime().map(UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {scopeName, scopeKeys};
}

@DataClassName('PendingOp')
class PendingOps extends Table {
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
