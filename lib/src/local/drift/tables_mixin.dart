import 'package:drift/drift.dart';

import 'package:just_sync/src/models/pending_op.dart';
import 'utc_datetime_converter.dart';

mixin DriftSyncTableMixin on Table {
  TextColumn get scopeName => text().withDefault(Constant(defaultScopeName))();
  TextColumn get scopeKeys => text().withDefault(Constant(''))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(Variable(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().map(UtcDateTimeConverter())();

  String get defaultScopeName;
}

mixin DriftSoftDeleteTableMixin on Table {
  DateTimeColumn get deletedAt =>
      dateTime().nullable().map(UtcDateTimeConverter())();
}

mixin SyncPointsTableMixin on Table {
  TextColumn get scopeName => text()();
  TextColumn get scopeKeys => text()();
  DateTimeColumn get lastSyncedAt => dateTime().map(UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {scopeName, scopeKeys};
}

mixin PendingOpsTableMixin on Table {
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
