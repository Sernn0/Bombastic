// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 유저가 참여 중인 그룹 목록 실시간 스트림

@ProviderFor(myGroups)
final myGroupsProvider = MyGroupsProvider._();

/// 현재 유저가 참여 중인 그룹 목록 실시간 스트림

final class MyGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupModel>>,
          List<GroupModel>,
          Stream<List<GroupModel>>
        >
    with $FutureModifier<List<GroupModel>>, $StreamProvider<List<GroupModel>> {
  /// 현재 유저가 참여 중인 그룹 목록 실시간 스트림
  MyGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myGroupsHash();

  @$internal
  @override
  $StreamProviderElement<List<GroupModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupModel>> create(Ref ref) {
    return myGroups(ref);
  }
}

String _$myGroupsHash() => r'ebbe08aa62354515d0dd2c4a1574d153edac19b1';
