// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verbatim_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(verbatimData)
final verbatimDataProvider = VerbatimDataProvider._();

final class VerbatimDataProvider
    extends
        $FunctionalProvider<
          List<VerbatimNode>,
          List<VerbatimNode>,
          List<VerbatimNode>
        >
    with $Provider<List<VerbatimNode>> {
  VerbatimDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verbatimDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verbatimDataHash();

  @$internal
  @override
  $ProviderElement<List<VerbatimNode>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<VerbatimNode> create(Ref ref) {
    return verbatimData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<VerbatimNode> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<VerbatimNode>>(value),
    );
  }
}

String _$verbatimDataHash() => r'78f5a08d0c92ca98dfe84d90404463eeee1e789b';
