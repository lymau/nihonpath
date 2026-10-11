// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_op_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SyncOpType _$reviewLog = const SyncOpType._('reviewLog');
const SyncOpType _$cardState = const SyncOpType._('cardState');
const SyncOpType _$settings = const SyncOpType._('settings');
const SyncOpType _$lessonProgress = const SyncOpType._('lessonProgress');
const SyncOpType _$testAttempt = const SyncOpType._('testAttempt');

SyncOpType _$valueOf(String name) {
  switch (name) {
    case 'reviewLog':
      return _$reviewLog;
    case 'cardState':
      return _$cardState;
    case 'settings':
      return _$settings;
    case 'lessonProgress':
      return _$lessonProgress;
    case 'testAttempt':
      return _$testAttempt;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<SyncOpType> _$values =
    new BuiltSet<SyncOpType>(const <SyncOpType>[
  _$reviewLog,
  _$cardState,
  _$settings,
  _$lessonProgress,
  _$testAttempt,
]);

class _$SyncOpTypeMeta {
  const _$SyncOpTypeMeta();
  SyncOpType get reviewLog => _$reviewLog;
  SyncOpType get cardState => _$cardState;
  SyncOpType get settings => _$settings;
  SyncOpType get lessonProgress => _$lessonProgress;
  SyncOpType get testAttempt => _$testAttempt;
  SyncOpType valueOf(String name) => _$valueOf(name);
  BuiltSet<SyncOpType> get values => _$values;
}

abstract class _$SyncOpTypeMixin {
  // ignore: non_constant_identifier_names
  _$SyncOpTypeMeta get SyncOpType => const _$SyncOpTypeMeta();
}

Serializer<SyncOpType> _$syncOpTypeSerializer = new _$SyncOpTypeSerializer();

class _$SyncOpTypeSerializer implements PrimitiveSerializer<SyncOpType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'reviewLog': 'review_log',
    'cardState': 'card_state',
    'settings': 'settings',
    'lessonProgress': 'lesson_progress',
    'testAttempt': 'test_attempt',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'review_log': 'reviewLog',
    'card_state': 'cardState',
    'settings': 'settings',
    'lesson_progress': 'lessonProgress',
    'test_attempt': 'testAttempt',
  };

  @override
  final Iterable<Type> types = const <Type>[SyncOpType];
  @override
  final String wireName = 'SyncOpType';

  @override
  Object serialize(Serializers serializers, SyncOpType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SyncOpType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SyncOpType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
