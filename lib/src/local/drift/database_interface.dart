import 'package:drift/drift.dart';

import 'tables_mixin.dart';

/// An interface implemented by user-defined Drift databases.
///
/// By implementing this interface, you signal that your database includes the
/// [SyncPointsTableMixin] and [PendingOpsTableMixin] tables, and the Drift generator will
/// automatically create the necessary getters, fulfilling the interface contract.
///
/// ### Example
///
/// ```dart
/// import 'package:just_sync/just_sync.dart';
///
/// @DataClassName('MyData')
/// class MyDataTable extends Table with DriftSyncTableMixin {
///   // ... your table definition ...
/// }
///
/// class SyncPoints extends Table with SyncPointsTableMixin {}
/// class PendingOps extends Table with PendingOpsTableMixin {}
///
/// @DriftDatabase(tables: [MyDataTable, SyncPoints, PendingOps])
/// class MyDatabase extends _$MyDatabase implements IDriftDatabase {
///   // ... your database constructor ...
/// }
/// ```
abstract class IDriftDatabase extends GeneratedDatabase {
  IDriftDatabase(super.executor);

  SyncPointsTableMixin get syncPoints;
  PendingOpsTableMixin get pendingOps;
}
