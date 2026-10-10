//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'app_config_response.g.dart';

/// Konfigurasi sistem dan parameter dinamis
///
/// Properties:
/// * [minAppVersion] - Versi minimum aplikasi yang diperbolehkan berjalan (§8.1)
/// * [latestAppVersion] - Versi aplikasi terbaru yang tersedia di store
/// * [maintenance] - Status pemeliharaan sistem
/// * [features] - Feature flag boolean aktif untuk klien
/// * [remoteParams] - Parameter jarak jauh untuk konfigurasi algoritma seperti FSRS
@BuiltValue()
abstract class AppConfigResponse
    implements Built<AppConfigResponse, AppConfigResponseBuilder> {
  /// Versi minimum aplikasi yang diperbolehkan berjalan (§8.1)
  @BuiltValueField(wireName: r'min_app_version')
  String get minAppVersion;

  /// Versi aplikasi terbaru yang tersedia di store
  @BuiltValueField(wireName: r'latest_app_version')
  String get latestAppVersion;

  /// Status pemeliharaan sistem
  @BuiltValueField(wireName: r'maintenance')
  bool get maintenance;

  /// Feature flag boolean aktif untuk klien
  @BuiltValueField(wireName: r'features')
  BuiltMap<String, bool> get features;

  /// Parameter jarak jauh untuk konfigurasi algoritma seperti FSRS
  @BuiltValueField(wireName: r'remote_params')
  BuiltMap<String, JsonObject?>? get remoteParams;

  AppConfigResponse._();

  factory AppConfigResponse([void updates(AppConfigResponseBuilder b)]) =
      _$AppConfigResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppConfigResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppConfigResponse> get serializer =>
      _$AppConfigResponseSerializer();
}

class _$AppConfigResponseSerializer
    implements PrimitiveSerializer<AppConfigResponse> {
  @override
  final Iterable<Type> types = const [AppConfigResponse, _$AppConfigResponse];

  @override
  final String wireName = r'AppConfigResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppConfigResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'min_app_version';
    yield serializers.serialize(
      object.minAppVersion,
      specifiedType: const FullType(String),
    );
    yield r'latest_app_version';
    yield serializers.serialize(
      object.latestAppVersion,
      specifiedType: const FullType(String),
    );
    yield r'maintenance';
    yield serializers.serialize(
      object.maintenance,
      specifiedType: const FullType(bool),
    );
    yield r'features';
    yield serializers.serialize(
      object.features,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(bool)]),
    );
    if (object.remoteParams != null) {
      yield r'remote_params';
      yield serializers.serialize(
        object.remoteParams,
        specifiedType: const FullType(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AppConfigResponse object, {
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
    required AppConfigResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'min_app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.minAppVersion = valueDes;
          break;
        case r'latest_app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.latestAppVersion = valueDes;
          break;
        case r'maintenance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.maintenance = valueDes;
          break;
        case r'features':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(bool)]),
          ) as BuiltMap<String, bool>;
          result.features.replace(valueDes);
          break;
        case r'remote_params':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.remoteParams.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppConfigResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppConfigResponseBuilder();
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
