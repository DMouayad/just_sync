import 'package:drift/drift.dart' show Value;
import 'package:just_sync/just_sync.dart';

import 'test_database.dart';

class MockDriftLocalStore
    extends DriftLocalStore<TestDatabase, TestModel, String> {
  MockDriftLocalStore(super.db)
    : super(
        scopeName: db.mockTable.defaultScopeName,
        fromJson: TestModel.fromJson,
        idToString: (id) => id,
        idFromString: (id) => id,
        table: db.mockTable,
        toInsertCompanion: (TestModel model, SyncScopeKeys scopeKeys) {
          return MockTableCompanion.insert(
            id: model.id,
            title: model.title,
            scopeKeys: Value(scopeKeys.toJson()),
            status: Value(model.status),
            count: Value(model.count),
            tags: Value(model.tags),
            updatedAt: model.updatedAt,
            completed: Value(model.completed),
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
            completed: Value(model.completed),
          );
        },
        toSoftDeleteCompanion: () =>
            MockTableCompanion(deletedAt: Value(DateTime.now().toUtc())),
      );
}
