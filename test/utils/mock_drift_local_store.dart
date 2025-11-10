import 'package:drift/drift.dart' show Value;
import 'package:just_sync/just_sync.dart';

import 'test_database.dart';

class MockDriftLocalStore
    extends DriftLocalStore<TestDatabase, TestModel, String> {
  MockDriftLocalStore(super.db)
    : super(
        fromJson: TestModel.fromJson,
        idToString: (id) => id,
        idFromString: (id) => id,
        table: db.mockTable,
        toInsertCompanion: (TestModel model, SyncScope scope) {
          return MockTableCompanion.insert(
            id: model.id,
            title: model.title,
            scopeName: scope.name,
            scopeKeys: scope.keysToJson(),
            status: Value(model.status),
            count: Value(model.count),
            tags: Value(model.tags),
            updatedAt: model.updatedAt,
          );
        },
        toUpdateCompanion: (TestModel model) {
          return MockTableCompanion(
            id: Value(model.id),
            title: Value(model.title),
            status: Value(model.status),
            count: Value(model.count),
            tags: Value(model.tags),
            updatedAt: Value(model.updatedAt),
          );
        },
        toSoftDeleteCompanion: () =>
            MockTableCompanion(deletedAt: Value(DateTime.now())),
      );
}
