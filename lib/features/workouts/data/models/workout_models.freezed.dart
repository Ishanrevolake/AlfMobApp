// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutPlan {

@JsonKey(name: 'client_id') String get clientId;@JsonKey(name: 'assigned_program_id') String get assignedProgramId; String get focus;@JsonKey(name: 'start_date') DateTime get startDate;@JsonKey(name: 'weekly_schedule') List<String> get weeklySchedule;@JsonKey(name: 'trainer_notes') String get trainerNotes; List<WorkoutDay> get days;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of WorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutPlanCopyWith<WorkoutPlan> get copyWith => _$WorkoutPlanCopyWithImpl<WorkoutPlan>(this as WorkoutPlan, _$identity);

  /// Serializes this WorkoutPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutPlan&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.assignedProgramId, assignedProgramId) || other.assignedProgramId == assignedProgramId)&&(identical(other.focus, focus) || other.focus == focus)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&const DeepCollectionEquality().equals(other.weeklySchedule, weeklySchedule)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,assignedProgramId,focus,startDate,const DeepCollectionEquality().hash(weeklySchedule),trainerNotes,const DeepCollectionEquality().hash(days),createdAt,updatedAt);

@override
String toString() {
  return 'WorkoutPlan(clientId: $clientId, assignedProgramId: $assignedProgramId, focus: $focus, startDate: $startDate, weeklySchedule: $weeklySchedule, trainerNotes: $trainerNotes, days: $days, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkoutPlanCopyWith<$Res>  {
  factory $WorkoutPlanCopyWith(WorkoutPlan value, $Res Function(WorkoutPlan) _then) = _$WorkoutPlanCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'client_id') String clientId,@JsonKey(name: 'assigned_program_id') String assignedProgramId, String focus,@JsonKey(name: 'start_date') DateTime startDate,@JsonKey(name: 'weekly_schedule') List<String> weeklySchedule,@JsonKey(name: 'trainer_notes') String trainerNotes, List<WorkoutDay> days,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$WorkoutPlanCopyWithImpl<$Res>
    implements $WorkoutPlanCopyWith<$Res> {
  _$WorkoutPlanCopyWithImpl(this._self, this._then);

  final WorkoutPlan _self;
  final $Res Function(WorkoutPlan) _then;

/// Create a copy of WorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? assignedProgramId = null,Object? focus = null,Object? startDate = null,Object? weeklySchedule = null,Object? trainerNotes = null,Object? days = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,assignedProgramId: null == assignedProgramId ? _self.assignedProgramId : assignedProgramId // ignore: cast_nullable_to_non_nullable
as String,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,weeklySchedule: null == weeklySchedule ? _self.weeklySchedule : weeklySchedule // ignore: cast_nullable_to_non_nullable
as List<String>,trainerNotes: null == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<WorkoutDay>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutPlan].
extension WorkoutPlanPatterns on WorkoutPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutPlan value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutPlan value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'client_id')  String clientId, @JsonKey(name: 'assigned_program_id')  String assignedProgramId,  String focus, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'weekly_schedule')  List<String> weeklySchedule, @JsonKey(name: 'trainer_notes')  String trainerNotes,  List<WorkoutDay> days, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutPlan() when $default != null:
return $default(_that.clientId,_that.assignedProgramId,_that.focus,_that.startDate,_that.weeklySchedule,_that.trainerNotes,_that.days,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'client_id')  String clientId, @JsonKey(name: 'assigned_program_id')  String assignedProgramId,  String focus, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'weekly_schedule')  List<String> weeklySchedule, @JsonKey(name: 'trainer_notes')  String trainerNotes,  List<WorkoutDay> days, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkoutPlan():
return $default(_that.clientId,_that.assignedProgramId,_that.focus,_that.startDate,_that.weeklySchedule,_that.trainerNotes,_that.days,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'client_id')  String clientId, @JsonKey(name: 'assigned_program_id')  String assignedProgramId,  String focus, @JsonKey(name: 'start_date')  DateTime startDate, @JsonKey(name: 'weekly_schedule')  List<String> weeklySchedule, @JsonKey(name: 'trainer_notes')  String trainerNotes,  List<WorkoutDay> days, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutPlan() when $default != null:
return $default(_that.clientId,_that.assignedProgramId,_that.focus,_that.startDate,_that.weeklySchedule,_that.trainerNotes,_that.days,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutPlan extends WorkoutPlan {
  const _WorkoutPlan({@JsonKey(name: 'client_id') required this.clientId, @JsonKey(name: 'assigned_program_id') required this.assignedProgramId, required this.focus, @JsonKey(name: 'start_date') required this.startDate, @JsonKey(name: 'weekly_schedule') final  List<String> weeklySchedule = const [], @JsonKey(name: 'trainer_notes') this.trainerNotes = '', final  List<WorkoutDay> days = const [], @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _weeklySchedule = weeklySchedule,_days = days,super._();
  factory _WorkoutPlan.fromJson(Map<String, dynamic> json) => _$WorkoutPlanFromJson(json);

@override@JsonKey(name: 'client_id') final  String clientId;
@override@JsonKey(name: 'assigned_program_id') final  String assignedProgramId;
@override final  String focus;
@override@JsonKey(name: 'start_date') final  DateTime startDate;
 final  List<String> _weeklySchedule;
@override@JsonKey(name: 'weekly_schedule') List<String> get weeklySchedule {
  if (_weeklySchedule is EqualUnmodifiableListView) return _weeklySchedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeklySchedule);
}

@override@JsonKey(name: 'trainer_notes') final  String trainerNotes;
 final  List<WorkoutDay> _days;
@override@JsonKey() List<WorkoutDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of WorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutPlanCopyWith<_WorkoutPlan> get copyWith => __$WorkoutPlanCopyWithImpl<_WorkoutPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutPlan&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.assignedProgramId, assignedProgramId) || other.assignedProgramId == assignedProgramId)&&(identical(other.focus, focus) || other.focus == focus)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&const DeepCollectionEquality().equals(other._weeklySchedule, _weeklySchedule)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,assignedProgramId,focus,startDate,const DeepCollectionEquality().hash(_weeklySchedule),trainerNotes,const DeepCollectionEquality().hash(_days),createdAt,updatedAt);

