/// Scope identifies a logical subset for syncing, e.g., per user or template.
class SyncScope {
  final String name; // e.g., 'records'
  final Map<String, String>
  keys; // e.g., { 'userId': 'u1', 'templateId': 't1' }

  const SyncScope(this.name, [this.keys = const {}]);

  factory SyncScope.collection(String name) => SyncScope(name);

  @override
  String toString() => 'SyncScope(name=$name, keys=$keys)';

  @override
  bool operator ==(Object other) {
    return other is SyncScope &&
        other.name == name &&
        _mapEquals(other.keys, keys);
  }

  @override
  int get hashCode => Object.hash(
    name,
    keys.entries
        .map((e) => e.key.hashCode ^ e.value.hashCode)
        .fold<int>(0, (a, b) => a ^ b),
  );
}

bool _mapEquals(Map a, Map b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) return false;
  }
  return true;
}
