//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:nihonpath_api/src/model/error_code.dart';
import 'package:built_collection/built_collection.dart';
import 'package:nihonpath_api/src/model/invalid_param.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'problem_details.g.dart';

/// Objek detail masalah sesuai standar RFC 9457 application/problem+json dengan ekstensi code dan trace_id (§8.1)
///
/// Properties:
/// * [type] - URI referensi tipe masalah
/// * [title] - Ringkasan singkat jenis masalah
/// * [status] - Kode status HTTP
/// * [detail] - Penjelasan detail masalah yang terjadi
/// * [instance] - URI kejadian masalah spesifik
/// * [code]
/// * [traceId] - ID penelusuran terdistribusi W3C / UUID untuk korelasi log (§10.1)
/// * [invalidParams] - Daftar parameter yang gagal validasi jika ada
@BuiltValue()
abstract class ProblemDetails
    implements Built<ProblemDetails, ProblemDetailsBuilder> {
  /// URI referensi tipe masalah
  @BuiltValueField(wireName: r'type')
  String get type;

  /// Ringkasan singkat jenis masalah
  @BuiltValueField(wireName: r'title')
  String get title;

  /// Kode status HTTP
  @BuiltValueField(wireName: r'status')
  int get status;

  /// Penjelasan detail masalah yang terjadi
  @BuiltValueField(wireName: r'detail')
  String? get detail;

  /// URI kejadian masalah spesifik
  @BuiltValueField(wireName: r'instance')
  String? get instance;

  @BuiltValueField(wireName: r'code')
  ErrorCode get code;
  // enum codeEnum {  AUTH_INVALID_TOKEN,  AUTH_REFRESH_REUSED,  VALIDATION_FAILED,  RATE_LIMITED,  SYNC_OP_REJECTED,  SYNC_CLOCK_INVALID,  CONTENT_NOT_FOUND,  ENTITLEMENT_REQUIRED,  APP_UPDATE_REQUIRED,  INTERNAL,  };

  /// ID penelusuran terdistribusi W3C / UUID untuk korelasi log (§10.1)
  @BuiltValueField(wireName: r'trace_id')
  String get traceId;

  /// Daftar parameter yang gagal validasi jika ada
  @BuiltValueField(wireName: r'invalid_params')
  BuiltList<InvalidParam>? get invalidParams;

  ProblemDetails._();

  factory ProblemDetails([void updates(ProblemDetailsBuilder b)]) =
      _$ProblemDetails;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProblemDetailsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProblemDetails> get serializer =>
      _$ProblemDetailsSerializer();
}

class _$ProblemDetailsSerializer
    implements PrimitiveSerializer<ProblemDetails> {
  @override
  final Iterable<Type> types = const [ProblemDetails, _$ProblemDetails];

  @override
  final String wireName = r'ProblemDetails';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProblemDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(int),
    );
    if (object.detail != null) {
      yield r'detail';
      yield serializers.serialize(
        object.detail,
        specifiedType: const FullType(String),
      );
    }
    if (object.instance != null) {
      yield r'instance';
      yield serializers.serialize(
        object.instance,
        specifiedType: const FullType(String),
      );
    }
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ErrorCode),
    );
    yield r'trace_id';
    yield serializers.serialize(
      object.traceId,
      specifiedType: const FullType(String),
    );
    if (object.invalidParams != null) {
      yield r'invalid_params';
      yield serializers.serialize(
        object.invalidParams,
        specifiedType: const FullType(BuiltList, [FullType(InvalidParam)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProblemDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProblemDetailsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.status = valueDes;
          break;
        case r'detail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.detail = valueDes;
          break;
        case r'instance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.instance = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ErrorCode),
          ) as ErrorCode;
          result.code = valueDes;
          break;
        case r'trace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.traceId = valueDes;
          break;
        case r'invalid_params':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(InvalidParam)]),
          ) as BuiltList<InvalidParam>?;
          if (valueDes == null) continue;
          result.invalidParams.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProblemDetails deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProblemDetailsBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