@override
String toString() {
  return 'WorkoutPlan(clientId: $clientId, assignedProgramId: $assignedProgramId, focus: $focus, startDate: $startDate, weeklySchedule: $weeklySchedule, trainerNotes: $trainerNotes, days: $days, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkoutPlanCopyWith<$Res> implements $WorkoutPlanCopyWith<$Res> {
  factory _$WorkoutPlanCopyWith(_WorkoutPlan value, $Res Function(_WorkoutPlan) _then) = __$WorkoutPlanCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'client_id') String clientId,@JsonKey(name: 'assigned_program_id') String assignedProgramId, String focus,@JsonKey(name: 'start_date') DateTime startDate,@JsonKey(name: 'weekly_schedule') List<String> weeklySchedule,@JsonKey(name: 'trainer_notes') String trainerNotes, List<WorkoutDay> days,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$WorkoutPlanCopyWithImpl<$Res>
    implements _$WorkoutPlanCopyWith<$Res> {
  __$WorkoutPlanCopyWithImpl(this._self, this._then);

  final _WorkoutPlan _self;
  final $Res Function(_WorkoutPlan) _then;

/// Create a copy of WorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? assignedProgramId = null,Object? focus = null,Object? startDate = null,Object? weeklySchedule = null,Object? trainerNotes = null,Object? days = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_WorkoutPlan(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,assignedProgramId: null == assignedProgramId ? _self.assignedProgramId : assignedProgramId // ignore: cast_nullable_to_non_nullable
as String,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,weeklySchedule: null == weeklySchedule ? _self._weeklySchedule : weeklySchedule // ignore: cast_nullable_to_non_nullable
as List<String>,trainerNotes: null == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<WorkoutDay>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$WorkoutDay {

 String get dayOfWeek;// 'MON', 'TUE', etc.
 String get title; String get meta; bool get rest; List<AssignedExercise> get exercises;// Keeps fields used by the web dashboard (ids and future additions) intact
// when the mobile app only changes completion state.
 Map<String, dynamic> get source;
/// Create a copy of WorkoutDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutDayCopyWith<WorkoutDay> get copyWith => _$WorkoutDayCopyWithImpl<WorkoutDay>(this as WorkoutDay, _$identity);

  /// Serializes this WorkoutDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutDay&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.title, title) || other.title == title)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.rest, rest) || other.rest == rest)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&const DeepCollectionEquality().equals(other.source, source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,title,meta,rest,const DeepCollectionEquality().hash(exercises),const DeepCollectionEquality().hash(source));

@override
String toString() {
  return 'WorkoutDay(dayOfWeek: $dayOfWeek, title: $title, meta: $meta, rest: $rest, exercises: $exercises, source: $source)';
}


}

/// @nodoc
abstract mixin class $WorkoutDayCopyWith<$Res>  {
  factory $WorkoutDayCopyWith(WorkoutDay value, $Res Function(WorkoutDay) _then) = _$WorkoutDayCopyWithImpl;
@useResult
$Res call({
 String dayOfWeek, String title, String meta, bool rest, List<AssignedExercise> exercises, Map<String, dynamic> source
});




}
/// @nodoc
class _$WorkoutDayCopyWithImpl<$Res>
    implements $WorkoutDayCopyWith<$Res> {
  _$WorkoutDayCopyWithImpl(this._self, this._then);

  final WorkoutDay _self;
  final $Res Function(WorkoutDay) _then;

/// Create a copy of WorkoutDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayOfWeek = null,Object? title = null,Object? meta = null,Object? rest = null,Object? exercises = null,Object? source = null,}) {
  return _then(_self.copyWith(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as String,rest: null == rest ? _self.rest : rest // ignore: cast_nullable_to_non_nullable
as bool,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<AssignedExercise>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutDay].
extension WorkoutDayPatterns on WorkoutDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutDay value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutDay value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dayOfWeek,  String title,  String meta,  bool rest,  List<AssignedExercise> exercises,  Map<String, dynamic> source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutDay() when $default != null:
return $default(_that.dayOfWeek,_that.title,_that.meta,_that.rest,_that.exercises,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dayOfWeek,  String title,  String meta,  bool rest,  List<AssignedExercise> exercises,  Map<String, dynamic> source)  $default,) {final _that = this;
switch (_that) {
case _WorkoutDay():
return $default(_that.dayOfWeek,_that.title,_that.meta,_that.rest,_that.exercises,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dayOfWeek,  String title,  String meta,  bool rest,  List<AssignedExercise> exercises,  Map<String, dynamic> source)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutDay() when $default != null:
return $default(_that.dayOfWeek,_that.title,_that.meta,_that.rest,_that.exercises,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutDay extends WorkoutDay {
  const _WorkoutDay({required this.dayOfWeek, required this.title, required this.meta, this.rest = false, final  List<AssignedExercise> exercises = const [], final  Map<String, dynamic> source = const {}}): _exercises = exercises,_source = source,super._();
  factory _WorkoutDay.fromJson(Map<String, dynamic> json) => _$WorkoutDayFromJson(json);

@override final  String dayOfWeek;
// 'MON', 'TUE', etc.
@override final  String title;
@override final  String meta;
@override@JsonKey() final  bool rest;
 final  List<AssignedExercise> _exercises;
@override@JsonKey() List<AssignedExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

// Keeps fields used by the web dashboard (ids and future additions) intact
// when the mobile app only changes completion state.
 final  Map<String, dynamic> _source;
// Keeps fields used by the web dashboard (ids and future additions) intact
// when the mobile app only changes completion state.
@override@JsonKey() Map<String, dynamic> get source {
  if (_source is EqualUnmodifiableMapView) return _source;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_source);
}


/// Create a copy of WorkoutDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutDayCopyWith<_WorkoutDay> get copyWith => __$WorkoutDayCopyWithImpl<_WorkoutDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutDay&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.title, title) || other.title == title)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.rest, rest) || other.rest == rest)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&const DeepCollectionEquality().equals(other._source, _source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dayOfWeek,title,meta,rest,const DeepCollectionEquality().hash(_exercises),const DeepCollectionEquality().hash(_source));

@override
String toString() {
  return 'WorkoutDay(dayOfWeek: $dayOfWeek, title: $title, meta: $meta, rest: $rest, exercises: $exercises, source: $source)';
}


}

/// @nodoc
abstract mixin class _$WorkoutDayCopyWith<$Res> implements $WorkoutDayCopyWith<$Res> {
  factory _$WorkoutDayCopyWith(_WorkoutDay value, $Res Function(_WorkoutDay) _then) = __$WorkoutDayCopyWithImpl;
@override @useResult
$Res call({
 String dayOfWeek, String title, String meta, bool rest, List<AssignedExercise> exercises, Map<String, dynamic> source
});




}
/// @nodoc
class __$WorkoutDayCopyWithImpl<$Res>
    implements _$WorkoutDayCopyWith<$Res> {
  __$WorkoutDayCopyWithImpl(this._self, this._then);

  final _WorkoutDay _self;
  final $Res Function(_WorkoutDay) _then;

/// Create a copy of WorkoutDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfWeek = null,Object? title = null,Object? meta = null,Object? rest = null,Object? exercises = null,Object? source = null,}) {
  return _then(_WorkoutDay(
dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as String,rest: null == rest ? _self.rest : rest // ignore: cast_nullable_to_non_nullable
as bool,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<AssignedExercise>,source: null == source ? _self._source : source // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$AssignedExercise {

 String get name; String get sets; String get reps; bool get done; String get cue; Map<String, dynamic> get source;
/// Create a copy of AssignedExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedExerciseCopyWith<AssignedExercise> get copyWith => _$AssignedExerciseCopyWithImpl<AssignedExercise>(this as AssignedExercise, _$identity);

  /// Serializes this AssignedExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedExercise&&(identical(other.name, name) || other.name == name)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.done, done) || other.done == done)&&(identical(other.cue, cue) || other.cue == cue)&&const DeepCollectionEquality().equals(other.source, source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,sets,reps,done,cue,const DeepCollectionEquality().hash(source));

@override
String toString() {
  return 'AssignedExercise(name: $name, sets: $sets, reps: $reps, done: $done, cue: $cue, source: $source)';
}


}

/// @nodoc
abstract mixin class $AssignedExerciseCopyWith<$Res>  {
  factory $AssignedExerciseCopyWith(AssignedExercise value, $Res Function(AssignedExercise) _then) = _$AssignedExerciseCopyWithImpl;
@useResult
$Res call({
 String name, String sets, String reps, bool done, String cue, Map<String, dynamic> source
});




}
/// @nodoc
class _$AssignedExerciseCopyWithImpl<$Res>
    implements $AssignedExerciseCopyWith<$Res> {
  _$AssignedExerciseCopyWithImpl(this._self, this._then);

  final AssignedExercise _self;
  final $Res Function(AssignedExercise) _then;

/// Create a copy of AssignedExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? sets = null,Object? reps = null,Object? done = null,Object? cue = null,Object? source = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as String,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as String,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,cue: null == cue ? _self.cue : cue // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignedExercise].
extension AssignedExercisePatterns on AssignedExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignedExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignedExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignedExercise value)  $default,){
final _that = this;
switch (_that) {
case _AssignedExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignedExercise value)?  $default,){
final _that = this;
switch (_that) {
case _AssignedExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String sets,  String reps,  bool done,  String cue,  Map<String, dynamic> source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignedExercise() when $default != null:
return $default(_that.name,_that.sets,_that.reps,_that.done,_that.cue,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String sets,  String reps,  bool done,  String cue,  Map<String, dynamic> source)  $default,) {final _that = this;
switch (_that) {
case _AssignedExercise():
return $default(_that.name,_that.sets,_that.reps,_that.done,_that.cue,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String sets,  String reps,  bool done,  String cue,  Map<String, dynamic> source)?  $default,) {final _that = this;
switch (_that) {
case _AssignedExercise() when $default != null:
return $default(_that.name,_that.sets,_that.reps,_that.done,_that.cue,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignedExercise extends AssignedExercise {
  const _AssignedExercise({required this.name, required this.sets, required this.reps, this.done = false, this.cue = '', final  Map<String, dynamic> source = const {}}): _source = source,super._();
  factory _AssignedExercise.fromJson(Map<String, dynamic> json) => _$AssignedExerciseFromJson(json);

@override final  String name;
@override final  String sets;
@override final  String reps;
@override@JsonKey() final  bool done;
@override@JsonKey() final  String cue;
 final  Map<String, dynamic> _source;
@override@JsonKey() Map<String, dynamic> get source {
  if (_source is EqualUnmodifiableMapView) return _source;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_source);
}


/// Create a copy of AssignedExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignedExerciseCopyWith<_AssignedExercise> get copyWith => __$AssignedExerciseCopyWithImpl<_AssignedExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignedExercise&&(identical(other.name, name) || other.name == name)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.done, done) || other.done == done)&&(identical(other.cue, cue) || other.cue == cue)&&const DeepCollectionEquality().equals(other._source, _source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,sets,reps,done,cue,const DeepCollectionEquality().hash(_source));

@override
String toString() {
  return 'AssignedExercise(name: $name, sets: $sets, reps: $reps, done: $done, cue: $cue, source: $source)';
}


}

/// @nodoc
abstract mixin class _$AssignedExerciseCopyWith<$Res> implements $AssignedExerciseCopyWith<$Res> {
  factory _$AssignedExerciseCopyWith(_AssignedExercise value, $Res Function(_AssignedExercise) _then) = __$AssignedExerciseCopyWithImpl;
@override @useResult
$Res call({
 String name, String sets, String reps, bool done, String cue, Map<String, dynamic> source
});




}
/// @nodoc
class __$AssignedExerciseCopyWithImpl<$Res>
    implements _$AssignedExerciseCopyWith<$Res> {
  __$AssignedExerciseCopyWithImpl(this._self, this._then);

  final _AssignedExercise _self;
  final $Res Function(_AssignedExercise) _then;

/// Create a copy of AssignedExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? sets = null,Object? reps = null,Object? done = null,Object? cue = null,Object? source = null,}) {
  return _then(_AssignedExercise(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as String,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as String,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,cue: null == cue ? _self.cue : cue // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self._source : source // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
