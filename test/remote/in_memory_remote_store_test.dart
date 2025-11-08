import 'package:flutter_test/flutter_test.dart';
import 'package:just_sync/src/remote/in_memory_remote_store.dart';
import 'package:just_sync/src/types.dart';

import '../utils/test_database.dart';

void main() {
  group('InMemoryRemoteStore', () {
    late InMemoryRemoteStore<TestModel, String> remote;
    const scope = SyncScope('records', {'userId': 'u1'});

    setUp(() {
      remote = InMemoryRemoteStore<TestModel, String>(idOf: (r) => r.id);
    });

    test('getServerTime returns UTC DateTime', () async {
      // Act
      final serverTime = await remote.getServerTime();

      // Assert
      expect(serverTime.isUtc, isTrue);
    });

    test('fetchSince returns a delta with UTC serverTimestamp', () async {
      // Act
      final delta = await remote.fetchSince(scope, null);

      // Assert
      expect(delta.serverTimestamp.isUtc, isTrue);
    });
  });
}
