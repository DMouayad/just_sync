import 'package:drift/drift.dart';

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
