//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_code.g.dart';

/// Kode error standar aplikasi (§8.4) untuk pemetaan pesan lokal di sisi klien
class ErrorCode extends EnumClass {
  @BuiltValueEnumConst(wireName: r'AUTH_INVALID_TOKEN')
  static const ErrorCode AUTH_INVALID_TOKEN = _$AUTH_INVALID_TOKEN;
  @BuiltValueEnumConst(wireName: r'AUTH_REFRESH_REUSED')
  static const ErrorCode AUTH_REFRESH_REUSED = _$AUTH_REFRESH_REUSED;
  @BuiltValueEnumConst(wireName: r'VALIDATION_FAILED')
  static const ErrorCode VALIDATION_FAILED = _$VALIDATION_FAILED;
  @BuiltValueEnumConst(wireName: r'RATE_LIMITED')
  static const ErrorCode RATE_LIMITED = _$RATE_LIMITED;
  @BuiltValueEnumConst(wireName: r'SYNC_OP_REJECTED')
  static const ErrorCode SYNC_OP_REJECTED = _$SYNC_OP_REJECTED;
  @BuiltValueEnumConst(wireName: r'SYNC_CLOCK_INVALID')
  static const ErrorCode SYNC_CLOCK_INVALID = _$SYNC_CLOCK_INVALID;
  @BuiltValueEnumConst(wireName: r'CONTENT_NOT_FOUND')
  static const ErrorCode CONTENT_NOT_FOUND = _$CONTENT_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'ENTITLEMENT_REQUIRED')
  static const ErrorCode ENTITLEMENT_REQUIRED = _$ENTITLEMENT_REQUIRED;
  @BuiltValueEnumConst(wireName: r'APP_UPDATE_REQUIRED')
  static const ErrorCode APP_UPDATE_REQUIRED = _$APP_UPDATE_REQUIRED;
  @BuiltValueEnumConst(wireName: r'INTERNAL')
  static const ErrorCode INTERNAL = _$INTERNAL;

  static Serializer<ErrorCode> get serializer => _$errorCodeSerializer;

  const ErrorCode._(String name) : super(name);

  static BuiltSet<ErrorCode> get values => _$values;
  static ErrorCode valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ErrorCodeMixin = Object with _$ErrorCodeMixin;
