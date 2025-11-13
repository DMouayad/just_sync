import 'package:just_sync/src/models/delta.dart';
import 'package:just_sync/src/models/pending_op.dart';
import 'package:just_sync/src/models/query_spec.dart';
import 'package:just_sync/src/models/sync_scope.dart';

/// LocalStore abstracts local persistence for syncable models.
abstract interface class LocalStore<T, Id> {
  final String scopeName;

  const LocalStore(this.scopeName);

  /// Whether this store performs soft delete (set deletedAt) instead of hard delete.
  bool get supportsSoftDelete => false;
  Future<T?> getById(Id id);
  Future<List<T>> query(SyncScopeKeys scopeKeys);
  Future<List<T>> querySince(SyncScopeKeys scopeKeys, DateTime since);

  /// Query with general DB-like filters, ordering and pagination within a scope.
  /// This does not escape the scope and respects soft-delete semantics.
  Future<List<T>> queryWith(SyncScopeKeys scopeKeys, QuerySpec spec);

  /// Upsert items that belong to the scope defined by [scopeName] and the given [scopeKeys].
  Future<void> upsertMany(SyncScopeKeys scopeKeys, List<T> items);

  /// Delete semantics within the scope [scopeName] and the given [scopeKeys]:
  /// - If [supportsSoftDelete] is true, mark items as deleted (e.g., set deletedAt) and keep rows.
  /// - Otherwise, remove rows permanently (hard delete).
  Future<void> deleteMany(SyncScopeKeys scopeKeys, List<Id> ids);

  /// Update items that match [spec] within the scope of [scopeName] and the given [scopeKeys].
  ///
  /// For stores that support soft delete, implementations SHOULD avoid updating tombstoned rows.
  /// Returns the number of affected rows if available, else -1.
  Future<int> updateWhere(
    SyncScopeKeys scopeKeys,
    QuerySpec spec,
    List<T> newValues,
  );

  /// Delete items that match [spec] within the scope defined by [scopeName]
  /// and the given [scopeKeys].
  ///
  /// Applies soft/hard delete semantics in the same way as [deleteMany].
  /// Returns the number of affected rows if available, else -1.
  Future<int> deleteWhere(SyncScopeKeys scopeKeys, QuerySpec spec);

  // Synchronization metadata
  Future<DateTime?> getSyncPoint(SyncScopeKeys scopeKeys);
  Future<void> saveSyncPoint(SyncScopeKeys scopeKeys, DateTime timestamp);

  Future<List<PendingOp<T, Id>>> getPendingOps(SyncScopeKeys scopeKeys);
  // Offline-first write pending job queue
  Future<void> enqueuePendingOp(PendingOp<T, Id> op);
  Future<void> clearPendingOps(SyncScopeKeys scopeKeys, List<String> opIds);
}

/// RemoteStore abstracts access to the remote service for syncable models.
abstract interface class RemoteStore<T, Id> {
  final String scopeName;

  const RemoteStore(this.scopeName);
  Future<T?> getById(Id id);
  Future<Delta<T, Id>> fetchSince(SyncScopeKeys scopeKeys, DateTime? since);

  /// Search within a scope using a normalized query spec.
  ///
  /// Implementations should apply soft-delete semantics and only support operators and fields that are
  /// natively available on the backend. Unsupported operators/fields must throw
  /// ArgumentError with a clear message.
  Future<List<T>> remoteSearch(SyncScopeKeys scopeKeys, QuerySpec spec);
  Future<void> batchUpsert(List<T> items);
  Future<void> batchDelete(List<Id> ids);
  Future<DateTime> getServerTime();
}
