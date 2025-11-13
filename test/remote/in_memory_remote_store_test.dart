import 'package:flutter_test/flutter_test.dart';

import 'package:just_sync/just_sync.dart';

import '../utils/test_database.dart';

void main() {
  group('InMemoryRemoteStore', () {
    late InMemoryRemoteStore<TestModel, String> remote;

    const scope = SyncScope('records', {'userId': 'u1'});

    setUp(() {
      remote = InMemoryRemoteStore<TestModel, String>(
        scopeName: scope.name,
        idOf: (r) => r.id,
      );
    });

    test('getServerTime returns UTC DateTime', () async {
      // Act
      final serverTime = await remote.getServerTime();

      // Assert
      expect(serverTime.isUtc, isTrue);
    });

    test('fetchSince returns a delta with UTC serverTimestamp', () async {
      // Act
      final delta = await remote.fetchSince(scope.keys, null);

      // Assert
      expect(delta.serverTimestamp.isUtc, isTrue);
    });
  });
}
