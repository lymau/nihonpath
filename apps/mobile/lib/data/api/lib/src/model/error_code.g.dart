// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_code.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ErrorCode _$AUTH_INVALID_TOKEN = const ErrorCode._('AUTH_INVALID_TOKEN');
const ErrorCode _$AUTH_REFRESH_REUSED =
    const ErrorCode._('AUTH_REFRESH_REUSED');
const ErrorCode _$VALIDATION_FAILED = const ErrorCode._('VALIDATION_FAILED');
const ErrorCode _$RATE_LIMITED = const ErrorCode._('RATE_LIMITED');
const ErrorCode _$SYNC_OP_REJECTED = const ErrorCode._('SYNC_OP_REJECTED');
const ErrorCode _$SYNC_CLOCK_INVALID = const ErrorCode._('SYNC_CLOCK_INVALID');
const ErrorCode _$CONTENT_NOT_FOUND = const ErrorCode._('CONTENT_NOT_FOUND');
const ErrorCode _$ENTITLEMENT_REQUIRED =
    const ErrorCode._('ENTITLEMENT_REQUIRED');
const ErrorCode _$APP_UPDATE_REQUIRED =
    const ErrorCode._('APP_UPDATE_REQUIRED');
const ErrorCode _$INTERNAL = const ErrorCode._('INTERNAL');

ErrorCode _$valueOf(String name) {
  switch (name) {
    case 'AUTH_INVALID_TOKEN':
      return _$AUTH_INVALID_TOKEN;
    case 'AUTH_REFRESH_REUSED':
      return _$AUTH_REFRESH_REUSED;
    case 'VALIDATION_FAILED':
      return _$VALIDATION_FAILED;
    case 'RATE_LIMITED':
      return _$RATE_LIMITED;
    case 'SYNC_OP_REJECTED':
      return _$SYNC_OP_REJECTED;
    case 'SYNC_CLOCK_INVALID':
      return _$SYNC_CLOCK_INVALID;
    case 'CONTENT_NOT_FOUND':
      return _$CONTENT_NOT_FOUND;
    case 'ENTITLEMENT_REQUIRED':
      return _$ENTITLEMENT_REQUIRED;
    case 'APP_UPDATE_REQUIRED':
      return _$APP_UPDATE_REQUIRED;
    case 'INTERNAL':
      return _$INTERNAL;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ErrorCode> _$values = new BuiltSet<ErrorCode>(const <ErrorCode>[
  _$AUTH_INVALID_TOKEN,
  _$AUTH_REFRESH_REUSED,
  _$VALIDATION_FAILED,
  _$RATE_LIMITED,
  _$SYNC_OP_REJECTED,
  _$SYNC_CLOCK_INVALID,
  _$CONTENT_NOT_FOUND,
  _$ENTITLEMENT_REQUIRED,
  _$APP_UPDATE_REQUIRED,
  _$INTERNAL,
]);

class _$ErrorCodeMeta {
  const _$ErrorCodeMeta();
  ErrorCode get AUTH_INVALID_TOKEN => _$AUTH_INVALID_TOKEN;
  ErrorCode get AUTH_REFRESH_REUSED => _$AUTH_REFRESH_REUSED;
  ErrorCode get VALIDATION_FAILED => _$VALIDATION_FAILED;
  ErrorCode get RATE_LIMITED => _$RATE_LIMITED;
  ErrorCode get SYNC_OP_REJECTED => _$SYNC_OP_REJECTED;
  ErrorCode get SYNC_CLOCK_INVALID => _$SYNC_CLOCK_INVALID;
  ErrorCode get CONTENT_NOT_FOUND => _$CONTENT_NOT_FOUND;
  ErrorCode get ENTITLEMENT_REQUIRED => _$ENTITLEMENT_REQUIRED;
  ErrorCode get APP_UPDATE_REQUIRED => _$APP_UPDATE_REQUIRED;
  ErrorCode get INTERNAL => _$INTERNAL;
  ErrorCode valueOf(String name) => _$valueOf(name);
  BuiltSet<ErrorCode> get values => _$values;
}

abstract class _$ErrorCodeMixin {
  // ignore: non_constant_identifier_names
  _$ErrorCodeMeta get ErrorCode => const _$ErrorCodeMeta();
}

Serializer<ErrorCode> _$errorCodeSerializer = new _$ErrorCodeSerializer();

class _$ErrorCodeSerializer implements PrimitiveSerializer<ErrorCode> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'AUTH_INVALID_TOKEN': 'AUTH_INVALID_TOKEN',
    'AUTH_REFRESH_REUSED': 'AUTH_REFRESH_REUSED',
    'VALIDATION_FAILED': 'VALIDATION_FAILED',
    'RATE_LIMITED': 'RATE_LIMITED',
    'SYNC_OP_REJECTED': 'SYNC_OP_REJECTED',
    'SYNC_CLOCK_INVALID': 'SYNC_CLOCK_INVALID',
    'CONTENT_NOT_FOUND': 'CONTENT_NOT_FOUND',
    'ENTITLEMENT_REQUIRED': 'ENTITLEMENT_REQUIRED',
    'APP_UPDATE_REQUIRED': 'APP_UPDATE_REQUIRED',
    'INTERNAL': 'INTERNAL',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'AUTH_INVALID_TOKEN': 'AUTH_INVALID_TOKEN',
    'AUTH_REFRESH_REUSED': 'AUTH_REFRESH_REUSED',
    'VALIDATION_FAILED': 'VALIDATION_FAILED',
    'RATE_LIMITED': 'RATE_LIMITED',
    'SYNC_OP_REJECTED': 'SYNC_OP_REJECTED',
    'SYNC_CLOCK_INVALID': 'SYNC_CLOCK_INVALID',
    'CONTENT_NOT_FOUND': 'CONTENT_NOT_FOUND',
    'ENTITLEMENT_REQUIRED': 'ENTITLEMENT_REQUIRED',
    'APP_UPDATE_REQUIRED': 'APP_UPDATE_REQUIRED',
    'INTERNAL': 'INTERNAL',
  };

  @override
  final Iterable<Type> types = const <Type>[ErrorCode];
  @override
  final String wireName = 'ErrorCode';

  @override
  Object serialize(Serializers serializers, ErrorCode object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ErrorCode deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ErrorCode.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
