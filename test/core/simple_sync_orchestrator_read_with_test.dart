import 'package:flutter_test/flutter_test.dart';

import 'package:just_sync/just_sync.dart';

import '../utils/mock_drift_local_store.dart';
import '../utils/test_database.dart';

void main() {
  group('SimpleSyncOrchestrator.readWith', () {
    late TestDatabase db;
    late MockDriftLocalStore local;
    late InMemoryRemoteStore<TestModel, String> remote;
    late SimpleSyncOrchestrator<TestModel, String> orch;
    const scope = SyncScope('records', {'userId': 'u1'});
    tearDown(() async => await db.close());

    setUp(() async {
      db = TestDatabase();
      local = MockDriftLocalStore(db);
      remote = InMemoryRemoteStore<TestModel, String>(idOf: (r) => r.id);
      // Seed remote scope maps so batchUpsert/fetchSince affect this scope
      await remote.fetchSince(scope, null);
      orch = SimpleSyncOrchestrator<TestModel, String>(
        local: local,
        remote: remote,
        resolver: const LastWriteWinsResolver<TestModel>(),
        idOf: (r) => r.id,
      );
    });

    test('offlineOnly evaluates only local cache', () async {
      // Local has items, remote has different items which should be ignored.
      final t2025 = DateTime.utc(2025, 1, 1);
      await local.upsertMany(scope, [
        TestModelFactory.create(id: 'L1', title: 'local-1', updatedAt: t2025),
        TestModelFactory.create(
          id: 'L2',
          title: 'locale-2',
          updatedAt: t2025.add(const Duration(minutes: 1)),
        ),
      ]);
      await remote.batchUpsert([
        TestModelFactory.create(
          id: 'R1',
          title: 'remote-1',
          updatedAt: t2025.add(const Duration(minutes: 2)),
        ),
      ]);

      final spec = QuerySpec(
        filters: [QueryFilter.gte('updatedAt', t2025)],
        orderBy: [OrderSpec('updatedAt', descending: false)],
      );

      final items = await orch.readWith(
        scope,
        spec,
        policy: CachePolicy.offlineOnly,
      );
      expect(items.map((e) => e.id), containsAll(['L1', 'L2']));
      expect(items.any((e) => e.id == 'R1'), isFalse);
    });

    test(
      'localFirst returns local immediately and triggers background sync',
      () async {
        final base = DateTime.utc(2025, 2, 1);
        // Local has one item, remote has another item which should appear after sync.
        await local.upsertMany(scope, [
          TestModelFactory.create(id: 'L1', title: 'local', updatedAt: base),
        ]);
        await remote.batchUpsert([
          TestModelFactory.create(
            id: 'R1',
            title: 'remote',
            updatedAt: base.add(const Duration(minutes: 1)),
          ),
        ]);

        final spec = QuerySpec(filters: [QueryFilter.gte('updatedAt', base)]);

        final first = await orch.readWith(
          scope,
          spec,
          policy: CachePolicy.localFirst,
        );
        expect(first.map((e) => e.id), contains('L1')); // immediate local

        // Allow background sync to complete
        await orch.synchronize(scope);
        final after = await local.queryWith(scope, spec);
        expect(after.map((e) => e.id), containsAll(['L1', 'R1']));
      },
    );

    test('remoteFirst syncs then evaluates locally', () async {
      final base = DateTime.utc(2025, 3, 1);
      await remote.batchUpsert([
        TestModelFactory.create(id: 'R1', title: 'remote-1', updatedAt: base),
        TestModelFactory.create(
          id: 'R2',
          title: 'remote-2',
          updatedAt: base.add(const Duration(minutes: 1)),
        ),
      ]);

      final spec = QuerySpec(
        filters: [QueryFilter.gte('updatedAt', base)],
        orderBy: [OrderSpec('updatedAt', descending: true)],
        limit: 1,
      );

      final items = await orch.readWith(
        scope,
        spec,
        policy: CachePolicy.remoteFirst,
      );
      expect(items.length, 1);
      expect(items.first.id, 'R2');
    });

    test(
      'preferRemoteEval upserts remote-evaluated results before local evaluation',
      () async {
        final base = DateTime.utc(2025, 4, 1);
        await remote.batchUpsert([
          TestModelFactory.create(id: 'R1', title: 'title-A', updatedAt: base),
          TestModelFactory.create(
            id: 'R2',
            title: 'title-B',
            updatedAt: base.add(const Duration(minutes: 1)),
          ),
        ]);

        final spec = QuerySpec(
          filters: [QueryFilter.gte('updatedAt', base)],
          orderBy: [OrderSpec('updatedAt', descending: false)],
        );

        final items = await orch.readWith(
          scope,
          spec,
          policy: CachePolicy.remoteFirst,
          preferRemoteEval: true,
        );

        // After preferRemoteEval, local should contain the remote-evaluated rows
        final localNow = await local.queryWith(scope, spec);
        expect(localNow.map((e) => e.id), containsAll(['R1', 'R2']));
        expect(items.map((e) => e.id), containsAll(['R1', 'R2']));
      },
    );
  });
}
