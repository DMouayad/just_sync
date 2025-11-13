import 'dart:async';

import 'package:just_sync/src/models/cache_policy.dart';
import 'package:just_sync/src/models/pending_op.dart';
import 'package:just_sync/src/models/query_spec.dart';
import 'package:just_sync/src/models/sync_scope.dart';
import 'package:just_sync/src/models/traits.dart';

import 'conflict_resolver.dart';
import 'store_interfaces.dart';
import 'sync_orchestrator.dart';

/// Generic, reusable synchronization orchestrator.
/// Assumes `RemoteStore` provides deltas via `fetchSince`, and `LocalStore`
/// persists the last sync point and pending operations.
class SimpleSyncOrchestrator<T extends HasUpdatedAt, Id>
    implements SyncOrchestrator<T, Id> {
  @override
  final LocalStore<T, Id> local;
  @override
  final RemoteStore<T, Id> remote;
  @override
  final ConflictResolver<T> resolver;
  // Strongly-typed ID selector to avoid dynamic casts.
  final Id Function(T) idOf;

  const SimpleSyncOrchestrator({
    required this.local,
    required this.remote,
    required this.resolver,
    required this.idOf,
  });

  @override
  Future<List<T>> read(
    SyncScopeKeys scopeKeys, {
    CachePolicy policy = CachePolicy.remoteFirst,
  }) async {
    switch (policy) {
      case CachePolicy.offlineOnly:
        return local.query(scopeKeys);
      case CachePolicy.onlineOnly:
        await synchronize(scopeKeys);
        final items = await local.query(scopeKeys);
        return items;
      case CachePolicy.localFirst:
        // Return local quickly and refresh from remote in the background.
        final localItems = await local.query(scopeKeys);
        unawaited(synchronize(scopeKeys));
        return localItems;
      case CachePolicy.remoteFirst:
        await synchronize(scopeKeys);
        return local.query(scopeKeys);
    }
  }

  @override
  Future<List<T>> readWith(
    SyncScopeKeys scopeKeys,
    QuerySpec spec, {
    CachePolicy policy = CachePolicy.remoteFirst,
    bool preferRemoteEval = false,
    bool fallbackToLocal = true,
  }) async {
    switch (policy) {
      case CachePolicy.offlineOnly:
        // Pure offline: evaluate QuerySpec against local cache only.
        return local.queryWith(scopeKeys, spec);
      case CachePolicy.localFirst:
        // Return local immediately; refresh in background.
        final localItems = await local.queryWith(scopeKeys, spec);
        unawaited(synchronize(scopeKeys));
        return localItems;
      case CachePolicy.remoteFirst:
      case CachePolicy.onlineOnly:
        // Keep cache-centric results: sync then evaluate on local.
        // Optionally try remote-side evaluation first for accuracy/perf,
        // but still return the locally evaluated result for consistency.
        if (preferRemoteEval) {
          try {
            final remoteItems = await remote.remoteSearch(scopeKeys, spec);
            // Upsert remote-evaluated results into local cache to keep it fresh.
            if (remoteItems.isNotEmpty) {
              await local.upsertMany(scopeKeys, remoteItems);
            }
          } on ArgumentError catch (_) {
            // Backend did not support part of the spec. Fall back to sync+local.
            if (!fallbackToLocal) rethrow;
          }
        }

        await synchronize(scopeKeys);
        return local.queryWith(scopeKeys, spec);
    }
  }

  @override
  Future<void> synchronize(SyncScopeKeys scopeKeys) async {
    // 1) Push pending operations
    final pending = await local.getPendingOps(scopeKeys);
    if (pending.isNotEmpty) {
      final creates = pending.where((p) => p.type == PendingOpType.create);
      final updates = pending.where((p) => p.type == PendingOpType.update);
      final deletes = pending.where((p) => p.type == PendingOpType.delete);

      if (creates.isNotEmpty) {
        await remote.batchUpsert(creates.map((p) => p.payload as T).toList());
      }
      if (updates.isNotEmpty) {
        await remote.batchUpsert(updates.map((p) => p.payload as T).toList());
      }
      if (deletes.isNotEmpty) {
        await remote.batchDelete(deletes.map((p) => p.id).toList());
      }
      await local.clearPendingOps(
        scopeKeys,
        pending.map((p) => p.opId).toList(),
      );
    }

    // 2) Fetch remote delta since the last sync point
    final last = await local.getSyncPoint(scopeKeys);
    final delta = await remote.fetchSince(scopeKeys, last);

    // 3) Merge with local using the conflict resolver
    final localNow = await local.query(scopeKeys);
    final byId = {for (final item in localNow) idOf(item): item};

    // Apply upserts (with conflict resolution)
    for (final up in delta.upserts) {
      final k = idOf(up);
      final existing = byId[k];
      if (existing == null) {
        byId[k] = up;
      } else {
        byId[k] = resolver.resolve(existing, up);
      }
    }

    // Apply deletes
    for (final id in delta.deletes) {
      byId.remove(id);
    }

    // 4) Persist merged state to local
    await local.upsertMany(scopeKeys, byId.values.toList());
    if (delta.deletes.isNotEmpty) {
      await local.deleteMany(scopeKeys, delta.deletes);
    }

    // 5) Save sync point using server timestamp (avoid clock skew)
    await local.saveSyncPoint(scopeKeys, delta.serverTimestamp);
  }

  @override
  Future<void> enqueueCreate(
    SyncScopeKeys scopeKeys,
    Id id,
    T payload, {
    CachePolicy? policy,
  }) async {
    await local.upsertMany(scopeKeys, [payload]);
    if (policy == CachePolicy.offlineOnly) {
      return;
    }
    await local.enqueuePendingOp(
      PendingOp<T, Id>(
        opId: _uuid(),
        scope: SyncScope(local.scopeName, scopeKeys),
        type: PendingOpType.create,
        id: id,
        payload: payload,
        updatedAt: payload.updatedAt,
      ),
    );
    // Fire-and-forget background sync attempt
    unawaited(synchronize(scopeKeys));
  }

  @override
  Future<void> enqueueUpdate(
    SyncScopeKeys scopeKeys,
    Id id,
    T payload, {
    CachePolicy? policy,
  }) async {
    await local.upsertMany(scopeKeys, [payload]);
    if (policy == CachePolicy.offlineOnly) {
      return;
    }
    await local.enqueuePendingOp(
      PendingOp<T, Id>(
        opId: _uuid(),
        scope: SyncScope(local.scopeName, scopeKeys),
        type: PendingOpType.update,
        id: id,
        payload: payload,
        updatedAt: payload.updatedAt,
      ),
    );
    unawaited(synchronize(scopeKeys));
  }

  @override
  Future<void> enqueueDelete(
    SyncScopeKeys scopeKeys,
    Id id, {
    CachePolicy? policy,
  }) async {
    await local.deleteMany(scopeKeys, [id]);
    if (policy == CachePolicy.offlineOnly) {
      return;
    }
    await local.enqueuePendingOp(
      PendingOp<T, Id>(
        opId: _uuid(),
        scope: SyncScope(local.scopeName, scopeKeys),
        type: PendingOpType.delete,
        id: id,
        payload: null,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    unawaited(synchronize(scopeKeys));
  }

  // ID equality provided by Id type; avoid dynamic casts.
}

String _uuid() {
  // Lightweight unique ID generator. Consider a UUID package in production.
  final now = DateTime.now().microsecondsSinceEpoch;
  final rand = now.hashCode ^ DateTime.now().millisecondsSinceEpoch.hashCode;
  return 'op_${now}_$rand';
}
