// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(database)
const databaseProvider = DatabaseProvider._();

final class DatabaseProvider extends $FunctionalProvider<AppDb, AppDb, AppDb>
    with $Provider<AppDb> {
  const DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<AppDb> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDb create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDb value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDb>(value),
    );
  }
}

String _$databaseHash() => r'ed38c2ce308369adadbebeba0520ddbdddcc7754';
