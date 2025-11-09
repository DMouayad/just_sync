import 'package:just_sync/src/models/sync_scope.dart';

/// Indicates the hold job that will be sent remotely while online.
class PendingOp<T, Id> {
  final String opId; // unique per op
  final SyncScope scope;
  final PendingOpType type;
  final Id id;
  final T? payload; // null for delete
  final DateTime updatedAt;

  const PendingOp({
    required this.opId,
    required this.scope,
    required this.type,
    required this.id,
    required this.payload,
    required this.updatedAt,
  });
}

enum PendingOpType { create, update, delete }

/// A normalized query description that can be mapped to local or remote backends.
class QuerySpec {
  final List<FilterOp> filters;
  final List<OrderSpec> orderBy;
  final int? limit;
  final int? offset;

  const QuerySpec({
    this.filters = const [],
    this.orderBy = const [],
    this.limit,
    this.offset,
  });

  QuerySpec copyWith({
    List<FilterOp>? filters,
    List<OrderSpec>? orderBy,
    int? limit,
    int? offset,
  }) {
    return QuerySpec(
      filters: filters ?? this.filters,
      orderBy: orderBy ?? this.orderBy,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

/// Supported filter operators for general DB-like querying.
enum FilterOperator {
  eq,
  neq,
  gt,
  gte,
  lt,
  lte,
  like, // substring or pattern match depending on backend
  contains, // array contains or string contains depending on backend support
  isNull,
  isNotNull,
  inList, // value IN (...)
}

/// A single filter predicate. Field names should match the serialized payload keys.
class FilterOp {
  final String field;
  final FilterOperator op;
  final Object? value;

  const FilterOp({required this.field, required this.op, this.value});
}

/// Ordering specification.
class OrderSpec {
  final String field;
  final bool descending;

  const OrderSpec(this.field, {this.descending = false});
}
