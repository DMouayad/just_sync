import 'package:drift/drift.dart';
import 'package:drift/native.dart' show NativeDatabase;
import 'package:just_sync/just_sync.dart';

part 'test_database.g.dart';

@DataClassName('TestModel', implementing: [DriftModel<String>])
class MockTable extends Table
    with DriftSyncTableMixin, DriftSoftDeleteTableMixin {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get status => text().withDefault(Constant(''))();
  IntColumn get count => integer().withDefault(Constant(0))();
  TextColumn get tags => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [MockTable, SyncPoints, PendingOps])
class TestDatabase extends _$TestDatabase implements IDriftDatabase {
  TestDatabase._(super.e);

  factory TestDatabase({bool logStatements = false}) {
    return TestDatabase._(
      LazyDatabase(() async {
        return DatabaseConnection(
          NativeDatabase.memory(logStatements: logStatements),
          closeStreamsSynchronously: true,
        );
      }),
    );
  }

  @override
  int get schemaVersion => 1;
}

class TestModelFactory {
  static TestModel create({
    required String id,
    String title = '',
    DateTime? updatedAt,
    String status = '',
    int count = 0,
    List<String>? tags,
    String scopeKeys = '',
  }) {
    return TestModel(
      scopeName: 'test',
      scopeKeys: scopeKeys,
      id: id,
      title: title,
      status: status,
      count: count,
      tags: tags?.join(','),
      updatedAt: updatedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}
