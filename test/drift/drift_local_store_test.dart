import 'package:flutter_test/flutter_test.dart';

import 'package:just_sync/just_sync.dart';

import '../utils/mock_drift_local_store.dart';
import '../utils/test_database.dart' hide PendingOp, SyncPoint;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockDriftLocalStore persistence', () {
    late TestDatabase db;
    late MockDriftLocalStore store;
    late final scope = SyncScope(db.mockTable.defaultScopeName, {
      'userId': 'u1',
    });

    setUp(() {
      db = TestDatabase();
      store = MockDriftLocalStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('upsert and getById should work correctly', () async {
      // Arrange
      const SyncScopeKeys scopeKeys = {};
      final now = DateTime.now();
      final model = TestModelFactory.create(
        id: '1',
        title: 'test value',
        updatedAt: now,
      );

      // Act
      await store.upsertMany(scopeKeys, [model]);
      final result = await store.getById('1');

      // Assert
      expect(result, isA<TestModel>());
      expect(result!.id, '1');
      expect(result.title, 'test value');
    });

    test('pending ops can be enqueued and retrieved', () async {
      // Arrange
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
      final pendingOps = await store.getPendingOps(scope.keys);

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
      const SyncScopeKeys scopeKeys = {};
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
      await store.upsertMany(scopeKeys, [model1, model2]);

      // Act
      await store.deleteMany(scopeKeys, ['1']);
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
      await store.upsertMany(scope.keys, [r1, r2]);

      final list = await store.query(scope.keys);
      expect(list.map((e) => e.id), containsAll(['a', 'b']));

      await store.deleteMany(scope.keys, ['a']);
      final after = await store.query(scope.keys);
      expect(after.map((e) => e.id), isNot(contains('a')));
      expect(after.map((e) => e.id), contains('b'));

      // querySince excludes deleted items
      final since = DateTime.utc(
        2025,
        1,
        1,
      ).subtract(const Duration(minutes: 1));
      final sinceList = await store.querySince(scope.keys, since);
      expect(sinceList.map((e) => e.id), isNot(contains('a')));
    });

    test('sync point is persisted', () async {
      final ts = DateTime.utc(2025, 2, 3, 4, 5, 6);
      await store.saveSyncPoint(scope.keys, ts);
      final got = await store.getSyncPoint(scope.keys);
      expect(got?.toIso8601String(), ts.toIso8601String());

      // New store instance (same DB) should read the same value
      final store2 = MockDriftLocalStore(db);
      final got2 = await store2.getSyncPoint(scope.keys);
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
      final list = await store.getPendingOps(scope.keys);
      expect(list.map((e) => e.opId), contains('op1'));

      await store.clearPendingOps(scope.keys, const ['op1']);
      final after = await store.getPendingOps(scope.keys);
      expect(after, isEmpty);
    });

    test('querySince returns records with UTC timestamps', () async {
      // Arrange
      final record = TestModelFactory.create(id: 'utc-test');
      await store.upsertMany(scope.keys, [record]);
      final sinceTime = record.updatedAt.subtract(const Duration(seconds: 1));

      // Act
      final results = await store.querySince(scope.keys, sinceTime);

      // Assert
      expect(results, isNotEmpty);
      expect(results.first.updatedAt.isUtc, isTrue);
    });

    test('updateWhere/deleteWhere work with spec', () async {
      final now = DateTime.now().toUtc();
      await store.upsertMany(scope.keys, [
        TestModelFactory.create(id: 'x', title: 'X', updatedAt: now),
        TestModelFactory.create(id: 'y', title: 'Y', updatedAt: now),
      ]);

      // updateWhere: only ids that match spec should be updated
      final spec = QuerySpec(
        filters: [
          QueryFilter.inList('id', ['x']),
        ],
      );
      final changed = await store.updateWhere(scope.keys, spec, [
        TestModelFactory.create(
          id: 'x',
          title: 'X2',
          updatedAt: now.add(const Duration(seconds: 1)),
        ),
        TestModelFactory.create(
          id: 'z',
          title: 'Z',
          updatedAt: now,
        ), // should be ignored
      ]);
      expect(changed, 1);
      final after = await store.queryWith(
        scope.keys,
        QuerySpec(filters: [QueryFilter.eq('id', 'x')]),
      );
      expect(after.single.title, 'X2');

      // deleteWhere by id
      final deleted = await store.deleteWhere(
        scope.keys,
        QuerySpec(filters: [QueryFilter.eq('id', 'y')]),
      );
      expect(deleted, 1);
      final remain = await store.query(scope.keys);
      expect(remain.map((e) => e.id), contains('x'));
      expect(remain.map((e) => e.id), isNot(contains('y')));
    });
  });
}
