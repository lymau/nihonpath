//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:nihonpath_api/src/model/sync_op_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_operation.g.dart';

/// Satuan operasi perubahan lokal dari outbox klien (§7.2)
///
/// Properties:
/// * [opId] - Pengenal idempoten operasi (UUIDv7)
/// * [type]
/// * [data] - Payload entitas yang dimutasi
@BuiltValue()
abstract class SyncOperation
    implements Built<SyncOperation, SyncOperationBuilder> {
  /// Pengenal idempoten operasi (UUIDv7)
  @BuiltValueField(wireName: r'op_id')
  String get opId;

  @BuiltValueField(wireName: r'type')
  SyncOpType get type;
  // enum typeEnum {  review_log,  card_state,  settings,  lesson_progress,  test_attempt,  };

  /// Payload entitas yang dimutasi
  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?> get data;

  SyncOperation._();

  factory SyncOperation([void updates(SyncOperationBuilder b)]) =
      _$SyncOperation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncOperationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncOperation> get serializer =>
      _$SyncOperationSerializer();
}

class _$SyncOperationSerializer implements PrimitiveSerializer<SyncOperation> {
  @override
  final Iterable<Type> types = const [SyncOperation, _$SyncOperation];

  @override
  final String wireName = r'SyncOperation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncOperation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'op_id';
    yield serializers.serialize(
      object.opId,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(SyncOpType),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncOperation object, {
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
    required SyncOperationBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SyncOpType),
          ) as SyncOpType;
          result.type = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncOperation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncOperationBuilder();
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
