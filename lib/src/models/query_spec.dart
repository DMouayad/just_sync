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
  between,
  inList, // value IN (...)
}

/// A single filter predicate. Field names should match the serialized payload keys.
class FilterOp<T> {
  final String field;
  final FilterOperator op;
  final dynamic value;

  const FilterOp.eq(this.field, T this.value) : op = FilterOperator.eq;
  const FilterOp.neq(this.field, T this.value) : op = FilterOperator.neq;
  const FilterOp.gt(this.field, T this.value) : op = FilterOperator.gt;
  const FilterOp.gte(this.field, T this.value) : op = FilterOperator.gte;
  const FilterOp.lt(this.field, T this.value) : op = FilterOperator.lt;
  const FilterOp.lte(this.field, T this.value) : op = FilterOperator.lte;
  const FilterOp.like(this.field, T this.value) : op = FilterOperator.like;
  const FilterOp.between(
    this.field, {
    required T firstValue,
    required T secondValue,
  }) : op = FilterOperator.between,
       value = (firstValue, secondValue);
  const FilterOp.contains(this.field, this.value)
    : op = FilterOperator.contains;
  FilterOp.isNull(this.field) : op = FilterOperator.isNull, value = null;
  FilterOp.isNotNull(this.field) : op = FilterOperator.isNotNull, value = null;
  const FilterOp.inList(this.field, List values)
    : op = FilterOperator.inList,
      value = values;
}

/// Ordering specification.
class OrderSpec {
  final String field;
  final bool descending;

  const OrderSpec(this.field, {this.descending = false});
}
