//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:nihonpath_api/src/model/sync_operation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_push_request.g.dart';

/// Permintaan sinkronisasi batch mutasi lokal (§7.2)
///
/// Properties:
/// * [deviceId] - ID perangkat pemancar transaksi outbox
/// * [ops] - Daftar operasi mutasi (maksimum 200 op)
@BuiltValue()
abstract class SyncPushRequest
    implements Built<SyncPushRequest, SyncPushRequestBuilder> {
  /// ID perangkat pemancar transaksi outbox
  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  /// Daftar operasi mutasi (maksimum 200 op)
  @BuiltValueField(wireName: r'ops')
  BuiltList<SyncOperation> get ops;

  SyncPushRequest._();

  factory SyncPushRequest([void updates(SyncPushRequestBuilder b)]) =
      _$SyncPushRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncPushRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncPushRequest> get serializer =>
      _$SyncPushRequestSerializer();
}

class _$SyncPushRequestSerializer
    implements PrimitiveSerializer<SyncPushRequest> {
  @override
  final Iterable<Type> types = const [SyncPushRequest, _$SyncPushRequest];

  @override
  final String wireName = r'SyncPushRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncPushRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'ops';
    yield serializers.serialize(
      object.ops,
      specifiedType: const FullType(BuiltList, [FullType(SyncOperation)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncPushRequest object, {
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
    required SyncPushRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'ops':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SyncOperation)]),
          ) as BuiltList<SyncOperation>;
          result.ops.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncPushRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncPushRequestBuilder();
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
