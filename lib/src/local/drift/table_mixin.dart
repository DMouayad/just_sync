import 'package:drift/drift.dart';

import 'utc_datetime_converter.dart';

mixin DriftSyncTableMixin on Table {
  TextColumn get scopeName => text()();
  TextColumn get scopeKeys => text()();
  // TextColumn get syncStatus =>
  // text().withDefault(const Constant('SYNCED'))(); // SYNCED, PENDING, ERROR
  // DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().map(UtcDateTimeConverter())();
}

mixin DriftSoftDeleteTableMixin on Table {
  DateTimeColumn get deletedAt =>
      dateTime().nullable().map(UtcDateTimeConverter())();
}
