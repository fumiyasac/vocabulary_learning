// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VocabularyNotifier)
const vocabularyProvider = VocabularyNotifierProvider._();

final class VocabularyNotifierProvider
    extends $NotifierProvider<VocabularyNotifier, VocabularyState> {
  const VocabularyNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabularyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabularyNotifierHash();

  @$internal
  @override
  VocabularyNotifier create() => VocabularyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VocabularyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VocabularyState>(value),
    );
  }
}

String _$vocabularyNotifierHash() =>
    r'e3679b04afc2dda243a33283912a0f3b790af979';

abstract class _$VocabularyNotifier extends $Notifier<VocabularyState> {
  VocabularyState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VocabularyState, VocabularyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VocabularyState, VocabularyState>,
              VocabularyState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
