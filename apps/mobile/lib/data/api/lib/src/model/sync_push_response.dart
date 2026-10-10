//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:nihonpath_api/src/model/sync_op_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_push_response.g.dart';

/// Respon dari batch operasi push
///
/// Properties:
/// * [results]
/// * [nextCursor] - Cursor sequence pengguna terbaru (user_seq)
/// * [serverTime] - Timestamp server saat push diproses untuk sinkronisasi clock offset (§7.4)
@BuiltValue()
abstract class SyncPushResponse
    implements Built<SyncPushResponse, SyncPushResponseBuilder> {
  @BuiltValueField(wireName: r'results')
  BuiltList<SyncOpResult> get results;

  /// Cursor sequence pengguna terbaru (user_seq)
  @BuiltValueField(wireName: r'next_cursor')
  int get nextCursor;

  /// Timestamp server saat push diproses untuk sinkronisasi clock offset (§7.4)
  @BuiltValueField(wireName: r'server_time')
  DateTime get serverTime;

  SyncPushResponse._();

  factory SyncPushResponse([void updates(SyncPushResponseBuilder b)]) =
      _$SyncPushResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncPushResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncPushResponse> get serializer =>
      _$SyncPushResponseSerializer();
}

class _$SyncPushResponseSerializer
    implements PrimitiveSerializer<SyncPushResponse> {
  @override
  final Iterable<Type> types = const [SyncPushResponse, _$SyncPushResponse];

  @override
  final String wireName = r'SyncPushResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncPushResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltList, [FullType(SyncOpResult)]),
    );
    yield r'next_cursor';
    yield serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType(int),
    );
    yield r'server_time';
    yield serializers.serialize(
      object.serverTime,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncPushResponse object, {
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
    required SyncPushResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SyncOpResult)]),
          ) as BuiltList<SyncOpResult>;
          result.results.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.nextCursor = valueDes;
          break;
        case r'server_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncPushResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncPushResponseBuilder();
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
