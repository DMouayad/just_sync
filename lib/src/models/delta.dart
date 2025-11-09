/// Delta returned by remote: upserts and deletions since a point in time.
class Delta<T, Id> {
  final List<T> upserts;
  final List<Id> deletes;
  final DateTime serverTimestamp;

  const Delta({
    required this.upserts,
    required this.deletes,
    required this.serverTimestamp,
  });
}
