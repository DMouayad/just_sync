import 'package:drift/drift.dart';

/// A custom drift converter to ensure that [DateTime] values are stored and
/// retrieved from the database as UTC.
class UtcDateTimeConverter extends TypeConverter<DateTime, DateTime> {
  const UtcDateTimeConverter();
  @override
  DateTime fromSql(DateTime fromDb) => fromDb.toUtc();

  @override
  DateTime toSql(DateTime value) => value.toUtc();
}
