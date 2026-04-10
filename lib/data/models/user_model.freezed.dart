// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get uid; String get displayName; int get currency; List<String> get ownedItemIds; List<String> get groupIds; Map<String, String> get groupNicknames; String? get currentGroupId; DateTime? get lastCheckInDate; DateTime? get createdAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.ownedItemIds, ownedItemIds)&&const DeepCollectionEquality().equals(other.groupIds, groupIds)&&const DeepCollectionEquality().equals(other.groupNicknames, groupNicknames)&&(identical(other.currentGroupId, currentGroupId) || other.currentGroupId == currentGroupId)&&(identical(other.lastCheckInDate, lastCheckInDate) || other.lastCheckInDate == lastCheckInDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,currency,const DeepCollectionEquality().hash(ownedItemIds),const DeepCollectionEquality().hash(groupIds),const DeepCollectionEquality().hash(groupNicknames),currentGroupId,lastCheckInDate,createdAt);

@override
String toString() {
  return 'UserModel(uid: $uid, displayName: $displayName, currency: $currency, ownedItemIds: $ownedItemIds, groupIds: $groupIds, groupNicknames: $groupNicknames, currentGroupId: $currentGroupId, lastCheckInDate: $lastCheckInDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, int currency, List<String> ownedItemIds, List<String> groupIds, Map<String, String> groupNicknames, String? currentGroupId, DateTime? lastCheckInDate, DateTime? createdAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? currency = null,Object? ownedItemIds = null,Object? groupIds = null,Object? groupNicknames = null,Object? currentGroupId = freezed,Object? lastCheckInDate = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as int,ownedItemIds: null == ownedItemIds ? _self.ownedItemIds : ownedItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,groupIds: null == groupIds ? _self.groupIds : groupIds // ignore: cast_nullable_to_non_nullable
as List<String>,groupNicknames: null == groupNicknames ? _self.groupNicknames : groupNicknames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,currentGroupId: freezed == currentGroupId ? _self.currentGroupId : currentGroupId // ignore: cast_nullable_to_non_nullable
as String?,lastCheckInDate: freezed == lastCheckInDate ? _self.lastCheckInDate : lastCheckInDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  int currency,  List<String> ownedItemIds,  List<String> groupIds,  Map<String, String> groupNicknames,  String? currentGroupId,  DateTime? lastCheckInDate,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.displayName,_that.currency,_that.ownedItemIds,_that.groupIds,_that.groupNicknames,_that.currentGroupId,_that.lastCheckInDate,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  int currency,  List<String> ownedItemIds,  List<String> groupIds,  Map<String, String> groupNicknames,  String? currentGroupId,  DateTime? lastCheckInDate,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.uid,_that.displayName,_that.currency,_that.ownedItemIds,_that.groupIds,_that.groupNicknames,_that.currentGroupId,_that.lastCheckInDate,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  int currency,  List<String> ownedItemIds,  List<String> groupIds,  Map<String, String> groupNicknames,  String? currentGroupId,  DateTime? lastCheckInDate,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.displayName,_that.currency,_that.ownedItemIds,_that.groupIds,_that.groupNicknames,_that.currentGroupId,_that.lastCheckInDate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.uid, required this.displayName, this.currency = 0, final  List<String> ownedItemIds = const [], final  List<String> groupIds = const [], final  Map<String, String> groupNicknames = const {}, this.currentGroupId, this.lastCheckInDate, this.createdAt}): _ownedItemIds = ownedItemIds,_groupIds = groupIds,_groupNicknames = groupNicknames;
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String uid;
@override final  String displayName;
@override@JsonKey() final  int currency;
 final  List<String> _ownedItemIds;
@override@JsonKey() List<String> get ownedItemIds {
  if (_ownedItemIds is EqualUnmodifiableListView) return _ownedItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedItemIds);
}

 final  List<String> _groupIds;
@override@JsonKey() List<String> get groupIds {
  if (_groupIds is EqualUnmodifiableListView) return _groupIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupIds);
}

 final  Map<String, String> _groupNicknames;
@override@JsonKey() Map<String, String> get groupNicknames {
  if (_groupNicknames is EqualUnmodifiableMapView) return _groupNicknames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupNicknames);
}

@override final  String? currentGroupId;
@override final  DateTime? lastCheckInDate;
@override final  DateTime? createdAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._ownedItemIds, _ownedItemIds)&&const DeepCollectionEquality().equals(other._groupIds, _groupIds)&&const DeepCollectionEquality().equals(other._groupNicknames, _groupNicknames)&&(identical(other.currentGroupId, currentGroupId) || other.currentGroupId == currentGroupId)&&(identical(other.lastCheckInDate, lastCheckInDate) || other.lastCheckInDate == lastCheckInDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,currency,const DeepCollectionEquality().hash(_ownedItemIds),const DeepCollectionEquality().hash(_groupIds),const DeepCollectionEquality().hash(_groupNicknames),currentGroupId,lastCheckInDate,createdAt);

@override
String toString() {
  return 'UserModel(uid: $uid, displayName: $displayName, currency: $currency, ownedItemIds: $ownedItemIds, groupIds: $groupIds, groupNicknames: $groupNicknames, currentGroupId: $currentGroupId, lastCheckInDate: $lastCheckInDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, int currency, List<String> ownedItemIds, List<String> groupIds, Map<String, String> groupNicknames, String? currentGroupId, DateTime? lastCheckInDate, DateTime? createdAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? currency = null,Object? ownedItemIds = null,Object? groupIds = null,Object? groupNicknames = null,Object? currentGroupId = freezed,Object? lastCheckInDate = freezed,Object? createdAt = freezed,}) {
  return _then(_UserModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as int,ownedItemIds: null == ownedItemIds ? _self._ownedItemIds : ownedItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,groupIds: null == groupIds ? _self._groupIds : groupIds // ignore: cast_nullable_to_non_nullable
as List<String>,groupNicknames: null == groupNicknames ? _self._groupNicknames : groupNicknames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,currentGroupId: freezed == currentGroupId ? _self.currentGroupId : currentGroupId // ignore: cast_nullable_to_non_nullable
as String?,lastCheckInDate: freezed == lastCheckInDate ? _self.lastCheckInDate : lastCheckInDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
