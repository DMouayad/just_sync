import 'package:drift/drift.dart';

import 'package:just_sync/src/models/query_spec.dart';
import 'utc_datetime_converter.dart';

mixin DriftSyncTableMixin on Table {
  TextColumn get scopeName => text()();
  TextColumn get scopeKeys => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(Variable(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().map(UtcDateTimeConverter())();
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
