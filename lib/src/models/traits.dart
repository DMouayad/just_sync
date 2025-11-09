/// Marker interface for models that carry an `updatedAt` timestamp.
abstract interface class HasUpdatedAt {
  DateTime get updatedAt;
}

/// Marker interface for models that expose a stable identifier.
abstract interface class HasId<Id> {
  Id get id;
}

/// Marker interface for models that support soft delete semantics.
abstract interface class SupportsSoftDelete {
  DateTime? get deletedAt; // null means not deleted
}
