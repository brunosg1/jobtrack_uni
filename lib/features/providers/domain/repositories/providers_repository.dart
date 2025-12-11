/// Didactic repository interface for the `Provider` entity.
///
/// NOTES / ASSUMPTIONS:
/// - This file is created from an automated request; I could not find an existing
///   domain entity named `Provider` in the project. To wire this repository you
///   should have a class `Provider` declared at:
///     lib/features/providers/domain/entities/provider.dart
///   If your entity uses a different path/name, update the import below accordingly.
/// - Replace `Provider` below with the actual entity class name if it differs.
/// - This interface follows the project's simple conventions: asynchronous
///   operations that return `Future` and use `List<Provider>` for collections.

import 'package:jobtrack_uni/features/providers/domain/entities/provider_entity.dart';

/// Abstraction for provider storage and retrieval.
///
/// Typical contract used by the domain/usecases layer. Implementations may
/// delegate to local storage, remote APIs, or a combination (cache + network).
abstract class ProvidersRepository {
  /// Returns a list of providers saved in the system.
  ///
  /// - On success returns a non-null List (may be empty).
  /// - On failure throws an exception (let callers handle/report errors).
  Future<List<ProviderEntity>> getProviders();

  /// Saves the list of providers, replacing any existing stored collection.
  ///
  /// Returns `true` when the operation succeeded, or `false` otherwise.
  /// Implementations should not swallow exceptions — prefer throwing on fatal
  /// errors so higher layers can decide how to react.
  Future<bool> saveProviders(List<ProviderEntity> providers);

  /// Adds or updates a single provider.
  ///
  /// Implementations may choose to append or update by id. Returns `true` on
  /// success. Callers should pass a fully-formed `Provider` entity.
  Future<bool> upsertProvider(ProviderEntity provider);

  /// Removes the provider identified by [id]. Returns `true` when the provider
  /// was found and removed, `false` when no provider matched the id.
  Future<bool> removeProvider(String id);
}
