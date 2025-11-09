/// Exception thrown when a network operation fails during synchronization.
class JustSyncNetworkException implements Exception {
  final String message;
  final dynamic innerException;

  JustSyncNetworkException(this.message, {this.innerException});

  @override
  String toString() => 'JustSyncNetworkException: $message';
}

/// Exception thrown when the remote server returns an error during synchronization.
class JustSyncServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic innerException;

  JustSyncServerException(this.message, {this.statusCode, this.innerException});

  @override
  String toString() =>
      'JustSyncServerException: $message (Status: $statusCode)';
}
