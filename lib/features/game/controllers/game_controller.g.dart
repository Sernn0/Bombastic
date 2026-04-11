// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 활성 폭탄 실시간 스트림 (단일, 하위 호환용)

@ProviderFor(activeBomb)
final activeBombProvider = ActiveBombFamily._();

/// 현재 활성 폭탄 실시간 스트림 (단일, 하위 호환용)

final class ActiveBombProvider
    extends
        $FunctionalProvider<
          AsyncValue<BombModel?>,
          BombModel?,
          Stream<BombModel?>
        >
    with $FutureModifier<BombModel?>, $StreamProvider<BombModel?> {
  /// 현재 활성 폭탄 실시간 스트림 (단일, 하위 호환용)
  ActiveBombProvider._({
    required ActiveBombFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeBombProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeBombHash();

  @override
  String toString() {
    return r'activeBombProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<BombModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<BombModel?> create(Ref ref) {
    final argument = this.argument as String;
    return activeBomb(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveBombProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeBombHash() => r'0655d94825bac943b0bffa7c2ed15a38aed1c6f8';

/// 현재 활성 폭탄 실시간 스트림 (단일, 하위 호환용)

final class ActiveBombFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BombModel?>, String> {
  ActiveBombFamily._()
    : super(
        retry: null,
        name: r'activeBombProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 현재 활성 폭탄 실시간 스트림 (단일, 하위 호환용)

  ActiveBombProvider call(String groupId) =>
      ActiveBombProvider._(argument: groupId, from: this);

  @override
  String toString() => r'activeBombProvider';
}

/// 모든 활성 폭탄 실시간 스트림 (다중 폭탄 지원)

@ProviderFor(activeBombs)
final activeBombsProvider = ActiveBombsFamily._();

/// 모든 활성 폭탄 실시간 스트림 (다중 폭탄 지원)

final class ActiveBombsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BombModel>>,
          List<BombModel>,
          Stream<List<BombModel>>
        >
    with $FutureModifier<List<BombModel>>, $StreamProvider<List<BombModel>> {
  /// 모든 활성 폭탄 실시간 스트림 (다중 폭탄 지원)
  ActiveBombsProvider._({
    required ActiveBombsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeBombsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeBombsHash();

  @override
  String toString() {
    return r'activeBombsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<BombModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BombModel>> create(Ref ref) {
    final argument = this.argument as String;
    return activeBombs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveBombsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeBombsHash() => r'69ee8c31d51feb7776c831ae7c98bc7364301b6c';

/// 모든 활성 폭탄 실시간 스트림 (다중 폭탄 지원)

final class ActiveBombsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<BombModel>>, String> {
  ActiveBombsFamily._()
    : super(
        retry: null,
        name: r'activeBombsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 모든 활성 폭탄 실시간 스트림 (다중 폭탄 지원)

  ActiveBombsProvider call(String groupId) =>
      ActiveBombsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'activeBombsProvider';
}

/// 내 차례인지 여부 (다중 폭탄 중 하나라도 내가 보유하면 true)

@ProviderFor(isMyTurn)
final isMyTurnProvider = IsMyTurnFamily._();

/// 내 차례인지 여부 (다중 폭탄 중 하나라도 내가 보유하면 true)

final class IsMyTurnProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 내 차례인지 여부 (다중 폭탄 중 하나라도 내가 보유하면 true)
  IsMyTurnProvider._({
    required IsMyTurnFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isMyTurnProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isMyTurnHash();

  @override
  String toString() {
    return r'isMyTurnProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isMyTurn(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsMyTurnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isMyTurnHash() => r'8cadcf2220e92262e699eae4e27b4ba159833140';

/// 내 차례인지 여부 (다중 폭탄 중 하나라도 내가 보유하면 true)

final class IsMyTurnFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsMyTurnFamily._()
    : super(
        retry: null,
        name: r'isMyTurnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 내 차례인지 여부 (다중 폭탄 중 하나라도 내가 보유하면 true)

  IsMyTurnProvider call(String groupId) =>
      IsMyTurnProvider._(argument: groupId, from: this);

  @override
  String toString() => r'isMyTurnProvider';
}

@ProviderFor(GameController)
final gameControllerProvider = GameControllerProvider._();

final class GameControllerProvider
    extends $NotifierProvider<GameController, AsyncValue<void>> {
  GameControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameControllerHash();

  @$internal
  @override
  GameController create() => GameController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$gameControllerHash() => r'54554a1e645fbe134c19563b02ef55d3964c1327';

abstract class _$GameController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
