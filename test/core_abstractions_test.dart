import 'package:flutter_test/flutter_test.dart';
import 'package:just_sync/just_sync.dart';

import 'utils/test_database.dart';

void main() {
  group('SyncScope', () {
    test('should have correct equality', () {
      const scope1 = SyncScope('todos', {'userId': '1'});
      const scope2 = SyncScope('todos', {'userId': '1'});
      const scope3 = SyncScope('todos', {'userId': '2'});
      const scope4 = SyncScope('tasks', {'userId': '1'});

      expect(scope1, equals(scope2));
      expect(scope1.hashCode, equals(scope2.hashCode));
      expect(scope1, isNot(equals(scope3)));
      expect(scope1, isNot(equals(scope4)));
    });
  });

  group('LastWriteWinsResolver', () {
    test('should return the model with the latest updatedAt timestamp', () {
      final now = DateTime.now();
      final local = TestModelFactory.create(id: '1', updatedAt: now);
      final remote = TestModelFactory.create(
        id: '1',
        updatedAt: now.add(const Duration(seconds: 1)),
      );

      const resolver = LastWriteWinsResolver<TestModel>();
      final result = resolver.resolve(local, remote);

      expect(result, equals(remote));
    });

    test('conflict resolution works correctly with UTC times', () {
      // Arrange
      final time1 = DateTime.utc(2025, 1, 1, 12, 0, 0);
      final time2 = DateTime.utc(2025, 1, 1, 12, 5, 0); // 5 minutes later

      final localModel = TestModelFactory.create(
        id: 'utc_test',
        title: 'local',
        updatedAt: time1,
      );
      final remoteModel = TestModelFactory.create(
        id: 'utc_test',
        title: 'remote',
        updatedAt: time2,
      );

      const resolver = LastWriteWinsResolver<TestModel>();

      // Act
      final winner = resolver.resolve(localModel, remoteModel);

      // Assert
      expect(winner.title, 'remote');
      expect(winner.updatedAt, time2);
    });
  });
}
