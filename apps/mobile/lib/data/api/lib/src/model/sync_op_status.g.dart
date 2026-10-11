// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_op_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SyncOpStatus _$accepted = const SyncOpStatus._('accepted');
const SyncOpStatus _$duplicate = const SyncOpStatus._('duplicate');
const SyncOpStatus _$rejected = const SyncOpStatus._('rejected');

SyncOpStatus _$valueOf(String name) {
  switch (name) {
    case 'accepted':
      return _$accepted;
    case 'duplicate':
      return _$duplicate;
    case 'rejected':
      return _$rejected;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<SyncOpStatus> _$values =
    new BuiltSet<SyncOpStatus>(const <SyncOpStatus>[
  _$accepted,
  _$duplicate,
  _$rejected,
]);

class _$SyncOpStatusMeta {
  const _$SyncOpStatusMeta();
  SyncOpStatus get accepted => _$accepted;
  SyncOpStatus get duplicate => _$duplicate;
  SyncOpStatus get rejected => _$rejected;
  SyncOpStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<SyncOpStatus> get values => _$values;
}

abstract class _$SyncOpStatusMixin {
  // ignore: non_constant_identifier_names
  _$SyncOpStatusMeta get SyncOpStatus => const _$SyncOpStatusMeta();
}

Serializer<SyncOpStatus> _$syncOpStatusSerializer =
    new _$SyncOpStatusSerializer();

class _$SyncOpStatusSerializer implements PrimitiveSerializer<SyncOpStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'accepted': 'accepted',
    'duplicate': 'duplicate',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'accepted': 'accepted',
    'duplicate': 'duplicate',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[SyncOpStatus];
  @override
  final String wireName = 'SyncOpStatus';

  @override
  Object serialize(Serializers serializers, SyncOpStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SyncOpStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SyncOpStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
