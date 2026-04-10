// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(missionRepository)
final missionRepositoryProvider = MissionRepositoryProvider._();

final class MissionRepositoryProvider
    extends
        $FunctionalProvider<
          MissionRepository,
          MissionRepository,
          MissionRepository
        >
    with $Provider<MissionRepository> {
  MissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionRepositoryHash();

  @$internal
  @override
  $ProviderElement<MissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MissionRepository create(Ref ref) {
    return missionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MissionRepository>(value),
    );
  }
}

String _$missionRepositoryHash() => r'096189ed0b03bdfb3754cd2e87677dd0e315b815';
