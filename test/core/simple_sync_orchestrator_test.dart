import 'package:flutter_test/flutter_test.dart';

import 'package:drift/native.dart' show NativeDatabase;
import 'package:just_sync/just_sync.dart';

import '../utils/mock_drift_local_store.dart';
import '../utils/test_database.dart';

void main() {
  group('SimpleSyncOrchestrator', () {
    late TestDatabase db;
    late MockDriftLocalStore local;
    late InMemoryRemoteStore<TestModel, String> remote;
    late SimpleSyncOrchestrator<TestModel, String> orch;
    const scope = SyncScope('records', {'userId': 'u1'});

    setUp(() async {
      db = TestDatabase(NativeDatabase.memory());
      local = MockDriftLocalStore(db);
      remote = InMemoryRemoteStore<TestModel, String>(idOf: (r) => r.id);
      // Seed remote scope maps so batchUpsert/batchDelete affect this scope
      await remote.fetchSince(scope, null);
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

        await orch.enqueueCreate(scope, r.id, r);
        await orch.synchronize(scope);

        // Local contains the item
        final localItems = await local.query(scope);
        expect(localItems.map((e) => e.id), contains(r.id));

        // Remote delta with since=null contains the item as upsert
        final delta = await remote.fetchSince(scope, null);
        expect(delta.upserts.map((e) => e.id), contains(r.id));

        // Pending cleared
        final pending = await local.getPendingOps(scope);
        expect(pending, isEmpty);

        // Sync point saved close to server time (within a few seconds)
        final sp = await local.getSyncPoint(scope);
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
      await orch.synchronize(scope);

      // Ensure local has it
      expect((await local.query(scope)).map((e) => e.id), contains('id2'));

      // Delete via orchestrator
      await orch.enqueueDelete(scope, 'id2');
      await orch.synchronize(scope);

      // Local query excludes it (soft-delete behavior)
      final after = await local.query(scope);
      expect(after.map((e) => e.id), isNot(contains('id2')));

      // Remote delta since t0 should include the deletion
      final delta = await remote.fetchSince(scope, t0);
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
        await local.upsertMany(scope, [old]);

        // Remote provides newer version
        final newer = TestModelFactory.create(
          id: 'id3',
          title: 'new',
          updatedAt: DateTime.now().toUtc(),
        );
        await remote.batchUpsert([newer]);

        await orch.synchronize(scope);
        final items = await local.query(scope);
        final r = items.firstWhere((e) => e.id == 'id3');
        expect(r.title, 'new');
      },
    );

    test('scope isolation: sync on A does not affect B', () async {
      const scopeA = SyncScope('records', {'userId': 'uA'});
      const scopeB = SyncScope('records', {'userId': 'uB'});

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
