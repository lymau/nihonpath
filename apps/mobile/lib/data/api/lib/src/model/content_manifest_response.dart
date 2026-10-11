//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:nihonpath_api/src/model/content_pack.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'content_manifest_response.g.dart';

/// Daftar seluruh paket konten yang tersedia
///
/// Properties:
/// * [packs]
/// * [generatedAt]
@BuiltValue()
abstract class ContentManifestResponse
    implements Built<ContentManifestResponse, ContentManifestResponseBuilder> {
  @BuiltValueField(wireName: r'packs')
  BuiltList<ContentPack> get packs;

  @BuiltValueField(wireName: r'generated_at')
  DateTime get generatedAt;

  ContentManifestResponse._();

  factory ContentManifestResponse(
          [void updates(ContentManifestResponseBuilder b)]) =
      _$ContentManifestResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContentManifestResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContentManifestResponse> get serializer =>
      _$ContentManifestResponseSerializer();
}

class _$ContentManifestResponseSerializer
    implements PrimitiveSerializer<ContentManifestResponse> {
  @override
  final Iterable<Type> types = const [
    ContentManifestResponse,
    _$ContentManifestResponse
  ];

  @override
  final String wireName = r'ContentManifestResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContentManifestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'packs';
    yield serializers.serialize(
      object.packs,
      specifiedType: const FullType(BuiltList, [FullType(ContentPack)]),
    );
    yield r'generated_at';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ContentManifestResponse object, {
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
    required ContentManifestResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'packs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ContentPack)]),
          ) as BuiltList<ContentPack>;
          result.packs.replace(valueDes);
          break;
        case r'generated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContentManifestResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContentManifestResponseBuilder();
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
