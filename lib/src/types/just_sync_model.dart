import 'package:drift/drift.dart' show DataClass;
import 'package:just_sync/src/types/traits.dart';

abstract class JustSyncModel extends DataClass implements HasId, HasUpdatedAt {
  String get scopeName;
  String get scopeKeys;
}
