import 'package:drift/drift.dart';
import 'package:just_sync/src/models/query_spec.dart';

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
/// @DataClassName('MyData', implementing: [DriftModel<String>])
/// class MyDataTable extends Table with DriftSyncTableMixin {
///   // ... your table definition ...
/// }
///
/// @DriftDatabase(tables: [MyDataTable, SyncPoints, PendingOps])
/// class MyDatabase extends _$MyDatabase implements IDriftDatabase {
///   // ... your database constructor ...
/// }
/// ```
abstract class IDriftDatabase extends GeneratedDatabase {
  IDriftDatabase(super.executor);

  TableInfo<SyncPoints, dynamic> get syncPoints;
  TableInfo<PendingOps, dynamic> get pendingOps;
}

/// Concrete table for storing synchronization points.
/// Add this table to your `@DriftDatabase`.
class SyncPoints extends Table {
  TextColumn get scopeName => text()();
  TextColumn get scopeKeys => text()();
  DateTimeColumn get lastSyncedAt => dateTime().map(UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {scopeName, scopeKeys};
}

/// Concrete table for storing pending offline operations.
/// Add this table to your `@DriftDatabase`.
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
