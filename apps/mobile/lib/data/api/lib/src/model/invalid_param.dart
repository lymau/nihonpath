//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invalid_param.g.dart';

/// Rincian parameter yang tidak valid dalam RFC 9457
///
/// Properties:
/// * [name] - Nama field atau parameter
/// * [reason] - Alasan penolakan validasi
@BuiltValue()
abstract class InvalidParam
    implements Built<InvalidParam, InvalidParamBuilder> {
  /// Nama field atau parameter
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Alasan penolakan validasi
  @BuiltValueField(wireName: r'reason')
  String get reason;

  InvalidParam._();

  factory InvalidParam([void updates(InvalidParamBuilder b)]) = _$InvalidParam;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvalidParamBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvalidParam> get serializer => _$InvalidParamSerializer();
}

class _$InvalidParamSerializer implements PrimitiveSerializer<InvalidParam> {
  @override
  final Iterable<Type> types = const [InvalidParam, _$InvalidParam];

  @override
  final String wireName = r'InvalidParam';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvalidParam object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InvalidParam object, {
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
    required InvalidParamBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvalidParam deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvalidParamBuilder();
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
