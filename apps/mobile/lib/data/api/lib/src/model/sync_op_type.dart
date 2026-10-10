//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_op_type.g.dart';

/// Tipe operasi entitas yang disinkronisasi (§7.2)
class SyncOpType extends EnumClass {
  @BuiltValueEnumConst(wireName: r'review_log')
  static const SyncOpType reviewLog = _$reviewLog;
  @BuiltValueEnumConst(wireName: r'card_state')
  static const SyncOpType cardState = _$cardState;
  @BuiltValueEnumConst(wireName: r'settings')
  static const SyncOpType settings = _$settings;
  @BuiltValueEnumConst(wireName: r'lesson_progress')
  static const SyncOpType lessonProgress = _$lessonProgress;
  @BuiltValueEnumConst(wireName: r'test_attempt')
  static const SyncOpType testAttempt = _$testAttempt;

  static Serializer<SyncOpType> get serializer => _$syncOpTypeSerializer;

  const SyncOpType._(String name) : super(name);

  static BuiltSet<SyncOpType> get values => _$values;
  static SyncOpType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class SyncOpTypeMixin = Object with _$SyncOpTypeMixin;
