// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bomb_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bombRepository)
final bombRepositoryProvider = BombRepositoryProvider._();

final class BombRepositoryProvider
    extends $FunctionalProvider<BombRepository, BombRepository, BombRepository>
    with $Provider<BombRepository> {
  BombRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bombRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bombRepositoryHash();

  @$internal
  @override
  $ProviderElement<BombRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BombRepository create(Ref ref) {
    return bombRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BombRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BombRepository>(value),
    );
  }
}

String _$bombRepositoryHash() => r'cd9985a7c7ad9f7d52808ce330a1998e2362a8d7';
