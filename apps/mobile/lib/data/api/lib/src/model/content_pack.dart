//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:nihonpath_api/src/model/content_pack_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'content_pack.g.dart';

/// Metadata paket konten terkompresi yang siap diunduh
///
/// Properties:
/// * [id]
/// * [jlptLevel] - Tingkat level JLPT (0 = Kana, 5 = N5, .. 1 = N1)
/// * [kind]
/// * [version] - Versi paket konten numerik incremental
/// * [sha256] - Checksum SHA-256 berkas zip untuk verifikasi integritas (§9.3)
/// * [sizeBytes] - Ukuran file paket dalam bytes
/// * [storageKey] - Lokasi penyimpanan objek pada bucket
/// * [downloadUrl] - URL unduhan langsung atau CDN bertanda tangan
/// * [minAppVersion] - Versi minimum aplikasi yang mendukung format paket ini
/// * [isPremium] - Apakah paket ini membutuhkan langganan berbayar (§8.2)
/// * [publishedAt] - Waktu paket dipublikasikan
@BuiltValue()
abstract class ContentPack implements Built<ContentPack, ContentPackBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Tingkat level JLPT (0 = Kana, 5 = N5, .. 1 = N1)
  @BuiltValueField(wireName: r'jlpt_level')
  int get jlptLevel;

  @BuiltValueField(wireName: r'kind')
  ContentPackKind get kind;
  // enum kindEnum {  core,  audio,  strokes,  passages,  tests,  };

  /// Versi paket konten numerik incremental
  @BuiltValueField(wireName: r'version')
  int get version;

  /// Checksum SHA-256 berkas zip untuk verifikasi integritas (§9.3)
  @BuiltValueField(wireName: r'sha256')
  String get sha256;

  /// Ukuran file paket dalam bytes
  @BuiltValueField(wireName: r'size_bytes')
  int get sizeBytes;

  /// Lokasi penyimpanan objek pada bucket
  @BuiltValueField(wireName: r'storage_key')
  String get storageKey;

  /// URL unduhan langsung atau CDN bertanda tangan
  @BuiltValueField(wireName: r'download_url')
  String? get downloadUrl;

  /// Versi minimum aplikasi yang mendukung format paket ini
  @BuiltValueField(wireName: r'min_app_version')
  String get minAppVersion;

  /// Apakah paket ini membutuhkan langganan berbayar (§8.2)
  @BuiltValueField(wireName: r'is_premium')
  bool get isPremium;

  /// Waktu paket dipublikasikan
  @BuiltValueField(wireName: r'published_at')
  DateTime? get publishedAt;

  ContentPack._();

  factory ContentPack([void updates(ContentPackBuilder b)]) = _$ContentPack;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContentPackBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContentPack> get serializer => _$ContentPackSerializer();
}

class _$ContentPackSerializer implements PrimitiveSerializer<ContentPack> {
  @override
  final Iterable<Type> types = const [ContentPack, _$ContentPack];

  @override
  final String wireName = r'ContentPack';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContentPack object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'jlpt_level';
    yield serializers.serialize(
      object.jlptLevel,
      specifiedType: const FullType(int),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ContentPackKind),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'sha256';
    yield serializers.serialize(
      object.sha256,
      specifiedType: const FullType(String),
    );
    yield r'size_bytes';
    yield serializers.serialize(
      object.sizeBytes,
      specifiedType: const FullType(int),
    );
    yield r'storage_key';
    yield serializers.serialize(
      object.storageKey,
      specifiedType: const FullType(String),
    );
    if (object.downloadUrl != null) {
      yield r'download_url';
      yield serializers.serialize(
        object.downloadUrl,
        specifiedType: const FullType(String),
      );
    }
    yield r'min_app_version';
    yield serializers.serialize(
      object.minAppVersion,
      specifiedType: const FullType(String),
    );
    yield r'is_premium';
    yield serializers.serialize(
      object.isPremium,
      specifiedType: const FullType(bool),
    );
    if (object.publishedAt != null) {
      yield r'published_at';
      yield serializers.serialize(
        object.publishedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ContentPack object, {
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
    required ContentPackBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'jlpt_level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.jlptLevel = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ContentPackKind),
          ) as ContentPackKind;
          result.kind = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'sha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sha256 = valueDes;
          break;
        case r'size_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sizeBytes = valueDes;
          break;
        case r'storage_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.storageKey = valueDes;
          break;
        case r'download_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.downloadUrl = valueDes;
          break;
        case r'min_app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.minAppVersion = valueDes;
          break;
        case r'is_premium':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isPremium = valueDes;
          break;
        case r'published_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.publishedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContentPack deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContentPackBuilder();
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
