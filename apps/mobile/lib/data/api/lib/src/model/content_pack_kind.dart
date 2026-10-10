//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'content_pack_kind.g.dart';

/// Jenis paket konten (§9.3, §6.3)
class ContentPackKind extends EnumClass {
  @BuiltValueEnumConst(wireName: r'core')
  static const ContentPackKind core = _$core;
  @BuiltValueEnumConst(wireName: r'audio')
  static const ContentPackKind audio = _$audio;
  @BuiltValueEnumConst(wireName: r'strokes')
  static const ContentPackKind strokes = _$strokes;
  @BuiltValueEnumConst(wireName: r'passages')
  static const ContentPackKind passages = _$passages;
  @BuiltValueEnumConst(wireName: r'tests')
  static const ContentPackKind tests = _$tests;

  static Serializer<ContentPackKind> get serializer =>
      _$contentPackKindSerializer;

  const ContentPackKind._(String name) : super(name);

  static BuiltSet<ContentPackKind> get values => _$values;
  static ContentPackKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ContentPackKindMixin = Object with _$ContentPackKindMixin;
