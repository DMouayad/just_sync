import 'package:just_sync/src/models/cache_policy.dart';
import 'package:just_sync/src/models/query_spec.dart';
import 'package:just_sync/src/models/sync_scope.dart';
import 'package:just_sync/src/models/traits.dart';

import 'conflict_resolver.dart';
import 'store_interfaces.dart';

/// Synchronization orchestrator interface.
/// - Sends accumulated pending ops from local to remote.
/// - Fetches delta from remote and merges using `ConflictResolver`.
/// - Updates local state and persists the sync point.
abstract interface class SyncOrchestrator<T extends HasUpdatedAt, Id> {
  LocalStore<T, Id> get local;
  RemoteStore<T, Id> get remote;
  ConflictResolver<T> get resolver;

  Future<List<T>> read(SyncScopeKeys scopeKeys, {CachePolicy policy});

  /// Read with a normalized query spec through the orchestrator.
  ///
  /// Default behavior is cache-centric: synchronize first (for online policies)
  /// and then evaluate the query against the local cache to keep results
  /// consistent with offline reads.
  ///
  /// If [preferRemoteEval] is true, the orchestrator will try to evaluate the
  /// query on the remote first (using `RemoteStore.remoteSearch`) and upsert
  /// the results into local before returning the locally-evaluated result.
  /// When the remote does not support certain operators/fields and throws
  /// `ArgumentError`, the call will fall back to local (if [fallbackToLocal]
  /// is true) after performing a synchronization.
  Future<List<T>> readWith(
    SyncScopeKeys scopeKeys,
    QuerySpec spec, {
    CachePolicy policy = CachePolicy.remoteFirst,
    bool preferRemoteEval = false,
    bool fallbackToLocal = true,
  });

  /// When online, push pending ops, fetch delta, and merge into local.
  Future<void> synchronize(SyncScopeKeys scopeKeys);

  /// Enqueue local ops and attempt background sync when possible.
  Future<void> enqueueCreate(
    SyncScopeKeys scopeKeys,
    Id id,
    T payload, {
    CachePolicy? policy,
  });
  Future<void> enqueueUpdate(
    SyncScopeKeys scopeKeys,
    Id id,
    T payload, {
    CachePolicy? policy,
  });
  Future<void> enqueueDelete(
    SyncScopeKeys scopeKeys,
    Id id, {
    CachePolicy? policy,
  });
}
