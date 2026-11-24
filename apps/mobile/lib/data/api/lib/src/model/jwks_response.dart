//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:nihonpath_api/src/model/json_web_key.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'jwks_response.g.dart';

/// JwksResponse
///
/// Properties:
/// * [keys]
@BuiltValue()
abstract class JwksResponse
    implements Built<JwksResponse, JwksResponseBuilder> {
  @BuiltValueField(wireName: r'keys')
  BuiltList<JsonWebKey> get keys;

  JwksResponse._();

  factory JwksResponse([void updates(JwksResponseBuilder b)]) = _$JwksResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(JwksResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<JwksResponse> get serializer => _$JwksResponseSerializer();
}

class _$JwksResponseSerializer implements PrimitiveSerializer<JwksResponse> {
  @override
  final Iterable<Type> types = const [JwksResponse, _$JwksResponse];

  @override
  final String wireName = r'JwksResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    JwksResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'keys';
    yield serializers.serialize(
      object.keys,
      specifiedType: const FullType(BuiltList, [FullType(JsonWebKey)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    JwksResponse object, {
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
    required JwksResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'keys':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(JsonWebKey)]),
          ) as BuiltList<JsonWebKey>;
          result.keys.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  JwksResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = JwksResponseBuilder();
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
