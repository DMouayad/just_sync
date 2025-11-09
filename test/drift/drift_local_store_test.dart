import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart' show NativeDatabase;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:just_sync/just_sync.dart';

import '../utils/mock_drift_local_store.dart';
import '../utils/test_database.dart' hide PendingOp, SyncPoint;

void main() {
  // Required for drift_flutter/path_provider in tests.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    // Suppress multiple database warning in tests where the same executor can be reused.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });
  group('MockDriftLocalStore persistence', () {
    late TestDatabase db;
    late MockDriftLocalStore store;
    const scope = SyncScope('records', {'userId': 'u1'});

    setUp(() {
      db = TestDatabase(NativeDatabase.memory());
      store = MockDriftLocalStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('upsert and getById should work correctly', () async {
      // Arrange
      final scope = SyncScope.collection('test');
      final now = DateTime.now();
      final model = TestModelFactory.create(
        id: '1',
        title: 'test value',
        updatedAt: now,
      );

      // Act
      await store.upsertMany(scope, [model]);
      final result = await store.getById('1');

      // Assert
      expect(result, isA<TestModel>());
      expect(result!.id, '1');
      expect(result.title, 'test value');
    });

    test('pending ops can be enqueued and retrieved', () async {
      // Arrange
      final scope = SyncScope.collection('test');
      final now = DateTime.now();
      final model = TestModelFactory.create(
        id: '1',
        title: 'test value',
        updatedAt: now,
      );
      final op = PendingOp<TestModel, String>(
        opId: 'op1',
        type: PendingOpType.create,
        id: '1', // entity id
        payload: model,
        scope: scope,
        updatedAt: now,
      );

      // Act
      await store.enqueuePendingOp(op);
      final pendingOps = await store.getPendingOps(scope);

      // Assert
      expect(pendingOps, hasLength(1));
      final retrievedOp = pendingOps.first;
      expect(retrievedOp.opId, 'op1');
      expect(retrievedOp.type, PendingOpType.create);
      expect(retrievedOp.id, '1');
      expect(retrievedOp.payload?.id, model.id);
      expect(retrievedOp.payload?.title, model.title);
    });

    test('deleteMany should remove items', () async {
      // Arrange
      final scope = SyncScope.collection('test');
      final now = DateTime.now();
      final model1 = TestModelFactory.create(
        id: '1',
        title: 'value1',
        updatedAt: now,
      );
      final model2 = TestModelFactory.create(
        id: '2',
        title: 'value2',
        updatedAt: now,
      );
      await store.upsertMany(scope, [model1, model2]);

      // Act
      await store.deleteMany(scope, ['1']);
      final result1 = await store.getById('1');
      final result2 = await store.getById('2');

      // Assert
      expect(result1, isNull);
      expect(result2, isNotNull);
      expect(result2!.id, '2');
    });
    test('upsert/query and soft delete behavior', () async {
      final r1 = TestModelFactory.create(
        id: 'a',
        title: 'A',
        updatedAt: DateTime.utc(2025, 1, 1),
      );
      final r2 = TestModelFactory.create(
        id: 'b',
        title: 'B',
        updatedAt: DateTime.utc(2025, 1, 2),
      );
      await store.upsertMany(scope, [r1, r2]);

      final list = await store.query(scope);
      expect(list.map((e) => e.id), containsAll(['a', 'b']));

      await store.deleteMany(scope, ['a']);
      final after = await store.query(scope);
      expect(after.map((e) => e.id), isNot(contains('a')));
      expect(after.map((e) => e.id), contains('b'));

      // querySince excludes deleted items
      final since = DateTime.utc(
        2025,
        1,
        1,
      ).subtract(const Duration(minutes: 1));
      final sinceList = await store.querySince(scope, since);
      expect(sinceList.map((e) => e.id), isNot(contains('a')));
    });

    test('sync point is persisted', () async {
      final ts = DateTime.utc(2025, 2, 3, 4, 5, 6);
      await store.saveSyncPoint(scope, ts);
      final got = await store.getSyncPoint(scope);
      expect(got?.toIso8601String(), ts.toIso8601String());

      // New store instance (same DB) should read the same value
      final store2 = MockDriftLocalStore(db);
      final got2 = await store2.getSyncPoint(scope);
      expect(got2?.toIso8601String(), ts.toIso8601String());
    });

    test('pending ops enqueue and clear', () async {
      final op = PendingOp<TestModel, String>(
        opId: 'op1',
        scope: scope,
        type: PendingOpType.create,
        id: 'x',
        payload: TestModelFactory.create(
          id: 'x',
          title: 'X',
          updatedAt: DateTime.now().toUtc(),
        ),
        updatedAt: DateTime.now().toUtc(),
      );
      await store.enqueuePendingOp(op);
      final list = await store.getPendingOps(scope);
      expect(list.map((e) => e.opId), contains('op1'));

      await store.clearPendingOps(scope, const ['op1']);
      final after = await store.getPendingOps(scope);
      expect(after, isEmpty);
    });

    test('querySince returns records with UTC timestamps', () async {
      // Arrange
      final record = TestModelFactory.create(id: 'utc-test');
      await store.upsertMany(scope, [record]);
      final sinceTime = record.updatedAt.subtract(const Duration(seconds: 1));

      // Act
      final results = await store.querySince(scope, sinceTime);

      // Assert
      expect(results, isNotEmpty);
      expect(results.first.updatedAt.isUtc, isTrue);
    });
  });
}
