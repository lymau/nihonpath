//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_entity_name.g.dart';

/// Nama entitas data sinkronisasi (§7.2)
class SyncEntityName extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cards')
  static const SyncEntityName cards = _$cards;
  @BuiltValueEnumConst(wireName: r'settings')
  static const SyncEntityName settings = _$settings;
  @BuiltValueEnumConst(wireName: r'progress')
  static const SyncEntityName progress = _$progress;
  @BuiltValueEnumConst(wireName: r'logs')
  static const SyncEntityName logs = _$logs;
  @BuiltValueEnumConst(wireName: r'tests')
  static const SyncEntityName tests = _$tests;

  static Serializer<SyncEntityName> get serializer =>
      _$syncEntityNameSerializer;

  const SyncEntityName._(String name) : super(name);

  static BuiltSet<SyncEntityName> get values => _$values;
  static SyncEntityName valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class SyncEntityNameMixin = Object with _$SyncEntityNameMixin;
