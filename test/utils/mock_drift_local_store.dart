import 'dart:convert';

import 'package:drift/drift.dart' show Value, GeneratedColumn, TableInfo;
import 'package:just_sync/just_sync.dart';

import 'test_database.dart';

class MockDriftLocalStore extends DriftLocalStore<TestModel, String> {
  MockDriftLocalStore(TestDatabase super.db);

  @override
  TestDatabase get db => super.db as TestDatabase;

  @override
  TableInfo get table => db.mockTable;

  @override
  String idFromString(String id) => id;

  @override
  String idToString(String id) => id;

  @override
  MockTableCompanion toInsertCompanion(TestModel model, SyncScope scope) {
    return MockTableCompanion.insert(
      id: model.id,
      title: model.title,
      scopeName: scope.name,
      scopeKeys: jsonEncode(scope.keys),
      status: Value(model.status),
      count: Value(model.count),
      tags: Value(model.tags),
      updatedAt: model.updatedAt,
    );
  }

  @override
  MockTableCompanion toUpdateCompanion(TestModel model) {
    return MockTableCompanion(
      title: Value(model.title),
      status: Value(model.status),
      count: Value(model.count),
      tags: Value(model.tags),
      updatedAt: Value(model.updatedAt),
    );
  }

  @override
  MockTableCompanion toSoftDeleteCompanion() {
    return MockTableCompanion(deletedAt: Value(DateTime.now()));
  }

  @override
  TestModel fromJson(Map<String, dynamic> json) {
    return TestModel.fromJson(json);
  }

  @override
  GeneratedColumn resolveColumn(String s) {
    return switch (s) {
      'id' => db.mockTable.id,
      'title' => db.mockTable.title,
      'status' => db.mockTable.status,
      'count' => db.mockTable.count,
      'tags' => db.mockTable.tags,
      'updatedAt' => db.mockTable.updatedAt,
      'scopeName' => db.mockTable.scopeName,
      'scopeKeys' => db.mockTable.scopeKeys,
      _ => throw ArgumentError('Unknown column $s'),
    };
  }
}
