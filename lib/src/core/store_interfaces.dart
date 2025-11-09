import 'package:just_sync/src/models/delta.dart';
import 'package:just_sync/src/models/query_spec.dart';
import 'package:just_sync/src/models/sync_scope.dart';

/// LocalStore abstracts local persistence for syncable models.
abstract interface class LocalStore<T, Id> {
  /// Whether this store performs soft delete (set deletedAt) instead of hard delete.
  bool get supportsSoftDelete => false;

  Future<T?> getById(Id id);
  Future<List<T>> query(SyncScope scope);
  Future<List<T>> querySince(SyncScope scope, DateTime since);

  /// Query with general DB-like filters, ordering and pagination within a scope.
  /// This does not escape the scope and respects soft-delete semantics.
  Future<List<T>> queryWith(SyncScope scope, QuerySpec spec);

  /// Upsert items that belong to the given [scope].
  Future<void> upsertMany(SyncScope scope, List<T> items);

  /// Delete semantics within the given [scope]:
  /// - If [supportsSoftDelete] is true, mark items as deleted (e.g., set deletedAt) and keep rows.
  /// - Otherwise, remove rows permanently (hard delete).
  Future<void> deleteMany(SyncScope scope, List<Id> ids);

  /// Update items that match [spec] within the [scope].
  /// For stores that support soft delete, implementations SHOULD avoid updating tombstoned rows.
  /// Returns the number of affected rows if available, else -1.
  Future<int> updateWhere(SyncScope scope, QuerySpec spec, List<T> newValues);

  /// Delete items that match [spec] within the [scope].
  /// Applies soft/hard delete semantics in the same way as [deleteMany].
  /// Returns the number of affected rows if available, else -1.
  Future<int> deleteWhere(SyncScope scope, QuerySpec spec);

  // Synchronization metadata
  Future<DateTime?> getSyncPoint(SyncScope scope);
  Future<void> saveSyncPoint(SyncScope scope, DateTime timestamp);

  Future<List<PendingOp<T, Id>>> getPendingOps(SyncScope scope);
  // Offline-first write pending job queue
  Future<void> enqueuePendingOp(PendingOp<T, Id> op);
  Future<void> clearPendingOps(SyncScope scope, List<String> opIds);
}

/// RemoteStore abstracts access to the remote service for syncable models.
abstract interface class RemoteStore<T, Id> {
  Future<T?> getById(Id id);
  Future<Delta<T, Id>> fetchSince(SyncScope scope, DateTime? since);

  /// Search within a scope using a normalized query spec. Implementations should
  /// apply soft-delete semantics and only support operators and fields that are
  /// natively available on the backend. Unsupported operators/fields must throw
  /// ArgumentError with a clear message.
  Future<List<T>> remoteSearch(SyncScope scope, QuerySpec spec);
  Future<void> batchUpsert(List<T> items);
  Future<void> batchDelete(List<Id> ids);
  Future<DateTime> getServerTime();
}
