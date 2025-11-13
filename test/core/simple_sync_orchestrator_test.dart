import 'package:flutter_test/flutter_test.dart';

import 'package:just_sync/just_sync.dart';

import '../utils/mock_drift_local_store.dart';
import '../utils/test_database.dart';

void main() {
  group('SimpleSyncOrchestrator', () {
    late TestDatabase db;
    late MockDriftLocalStore local;
    late InMemoryRemoteStore<TestModel, String> remote;
    late SimpleSyncOrchestrator<TestModel, String> orch;

    const SyncScopeKeys scopeKeys = {'userId': 'u1'};
    setUp(() async {
      db = TestDatabase();
      local = MockDriftLocalStore(db);
      remote = InMemoryRemoteStore<TestModel, String>(
        scopeName: db.mockTable.defaultScopeName,
        idOf: (r) => r.id,
      );
      // Seed remote scope maps so batchUpsert/batchDelete affect this scope
      await remote.fetchSince(scopeKeys, null);
      orch = SimpleSyncOrchestrator<TestModel, String>(
        local: local,
        remote: remote,
        resolver: const LastWriteWinsResolver<TestModel>(),
        idOf: (r) => r.id,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'enqueueCreate + synchronize pushes to remote and clears pending',
      () async {
        final now = DateTime.now().toUtc();
        final r = TestModelFactory.create(
          id: 'id1',
          title: 'A',
          updatedAt: now,
        );

        await orch.enqueueCreate(scopeKeys, r.id, r);
        await orch.synchronize(scopeKeys);

        // Local contains the item
        final localItems = await local.query(scopeKeys);
        expect(localItems.map((e) => e.id), contains(r.id));

        // Remote delta with since=null contains the item as upsert
        final delta = await remote.fetchSince(scopeKeys, null);
        expect(delta.upserts.map((e) => e.id), contains(r.id));

        // Pending cleared
        final pending = await local.getPendingOps(scopeKeys);
        expect(pending, isEmpty);

        // Sync point saved close to server time (within a few seconds)
        final sp = await local.getSyncPoint(scopeKeys);
        expect(sp, isNotNull);
        final serverNow = await remote.getServerTime();
        expect(serverNow.difference(sp!).inSeconds.abs() < 5, isTrue);
      },
    );

    test('delete flows through and is excluded by soft-delete', () async {
      // Prepare a record present remotely and locally after initial sync
      final t0 = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      final rec = TestModelFactory.create(id: 'id2', title: 'B', updatedAt: t0);
      await remote.batchUpsert([rec]);
      await orch.synchronize(scopeKeys);

      // Ensure local has it
      expect((await local.query(scopeKeys)).map((e) => e.id), contains('id2'));

      // Delete via orchestrator
      await orch.enqueueDelete(scopeKeys, 'id2');
      await orch.synchronize(scopeKeys);

      // Local query excludes it (soft-delete behavior)
      final after = await local.query(scopeKeys);
      expect(after.map((e) => e.id), isNot(contains('id2')));

      // Remote delta since t0 should include the deletion
      final delta = await remote.fetchSince(scopeKeys, t0);
      expect(delta.deletes, contains('id2'));
    });

    test(
      'delta upsert prefers resolver (LastWriteWins by updatedAt)',
      () async {
        // Existing local record with older updatedAt
        final old = TestModelFactory.create(
          id: 'id3',
          title: 'old',
          updatedAt: DateTime.now().toUtc().subtract(
            const Duration(minutes: 5),
          ),
        );
        await local.upsertMany(scopeKeys, [old]);

        // Remote provides newer version
        final newer = TestModelFactory.create(
          id: 'id3',
          title: 'new',
          updatedAt: DateTime.now().toUtc(),
        );
        await remote.batchUpsert([newer]);

        await orch.synchronize(scopeKeys);
        final items = await local.query(scopeKeys);
        final r = items.firstWhere((e) => e.id == 'id3');
        expect(r.title, 'new');
      },
    );

    test('scope isolation: sync on A does not affect B', () async {
      const scopeA = {'userId': 'uA'};
      const scopeB = {'userId': 'uB'};

      // Seed scopes
      await remote.fetchSince(scopeA, null);
      await remote.fetchSince(scopeB, null);

      // Use different IDs to avoid InMemoryRemoteStore distributing same-ID upserts across scopes.
      final recA = TestModelFactory.create(
        id: 'idA',
        title: 'A',
        updatedAt: DateTime.now().toUtc(),
      );
      final recB = TestModelFactory.create(
        id: 'idB',
        title: 'B',
        updatedAt: DateTime.now().toUtc(),
      );

      // Put different records per scope directly on remote by manipulating maps via batchUpsert
      // Since InMemoryRemoteStore upserts across existing scope entries, ensure both scopes exist (seeded above)
      await remote.batchUpsert([recA, recB]);

      // Sync only scopeA
      await orch.synchronize(scopeA);
      final a = await local.query(scopeA);
      expect(a.map((e) => e.id), contains('idA'));
      expect(a.map((e) => e.title), contains('A'));

      final bBefore = await local.query(scopeB);
      // Still empty because we didn't sync scopeB
      expect(bBefore, isEmpty);
    });
  });
}
