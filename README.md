# just_sync

[![pub version](https://img.shields.io/pub/v/just_sync.svg)](https://pub.dev/packages/just_sync)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A solution for building offline-first Flutter applications by synchronizing a local database with remote backend services. 

## Features

### Offline-First Architecture
Keep your app fully functional with or without a network connection. Changes made offline are automatically queued and synced when the connection is restored.

### Pluggable Backends
The `RemoteStore` interface makes it easy to create adapters for any backend.
### Customizable Conflict Resolution
A default "last write wins" resolver is included. You can easily provide your own logic to handle complex data merge conflicts.
### Scoped Synchronization
`SyncScope` enables Multi-tenant Data Separation and Partial Sync: Synchronize logical subsets of your data (e.g., data per-user or per-project).
### Normalized Querying
`QuerySpec` allows you to build complex filters and sorting that are translated into native SQL or PostgREST queries.



## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.
