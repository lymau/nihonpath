// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_pack_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ContentPackKind _$core = const ContentPackKind._('core');
const ContentPackKind _$audio = const ContentPackKind._('audio');
const ContentPackKind _$strokes = const ContentPackKind._('strokes');
const ContentPackKind _$passages = const ContentPackKind._('passages');
const ContentPackKind _$tests = const ContentPackKind._('tests');

ContentPackKind _$valueOf(String name) {
  switch (name) {
    case 'core':
      return _$core;
    case 'audio':
      return _$audio;
    case 'strokes':
      return _$strokes;
    case 'passages':
      return _$passages;
    case 'tests':
      return _$tests;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ContentPackKind> _$values =
    new BuiltSet<ContentPackKind>(const <ContentPackKind>[
  _$core,
  _$audio,
  _$strokes,
  _$passages,
  _$tests,
]);

class _$ContentPackKindMeta {
  const _$ContentPackKindMeta();
  ContentPackKind get core => _$core;
  ContentPackKind get audio => _$audio;
  ContentPackKind get strokes => _$strokes;
  ContentPackKind get passages => _$passages;
  ContentPackKind get tests => _$tests;
  ContentPackKind valueOf(String name) => _$valueOf(name);
  BuiltSet<ContentPackKind> get values => _$values;
}

abstract class _$ContentPackKindMixin {
  // ignore: non_constant_identifier_names
  _$ContentPackKindMeta get ContentPackKind => const _$ContentPackKindMeta();
}

Serializer<ContentPackKind> _$contentPackKindSerializer =
    new _$ContentPackKindSerializer();

class _$ContentPackKindSerializer
    implements PrimitiveSerializer<ContentPackKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'core': 'core',
    'audio': 'audio',
    'strokes': 'strokes',
    'passages': 'passages',
    'tests': 'tests',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'core': 'core',
    'audio': 'audio',
    'strokes': 'strokes',
    'passages': 'passages',
    'tests': 'tests',
  };

  @override
  final Iterable<Type> types = const <Type>[ContentPackKind];
  @override
  final String wireName = 'ContentPackKind';

  @override
  Object serialize(Serializers serializers, ContentPackKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ContentPackKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ContentPackKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
