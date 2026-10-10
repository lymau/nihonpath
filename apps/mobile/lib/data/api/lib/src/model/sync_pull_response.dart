//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:nihonpath_api/src/model/sync_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_pull_response.g.dart';

/// Respon penarikan perubahan data terbaru
///
/// Properties:
/// * [changes]
/// * [nextCursor] - Sequence tertinggi yang ditarik
/// * [hasMore] - Bernilai true jika masih ada halaman perubahan berikutnya
/// * [serverTime] - Waktu server saat ini untuk kalkulasi clock offset
@BuiltValue()
abstract class SyncPullResponse
    implements Built<SyncPullResponse, SyncPullResponseBuilder> {
  @BuiltValueField(wireName: r'changes')
  BuiltList<SyncChange> get changes;

  /// Sequence tertinggi yang ditarik
  @BuiltValueField(wireName: r'next_cursor')
  int get nextCursor;

  /// Bernilai true jika masih ada halaman perubahan berikutnya
  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  /// Waktu server saat ini untuk kalkulasi clock offset
  @BuiltValueField(wireName: r'server_time')
  DateTime get serverTime;

  SyncPullResponse._();

  factory SyncPullResponse([void updates(SyncPullResponseBuilder b)]) =
      _$SyncPullResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncPullResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncPullResponse> get serializer =>
      _$SyncPullResponseSerializer();
}

class _$SyncPullResponseSerializer
    implements PrimitiveSerializer<SyncPullResponse> {
  @override
  final Iterable<Type> types = const [SyncPullResponse, _$SyncPullResponse];

  @override
  final String wireName = r'SyncPullResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncPullResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'changes';
    yield serializers.serialize(
      object.changes,
      specifiedType: const FullType(BuiltList, [FullType(SyncChange)]),
    );
    yield r'next_cursor';
    yield serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType(int),
    );
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
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
    SyncPullResponse object, {
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
    required SyncPullResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SyncChange)]),
          ) as BuiltList<SyncChange>;
          result.changes.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.nextCursor = valueDes;
          break;
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
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
  SyncPullResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncPullResponseBuilder();
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
