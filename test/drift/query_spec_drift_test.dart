import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:just_sync/just_sync.dart';

import '../utils/mock_drift_local_store.dart';
import '../utils/test_database.dart';

void main() {
  // Required for drift_flutter/path_provider in tests.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    // Suppress multiple database warning in tests where the same executor can be reused.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('DriftLocalStore QuerySpec', () {
    late TestDatabase db;
    late MockDriftLocalStore store;
    const scope = SyncScope('records', {'userId': 'u1'});

    setUp(() async {
      db = TestDatabase(NativeDatabase.memory());
      store = MockDriftLocalStore(db);
    });
    tearDown(() async => await db.close());

    test('queryWith: payload filters + order + limit/offset', () async {
      final now = DateTime.now().toUtc();
      final items = <TestModel>[
        TestModelFactory.create(
          id: 'a',
          title: 'Alpha',
          updatedAt: now.subtract(const Duration(minutes: 3)),
          status: 'open',
          count: 5,
          tags: const ['x', 'y'],
        ),
        TestModelFactory.create(
          id: 'b',
          title: 'Beta',
          updatedAt: now.subtract(const Duration(minutes: 2)),
          status: 'open',
          count: 10,
          tags: const ['y'],
        ),
        TestModelFactory.create(
          id: 'c',
          title: 'Gamma',
          updatedAt: now.subtract(const Duration(minutes: 1)),
          status: 'closed',
          count: 2,
          tags: const ['z'],
        ),
        TestModelFactory.create(
          id: 'd',
          title: 'Alpine',
          updatedAt: now,
          status: 'open',
          count: 8,
          tags: const ['x', 'z'],
        ),
      ];
      await store.upsertMany(scope, items);

      // status == 'open' AND count > 5, order by count desc, limit 2
      final spec = QuerySpec(
        filters: const [
          FilterOp(field: 'status', op: FilterOperator.eq, value: 'open'),
          FilterOp(field: 'count', op: FilterOperator.gt, value: 5),
        ],
        orderBy: const [OrderSpec('count', descending: true)],
        limit: 2,
      );
      final res = await store.queryWith(scope, spec);
      expect(res.map((e) => e.id).toList(), ['b', 'd']);

      // like on title, contains on tags, inList on status
      final spec2 = QuerySpec(
        filters: const [
          FilterOp(field: 'title', op: FilterOperator.like, value: 'Al'),
          FilterOp(field: 'tags', op: FilterOperator.contains, value: 'x'),
          FilterOp(
            field: 'status',
            op: FilterOperator.inList,
            value: ['open', 'closed'],
          ),
        ],
        orderBy: const [OrderSpec('id')],
      );
      final res2 = await store.queryWith(scope, spec2);
      expect(res2.map((e) => e.id).toList(), ['a', 'd']);
    });

    test('updateWhere/deleteWhere work with spec', () async {
      final now = DateTime.now().toUtc();
      await store.upsertMany(scope, [
        TestModelFactory.create(id: 'x', title: 'X', updatedAt: now),
        TestModelFactory.create(id: 'y', title: 'Y', updatedAt: now),
      ]);

      // updateWhere: only ids that match spec should be updated
      final spec = QuerySpec(
        filters: const [
          FilterOp(field: 'id', op: FilterOperator.inList, value: ['x']),
        ],
      );
      final changed = await store.updateWhere(scope, spec, [
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
        scope,
        QuerySpec(
          filters: const [
            FilterOp(field: 'id', op: FilterOperator.eq, value: 'x'),
          ],
        ),
      );
      expect(after.single.title, 'X2');

      // deleteWhere by id
      final deleted = await store.deleteWhere(
        scope,
        QuerySpec(
          filters: const [
            FilterOp(field: 'id', op: FilterOperator.eq, value: 'y'),
          ],
        ),
      );
      expect(deleted, 1);
      final remain = await store.query(scope);
      expect(remain.map((e) => e.id), contains('x'));
      expect(remain.map((e) => e.id), isNot(contains('y')));
    });
  });
}
