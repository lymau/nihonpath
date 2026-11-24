//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'json_web_key.g.dart';

/// JsonWebKey
///
/// Properties:
/// * [kty]
/// * [crv]
/// * [x]
/// * [y]
/// * [use]
/// * [alg]
/// * [kid]
/// * [keyOps]
@BuiltValue()
abstract class JsonWebKey implements Built<JsonWebKey, JsonWebKeyBuilder> {
  @BuiltValueField(wireName: r'kty')
  String get kty;

  @BuiltValueField(wireName: r'crv')
  String get crv;

  @BuiltValueField(wireName: r'x')
  String get x;

  @BuiltValueField(wireName: r'y')
  String get y;

  @BuiltValueField(wireName: r'use')
  String get use;

  @BuiltValueField(wireName: r'alg')
  String get alg;

  @BuiltValueField(wireName: r'kid')
  String get kid;

  @BuiltValueField(wireName: r'key_ops')
  BuiltList<String> get keyOps;

  JsonWebKey._();

  factory JsonWebKey([void updates(JsonWebKeyBuilder b)]) = _$JsonWebKey;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(JsonWebKeyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<JsonWebKey> get serializer => _$JsonWebKeySerializer();
}

class _$JsonWebKeySerializer implements PrimitiveSerializer<JsonWebKey> {
  @override
  final Iterable<Type> types = const [JsonWebKey, _$JsonWebKey];

  @override
  final String wireName = r'JsonWebKey';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    JsonWebKey object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kty';
    yield serializers.serialize(
      object.kty,
      specifiedType: const FullType(String),
    );
    yield r'crv';
    yield serializers.serialize(
      object.crv,
      specifiedType: const FullType(String),
    );
    yield r'x';
    yield serializers.serialize(
      object.x,
      specifiedType: const FullType(String),
    );
    yield r'y';
    yield serializers.serialize(
      object.y,
      specifiedType: const FullType(String),
    );
    yield r'use';
    yield serializers.serialize(
      object.use,
      specifiedType: const FullType(String),
    );
    yield r'alg';
    yield serializers.serialize(
      object.alg,
      specifiedType: const FullType(String),
    );
    yield r'kid';
    yield serializers.serialize(
      object.kid,
      specifiedType: const FullType(String),
    );
    yield r'key_ops';
    yield serializers.serialize(
      object.keyOps,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    JsonWebKey object, {
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
    required JsonWebKeyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kty = valueDes;
          break;
        case r'crv':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.crv = valueDes;
          break;
        case r'x':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.x = valueDes;
          break;
        case r'y':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.y = valueDes;
          break;
        case r'use':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.use = valueDes;
          break;
        case r'alg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.alg = valueDes;
          break;
        case r'kid':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kid = valueDes;
          break;
        case r'key_ops':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.keyOps.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  JsonWebKey deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = JsonWebKeyBuilder();
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
