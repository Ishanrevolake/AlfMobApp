// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientMealPlan {

@JsonKey(name: 'client_id') String get clientId; String get focus;@JsonKey(name: 'start_date') DateTime get startDate;@JsonKey(name: 'trainer_notes') String get trainerNotes; List<MealPlanDay> get days;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of ClientMealPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientMealPlanCopyWith<ClientMealPlan> get copyWith => _$ClientMealPlanCopyWithImpl<ClientMealPlan>(this as ClientMealPlan, _$identity);

  /// Serializes this ClientMealPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientMealPlan&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.focus, focus) || other.focus == focus)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,focus,startDate,trainerNotes,const DeepCollectionEquality().hash(days),createdAt,updatedAt);

@override
String toString() {
  return 'ClientMealPlan(clientId: $clientId, focus: $focus, startDate: $startDate, trainerNotes: $trainerNotes, days: $days, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClientMealPlanCopyWith<$Res>  {
  factory $ClientMealPlanCopyWith(ClientMealPlan value, $Res Function(ClientMealPlan) _then) = _$ClientMealPlanCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'client_id') String clientId, String focus,@JsonKey(name: 'start_date') DateTime startDate,@JsonKey(name: 'trainer_notes') String trainerNotes, List<MealPlanDay> days,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ClientMealPlanCopyWithImpl<$Res>
    implements $ClientMealPlanCopyWith<$Res> {
  _$ClientMealPlanCopyWithImpl(this._self, this._then);

  final ClientMealPlan _self;
  final $Res Function(ClientMealPlan) _then;

/// Create a copy of ClientMealPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? focus = null,Object? startDate = null,Object? trainerNotes = null,Object? days = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,trainerNotes: null == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<MealPlanDay>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientMealPlan].
extension ClientMealPlanPatterns on ClientMealPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientMealPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientMealPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientMealPlan value)  $default,){
final _that = this;
switch (_that) {
case _ClientMealPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientMealPlan value)?  $default,){
final _that = this;
switch (_that) {
case _ClientMealPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'client_id')  String clientId,  String focus, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'trainer_notes')  String trainerNotes,  List<MealPlanDay> days, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientMealPlan() when $default != null:
return $default(_that.clientId,_that.focus,_that.startDate,_that.trainerNotes,_that.days,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'client_id')  String clientId,  String focus, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'trainer_notes')  String trainerNotes,  List<MealPlanDay> days, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ClientMealPlan():
return $default(_that.clientId,_that.focus,_that.startDate,_that.trainerNotes,_that.days,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'client_id')  String clientId,  String focus, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'trainer_notes')  String trainerNotes,  List<MealPlanDay> days, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClientMealPlan() when $default != null:
return $default(_that.clientId,_that.focus,_that.startDate,_that.trainerNotes,_that.days,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientMealPlan implements ClientMealPlan {
  const _ClientMealPlan({@JsonKey(name: 'client_id') required this.clientId, required this.focus, @JsonKey(name: 'start_date') required this.startDate, @JsonKey(name: 'trainer_notes') this.trainerNotes = '', final  List<MealPlanDay> days = const [], @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _days = days;
  factory _ClientMealPlan.fromJson(Map<String, dynamic> json) => _$ClientMealPlanFromJson(json);

@override@JsonKey(name: 'client_id') final  String clientId;
@override final  String focus;
@override@JsonKey(name: 'start_date') final  DateTime startDate;
@override@JsonKey(name: 'trainer_notes') final  String trainerNotes;
 final  List<MealPlanDay> _days;
@override@JsonKey() List<MealPlanDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of ClientMealPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientMealPlanCopyWith<_ClientMealPlan> get copyWith => __$ClientMealPlanCopyWithImpl<_ClientMealPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientMealPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientMealPlan&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.focus, focus) || other.focus == focus)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,focus,startDate,trainerNotes,const DeepCollectionEquality().hash(_days),createdAt,updatedAt);

@override
String toString() {
  return 'ClientMealPlan(clientId: $clientId, focus: $focus, startDate: $startDate, trainerNotes: $trainerNotes, days: $days, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClientMealPlanCopyWith<$Res> implements $ClientMealPlanCopyWith<$Res> {
  factory _$ClientMealPlanCopyWith(_ClientMealPlan value, $Res Function(_ClientMealPlan) _then) = __$ClientMealPlanCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'client_id') String clientId, String focus,@JsonKey(name: 'start_date') DateTime startDate,@JsonKey(name: 'trainer_notes') String trainerNotes, List<MealPlanDay> days,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ClientMealPlanCopyWithImpl<$Res>
    implements _$ClientMealPlanCopyWith<$Res> {
  __$ClientMealPlanCopyWithImpl(this._self, this._then);

  final _ClientMealPlan _self;
  final $Res Function(_ClientMealPlan) _then;

/// Create a copy of ClientMealPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? focus = null,Object? startDate = null,Object? trainerNotes = null,Object? days = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ClientMealPlan(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,trainerNotes: null == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<MealPlanDay>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MealPlanDay {

 String get dayOfWeek;// 'MON', 'TUE', etc.
 List<AssignedMeal> get meals; Map<String, dynamic> get source;
/// Create a copy of MealPlanDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealPlanDayCopyWith<MealPlanDay> get copyWith => _$MealPlanDayCopyWithImpl<MealPlanDay>(this as MealPlanDay, _$identity);

  /// Serializes this MealPlanDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealPlanDay&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&const DeepCollectionEquality().equals(other.meals, meals)&&const DeepCollectionEquality().equals(other.source, source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,const DeepCollectionEquality().hash(meals),const DeepCollectionEquality().hash(source));

@override
String toString() {
  return 'MealPlanDay(dayOfWeek: $dayOfWeek, meals: $meals, source: $source)';
}


}

/// @nodoc
abstract mixin class $MealPlanDayCopyWith<$Res>  {
  factory $MealPlanDayCopyWith(MealPlanDay value, $Res Function(MealPlanDay) _then) = _$MealPlanDayCopyWithImpl;
@useResult
$Res call({
 String dayOfWeek, List<AssignedMeal> meals, Map<String, dynamic> source
});




}
/// @nodoc
class _$MealPlanDayCopyWithImpl<$Res>
    implements $MealPlanDayCopyWith<$Res> {
  _$MealPlanDayCopyWithImpl(this._self, this._then);

  final MealPlanDay _self;
  final $Res Function(MealPlanDay) _then;

/// Create a copy of MealPlanDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayOfWeek = null,Object? meals = null,Object? source = null,}) {
  return _then(_self.copyWith(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as String,meals: null == meals ? _self.meals : meals // ignore: cast_nullable_to_non_nullable
as List<AssignedMeal>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [MealPlanDay].
extension MealPlanDayPatterns on MealPlanDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealPlanDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealPlanDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealPlanDay value)  $default,){
final _that = this;
switch (_that) {
case _MealPlanDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealPlanDay value)?  $default,){
final _that = this;
switch (_that) {
case _MealPlanDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dayOfWeek,  List<AssignedMeal> meals,  Map<String, dynamic> source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealPlanDay() when $default != null:
return $default(_that.dayOfWeek,_that.meals,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dayOfWeek,  List<AssignedMeal> meals,  Map<String, dynamic> source)  $default,) {final _that = this;
switch (_that) {
case _MealPlanDay():
return $default(_that.dayOfWeek,_that.meals,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dayOfWeek,  List<AssignedMeal> meals,  Map<String, dynamic> source)?  $default,) {final _that = this;
switch (_that) {
case _MealPlanDay() when $default != null:
return $default(_that.dayOfWeek,_that.meals,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealPlanDay implements MealPlanDay {
  const _MealPlanDay({required this.dayOfWeek, final  List<AssignedMeal> meals = const [], final  Map<String, dynamic> source = const {}}): _meals = meals,_source = source;
  factory _MealPlanDay.fromJson(Map<String, dynamic> json) => _$MealPlanDayFromJson(json);

@override final  String dayOfWeek;
// 'MON', 'TUE', etc.
 final  List<AssignedMeal> _meals;
// 'MON', 'TUE', etc.
@override@JsonKey() List<AssignedMeal> get meals {
  if (_meals is EqualUnmodifiableListView) return _meals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meals);
}

 final  Map<String, dynamic> _source;
@override@JsonKey() Map<String, dynamic> get source {
  if (_source is EqualUnmodifiableMapView) return _source;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_source);
}


/// Create a copy of MealPlanDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealPlanDayCopyWith<_MealPlanDay> get copyWith => __$MealPlanDayCopyWithImpl<_MealPlanDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealPlanDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealPlanDay&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&const DeepCollectionEquality().equals(other._meals, _meals)&&const DeepCollectionEquality().equals(other._source, _source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,const DeepCollectionEquality().hash(_meals),const DeepCollectionEquality().hash(_source));

@override
String toString() {
  return 'MealPlanDay(dayOfWeek: $dayOfWeek, meals: $meals, source: $source)';
}


}

/// @nodoc
abstract mixin class _$MealPlanDayCopyWith<$Res> implements $MealPlanDayCopyWith<$Res> {
  factory _$MealPlanDayCopyWith(_MealPlanDay value, $Res Function(_MealPlanDay) _then) = __$MealPlanDayCopyWithImpl;
@override @useResult
$Res call({
 String dayOfWeek, List<AssignedMeal> meals, Map<String, dynamic> source
});




}
/// @nodoc
class __$MealPlanDayCopyWithImpl<$Res>
    implements _$MealPlanDayCopyWith<$Res> {
  __$MealPlanDayCopyWithImpl(this._self, this._then);

  final _MealPlanDay _self;
  final $Res Function(_MealPlanDay) _then;

/// Create a copy of MealPlanDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? meals = null,Object? source = null,}) {
  return _then(_MealPlanDay(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as String,meals: null == meals ? _self._meals : meals // ignore: cast_nullable_to_non_nullable
as List<AssignedMeal>,source: null == source ? _self._source : source // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$AssignedMeal {

 int get id; String get time;// 'Breakfast', 'Lunch', etc.
 String get name; int get kcal; int get protein; bool get eaten;// Carries web-only fields such as foods, items, carbs, fat and notes so a
// mobile progress update cannot erase them.
 Map<String, dynamic> get source;
/// Create a copy of AssignedMeal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedMealCopyWith<AssignedMeal> get copyWith => _$AssignedMealCopyWithImpl<AssignedMeal>(this as AssignedMeal, _$identity);

  /// Serializes this AssignedMeal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedMeal&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.name, name) || other.name == name)&&(identical(other.kcal, kcal) || other.kcal == kcal)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.eaten, eaten) || other.eaten == eaten)&&const DeepCollectionEquality().equals(other.source, source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,time,name,kcal,protein,eaten,const DeepCollectionEquality().hash(source));

@override
String toString() {
  return 'AssignedMeal(id: $id, time: $time, name: $name, kcal: $kcal, protein: $protein, eaten: $eaten, source: $source)';
}


}

/// @nodoc
abstract mixin class $AssignedMealCopyWith<$Res>  {
  factory $AssignedMealCopyWith(AssignedMeal value, $Res Function(AssignedMeal) _then) = _$AssignedMealCopyWithImpl;
@useResult
$Res call({
 int id, String time, String name, int kcal, int protein, bool eaten, Map<String, dynamic> source
});




}
/// @nodoc
class _$AssignedMealCopyWithImpl<$Res>
    implements $AssignedMealCopyWith<$Res> {
  _$AssignedMealCopyWithImpl(this._self, this._then);

  final AssignedMeal _self;
  final $Res Function(AssignedMeal) _then;

/// Create a copy of AssignedMeal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? time = null,Object? name = null,Object? kcal = null,Object? protein = null,Object? eaten = null,Object? source = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kcal: null == kcal ? _self.kcal : kcal // ignore: cast_nullable_to_non_nullable
as int,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as int,eaten: null == eaten ? _self.eaten : eaten // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignedMeal].
extension AssignedMealPatterns on AssignedMeal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignedMeal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignedMeal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignedMeal value)  $default,){
final _that = this;
switch (_that) {
case _AssignedMeal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignedMeal value)?  $default,){
final _that = this;
switch (_that) {
case _AssignedMeal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String time,  String name,  int kcal,  int protein,  bool eaten,  Map<String, dynamic> source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignedMeal() when $default != null:
return $default(_that.id,_that.time,_that.name,_that.kcal,_that.protein,_that.eaten,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String time,  String name,  int kcal,  int protein,  bool eaten,  Map<String, dynamic> source)  $default,) {final _that = this;
switch (_that) {
case _AssignedMeal():
return $default(_that.id,_that.time,_that.name,_that.kcal,_that.protein,_that.eaten,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String time,  String name,  int kcal,  int protein,  bool eaten,  Map<String, dynamic> source)?  $default,) {final _that = this;
switch (_that) {
case _AssignedMeal() when $default != null:
return $default(_that.id,_that.time,_that.name,_that.kcal,_that.protein,_that.eaten,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignedMeal implements AssignedMeal {
  const _AssignedMeal({required this.id, required this.time, required this.name, required this.kcal, required this.protein, this.eaten = false, final  Map<String, dynamic> source = const {}}): _source = source;
  factory _AssignedMeal.fromJson(Map<String, dynamic> json) => _$AssignedMealFromJson(json);

@override final  int id;
@override final  String time;
// 'Breakfast', 'Lunch', etc.
@override final  String name;
@override final  int kcal;
@override final  int protein;
@override@JsonKey() final  bool eaten;
// Carries web-only fields such as foods, items, carbs, fat and notes so a
// mobile progress update cannot erase them.
 final  Map<String, dynamic> _source;
// Carries web-only fields such as foods, items, carbs, fat and notes so a
// mobile progress update cannot erase them.
@override@JsonKey() Map<String, dynamic> get source {
  if (_source is EqualUnmodifiableMapView) return _source;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_source);
}


/// Create a copy of AssignedMeal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignedMealCopyWith<_AssignedMeal> get copyWith => __$AssignedMealCopyWithImpl<_AssignedMeal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedMealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignedMeal&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.name, name) || other.name == name)&&(identical(other.kcal, kcal) || other.kcal == kcal)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.eaten, eaten) || other.eaten == eaten)&&const DeepCollectionEquality().equals(other._source, _source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,time,name,kcal,protein,eaten,const DeepCollectionEquality().hash(_source));

@override
String toString() {
  return 'AssignedMeal(id: $id, time: $time, name: $name, kcal: $kcal, protein: $protein, eaten: $eaten, source: $source)';
}


}

/// @nodoc
abstract mixin class _$AssignedMealCopyWith<$Res> implements $AssignedMealCopyWith<$Res> {
  factory _$AssignedMealCopyWith(_AssignedMeal value, $Res Function(_AssignedMeal) _then) = __$AssignedMealCopyWithImpl;
@override @useResult
$Res call({
 int id, String time, String name, int kcal, int protein, bool eaten, Map<String, dynamic> source
});




}
/// @nodoc
class __$AssignedMealCopyWithImpl<$Res>
    implements _$AssignedMealCopyWith<$Res> {
  __$AssignedMealCopyWithImpl(this._self, this._then);

  final _AssignedMeal _self;
  final $Res Function(_AssignedMeal) _then;

/// Create a copy of AssignedMeal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? time = null,Object? name = null,Object? kcal = null,Object? protein = null,Object? eaten = null,Object? source = null,}) {
  return _then(_AssignedMeal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kcal: null == kcal ? _self.kcal : kcal // ignore: cast_nullable_to_non_nullable
as int,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as int,eaten: null == eaten ? _self.eaten : eaten // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self._source : source // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
