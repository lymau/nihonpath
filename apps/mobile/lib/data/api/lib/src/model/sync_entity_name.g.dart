// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_entity_name.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SyncEntityName _$cards = const SyncEntityName._('cards');
const SyncEntityName _$settings = const SyncEntityName._('settings');
const SyncEntityName _$progress = const SyncEntityName._('progress');
const SyncEntityName _$logs = const SyncEntityName._('logs');
const SyncEntityName _$tests = const SyncEntityName._('tests');

SyncEntityName _$valueOf(String name) {
  switch (name) {
    case 'cards':
      return _$cards;
    case 'settings':
      return _$settings;
    case 'progress':
      return _$progress;
    case 'logs':
      return _$logs;
    case 'tests':
      return _$tests;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<SyncEntityName> _$values =
    new BuiltSet<SyncEntityName>(const <SyncEntityName>[
  _$cards,
  _$settings,
  _$progress,
  _$logs,
  _$tests,
]);

class _$SyncEntityNameMeta {
  const _$SyncEntityNameMeta();
  SyncEntityName get cards => _$cards;
  SyncEntityName get settings => _$settings;
  SyncEntityName get progress => _$progress;
  SyncEntityName get logs => _$logs;
  SyncEntityName get tests => _$tests;
  SyncEntityName valueOf(String name) => _$valueOf(name);
  BuiltSet<SyncEntityName> get values => _$values;
}

abstract class _$SyncEntityNameMixin {
  // ignore: non_constant_identifier_names
  _$SyncEntityNameMeta get SyncEntityName => const _$SyncEntityNameMeta();
}

Serializer<SyncEntityName> _$syncEntityNameSerializer =
    new _$SyncEntityNameSerializer();

class _$SyncEntityNameSerializer
    implements PrimitiveSerializer<SyncEntityName> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cards': 'cards',
    'settings': 'settings',
    'progress': 'progress',
    'logs': 'logs',
    'tests': 'tests',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cards': 'cards',
    'settings': 'settings',
    'progress': 'progress',
    'logs': 'logs',
    'tests': 'tests',
  };

  @override
  final Iterable<Type> types = const <Type>[SyncEntityName];
  @override
  final String wireName = 'SyncEntityName';

  @override
  Object serialize(Serializers serializers, SyncEntityName object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SyncEntityName deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SyncEntityName.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
