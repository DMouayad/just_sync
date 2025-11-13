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
    late final scope = SyncScope(db.mockTable.defaultScopeName, {
      'userId': 'u1',
    });

    setUp(() async {
      db = TestDatabase();
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
      await store.upsertMany(scope.keys, items);

      // status == 'open' AND count > 5, order by count desc, limit 2
      final spec = QuerySpec(
        filters: const [
          QueryFilter.eq('status', 'open'),
          QueryFilter.gt('count', 5),
        ],
        orderBy: const [OrderSpec('count', descending: true)],
        limit: 2,
      );
      final res = await store.queryWith(scope.keys, spec);
      expect(res.map((e) => e.id).toList(), ['b', 'd']);

      // like on title, contains on tags, inList on status
      final spec2 = QuerySpec(
        filters: const [
          QueryFilter.like('title', 'Al'),
          QueryFilter.contains('tags', 'x'),
          QueryFilter.inList('status', ['open', 'closed']),
        ],
        orderBy: const [OrderSpec('id')],
      );
      final res2 = await store.queryWith(scope.keys, spec2);
      expect(res2.map((e) => e.id).toList(), ['a', 'd']);
    });
  });
  group('QuerySpec filtering', () {
    late TestDatabase db;
    late MockDriftLocalStore store;
    const scope = SyncScope('records', {'userId': 'u1'});

    setUp(() async {
      db = TestDatabase();
      store = MockDriftLocalStore(db);

      final records = [
        TestModelFactory.create(
          id: '1',
          title: 'apple',
          count: 10,
          updatedAt: DateTime.utc(2025, 1, 1),
          completed: false,
        ),
        TestModelFactory.create(
          id: '2',
          title: 'banana',
          count: 20,
          updatedAt: DateTime.utc(2025, 1, 2),
          completed: true,
        ),
        TestModelFactory.create(
          id: '3',
          title: 'apple pie',
          count: 30,
          updatedAt: DateTime.utc(2025, 1, 3),
          completed: false,
          tags: ['fruit', 'dessert'],
        ),
        TestModelFactory.create(
          id: '4',
          title: 'orange',
          count: 20,
          updatedAt: DateTime.utc(2025, 1, 4),
          completed: true,
        ),
      ];
      await store.upsertMany(scope.keys, records);
    });

    tearDown(() async {
      await db.close();
    });

    // String filters
    test('String eq', () async {
      final spec = QuerySpec(filters: [QueryFilter.eq('title', 'apple')]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), ['1']);
    });

    test('String neq', () async {
      final spec = QuerySpec(filters: [QueryFilter.neq('title', 'apple')]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['2', '3', '4']));
    });

    test('String contains', () async {
      final spec = QuerySpec(filters: [QueryFilter.contains('title', 'apple')]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['1', '3']));
    });

    test('String inList', () async {
      final spec = QuerySpec(
        filters: [
          QueryFilter.inList('title', ['apple', 'orange']),
        ],
      );
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['1', '4']));
    });

    // Int filters
    test('Int gt', () async {
      final spec = QuerySpec(filters: [QueryFilter.gt('count', 20)]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), ['3']);
    });

    test('Int gte', () async {
      final spec = QuerySpec(filters: [QueryFilter.gte('count', 20)]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['2', '3', '4']));
    });

    test('Int lt', () async {
      final spec = QuerySpec(filters: [QueryFilter.lt('count', 20)]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), ['1']);
    });

    test('Int lte', () async {
      final spec = QuerySpec(filters: [QueryFilter.lte('count', 20)]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['1', '2', '4']));
    });

    test('Int inList', () async {
      final spec = QuerySpec(
        filters: [
          QueryFilter.inList('count', [10, 30]),
        ],
      );
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['1', '3']));
    });

    // DateTime filters
    test('DateTime gt', () async {
      final spec = QuerySpec(
        filters: [QueryFilter.gt('updatedAt', DateTime.utc(2025, 1, 2))],
      );
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['3', '4']));
    });

    test('DateTime lte', () async {
      final spec = QuerySpec(
        filters: [QueryFilter.lte('updatedAt', DateTime.utc(2025, 1, 2))],
      );
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['1', '2']));
    });

    // Bool filters
    test('Bool eq', () async {
      final spec = QuerySpec(filters: [QueryFilter.eq('completed', true)]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['2', '4']));
    });

    // Null filters
    test('isNull', () async {
      final spec = QuerySpec(filters: [QueryFilter.isNull('tags')]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['1', '2', '4']));
    });

    test('isNotNull', () async {
      final spec = QuerySpec(filters: [QueryFilter.isNotNull('tags')]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), ['3']);
    });

    // Combined filters
    test('multiple filters (AND)', () async {
      final spec = QuerySpec(
        filters: [
          QueryFilter.gte('count', 20),
          QueryFilter.eq('completed', true),
        ],
      );
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), unorderedEquals(['2', '4']));
    });

    // Ordering
    test('orderBy ascending', () async {
      final spec = QuerySpec(orderBy: [OrderSpec('count')]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), ['1', '2', '4', '3']);
    });

    test('orderBy descending', () async {
      final spec = QuerySpec(orderBy: [OrderSpec('count', descending: true)]);
      final results = await store.queryWith(scope.keys, spec);
      expect(results.map((e) => e.id), ['3', '2', '4', '1']);
    });
    group('QuerySpec Pagination', () {
      test('limit', () async {
        final spec = QuerySpec(orderBy: [OrderSpec('id')], limit: 2);
        final results = await store.queryWith(scope.keys, spec);
        expect(results.map((e) => e.id), ['1', '2']);
      });

      test('limit and offset', () async {
        final spec = QuerySpec(orderBy: [OrderSpec('id')], limit: 2, offset: 1);
        final results = await store.queryWith(scope.keys, spec);
        expect(results.map((e) => e.id), ['2', '3']);
      });
    });
  });
}
