//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_auth_request.g.dart';

/// Payload untuk membuat akun tamu baru
///
/// Properties:
/// * [deviceId] - Pengenal unik perangkat (UUIDv4)
/// * [platform] - Platform sistem operasi perangkat (§6.3)
/// * [appVersion] - Versi aplikasi mobile saat ini
/// * [osVersion] - Versi sistem operasi perangkat
@BuiltValue()
abstract class GuestAuthRequest
    implements Built<GuestAuthRequest, GuestAuthRequestBuilder> {
  /// Pengenal unik perangkat (UUIDv4)
  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  /// Platform sistem operasi perangkat (§6.3)
  @BuiltValueField(wireName: r'platform')
  GuestAuthRequestPlatformEnum get platform;
  // enum platformEnum {  apple,  google,  android,  ios,  };

  /// Versi aplikasi mobile saat ini
  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  /// Versi sistem operasi perangkat
  @BuiltValueField(wireName: r'os_version')
  String? get osVersion;

  GuestAuthRequest._();

  factory GuestAuthRequest([void updates(GuestAuthRequestBuilder b)]) =
      _$GuestAuthRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestAuthRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestAuthRequest> get serializer =>
      _$GuestAuthRequestSerializer();
}

class _$GuestAuthRequestSerializer
    implements PrimitiveSerializer<GuestAuthRequest> {
  @override
  final Iterable<Type> types = const [GuestAuthRequest, _$GuestAuthRequest];

  @override
  final String wireName = r'GuestAuthRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestAuthRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(GuestAuthRequestPlatformEnum),
    );
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.osVersion != null) {
      yield r'os_version';
      yield serializers.serialize(
        object.osVersion,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestAuthRequest object, {
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
    required GuestAuthRequestBuilder result,
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
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GuestAuthRequestPlatformEnum),
          ) as GuestAuthRequestPlatformEnum;
          result.platform = valueDes;
          break;
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'os_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.osVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GuestAuthRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestAuthRequestBuilder();
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

/// Platform sistem operasi perangkat (§6.3)
class GuestAuthRequestPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'apple')
  static const GuestAuthRequestPlatformEnum apple =
      _$guestAuthRequestPlatformEnum_apple;
  @BuiltValueEnumConst(wireName: r'google')
  static const GuestAuthRequestPlatformEnum google =
      _$guestAuthRequestPlatformEnum_google;
  @BuiltValueEnumConst(wireName: r'android')
  static const GuestAuthRequestPlatformEnum android =
      _$guestAuthRequestPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'ios')
  static const GuestAuthRequestPlatformEnum ios =
      _$guestAuthRequestPlatformEnum_ios;

  static Serializer<GuestAuthRequestPlatformEnum> get serializer =>
      _$guestAuthRequestPlatformEnumSerializer;

  const GuestAuthRequestPlatformEnum._(String name) : super(name);

  static BuiltSet<GuestAuthRequestPlatformEnum> get values =>
      _$guestAuthRequestPlatformEnumValues;
  static GuestAuthRequestPlatformEnum valueOf(String name) =>
      _$guestAuthRequestPlatformEnumValueOf(name);
}
