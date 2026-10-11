//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:nihonpath_api/src/model/sync_op_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_op_result.g.dart';

/// Hasil pemrosesan satu operasi sinkronisasi
///
/// Properties:
/// * [opId] - ID operasi yang diproses
/// * [status]
/// * [code] - Kode kesalahan jika berstatus rejected (misal SYNC_CLOCK_INVALID, SYNC_OP_REJECTED)
@BuiltValue()
abstract class SyncOpResult
    implements Built<SyncOpResult, SyncOpResultBuilder> {
  /// ID operasi yang diproses
  @BuiltValueField(wireName: r'op_id')
  String get opId;

  @BuiltValueField(wireName: r'status')
  SyncOpStatus get status;
  // enum statusEnum {  accepted,  duplicate,  rejected,  };

  /// Kode kesalahan jika berstatus rejected (misal SYNC_CLOCK_INVALID, SYNC_OP_REJECTED)
  @BuiltValueField(wireName: r'code')
  String? get code;

  SyncOpResult._();

  factory SyncOpResult([void updates(SyncOpResultBuilder b)]) = _$SyncOpResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncOpResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncOpResult> get serializer => _$SyncOpResultSerializer();
}

class _$SyncOpResultSerializer implements PrimitiveSerializer<SyncOpResult> {
  @override
  final Iterable<Type> types = const [SyncOpResult, _$SyncOpResult];

  @override
  final String wireName = r'SyncOpResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncOpResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'op_id';
    yield serializers.serialize(
      object.opId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(SyncOpStatus),
    );
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncOpResult object, {
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
    required SyncOpResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'op_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.opId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SyncOpStatus),
          ) as SyncOpStatus;
          result.status = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncOpResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncOpResultBuilder();
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
