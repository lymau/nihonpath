// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_auth_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GuestAuthRequestPlatformEnum _$guestAuthRequestPlatformEnum_apple =
    const GuestAuthRequestPlatformEnum._('apple');
const GuestAuthRequestPlatformEnum _$guestAuthRequestPlatformEnum_google =
    const GuestAuthRequestPlatformEnum._('google');
const GuestAuthRequestPlatformEnum _$guestAuthRequestPlatformEnum_android =
    const GuestAuthRequestPlatformEnum._('android');
const GuestAuthRequestPlatformEnum _$guestAuthRequestPlatformEnum_ios =
    const GuestAuthRequestPlatformEnum._('ios');

GuestAuthRequestPlatformEnum _$guestAuthRequestPlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'apple':
      return _$guestAuthRequestPlatformEnum_apple;
    case 'google':
      return _$guestAuthRequestPlatformEnum_google;
    case 'android':
      return _$guestAuthRequestPlatformEnum_android;
    case 'ios':
      return _$guestAuthRequestPlatformEnum_ios;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GuestAuthRequestPlatformEnum>
    _$guestAuthRequestPlatformEnumValues = new BuiltSet<
        GuestAuthRequestPlatformEnum>(const <GuestAuthRequestPlatformEnum>[
  _$guestAuthRequestPlatformEnum_apple,
  _$guestAuthRequestPlatformEnum_google,
  _$guestAuthRequestPlatformEnum_android,
  _$guestAuthRequestPlatformEnum_ios,
]);

Serializer<GuestAuthRequestPlatformEnum>
    _$guestAuthRequestPlatformEnumSerializer =
    new _$GuestAuthRequestPlatformEnumSerializer();

class _$GuestAuthRequestPlatformEnumSerializer
    implements PrimitiveSerializer<GuestAuthRequestPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'apple': 'apple',
    'google': 'google',
    'android': 'android',
    'ios': 'ios',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'apple': 'apple',
    'google': 'google',
    'android': 'android',
    'ios': 'ios',
  };

  @override
  final Iterable<Type> types = const <Type>[GuestAuthRequestPlatformEnum];
  @override
  final String wireName = 'GuestAuthRequestPlatformEnum';

  @override
  Object serialize(Serializers serializers, GuestAuthRequestPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GuestAuthRequestPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GuestAuthRequestPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GuestAuthRequest extends GuestAuthRequest {
  @override
  final String deviceId;
  @override
  final GuestAuthRequestPlatformEnum platform;
  @override
  final String? appVersion;
  @override
  final String? osVersion;

  factory _$GuestAuthRequest(
          [void Function(GuestAuthRequestBuilder)? updates]) =>
      (new GuestAuthRequestBuilder()..update(updates))._build();

  _$GuestAuthRequest._(
      {required this.deviceId,
      required this.platform,
      this.appVersion,
      this.osVersion})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        deviceId, r'GuestAuthRequest', 'deviceId');
    BuiltValueNullFieldError.checkNotNull(
        platform, r'GuestAuthRequest', 'platform');
  }

  @override
  GuestAuthRequest rebuild(void Function(GuestAuthRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestAuthRequestBuilder toBuilder() =>
      new GuestAuthRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestAuthRequest &&
        deviceId == other.deviceId &&
        platform == other.platform &&
        appVersion == other.appVersion &&
        osVersion == other.osVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, osVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GuestAuthRequest')
          ..add('deviceId', deviceId)
          ..add('platform', platform)
          ..add('appVersion', appVersion)
          ..add('osVersion', osVersion))
        .toString();
  }
}

class GuestAuthRequestBuilder
    implements Builder<GuestAuthRequest, GuestAuthRequestBuilder> {
  _$GuestAuthRequest? _$v;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  GuestAuthRequestPlatformEnum? _platform;
  GuestAuthRequestPlatformEnum? get platform => _$this._platform;
  set platform(GuestAuthRequestPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _osVersion;
  String? get osVersion => _$this._osVersion;
  set osVersion(String? osVersion) => _$this._osVersion = osVersion;

  GuestAuthRequestBuilder() {
    GuestAuthRequest._defaults(this);
  }

  GuestAuthRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceId = $v.deviceId;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _osVersion = $v.osVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestAuthRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GuestAuthRequest;
  }

  @override
  void update(void Function(GuestAuthRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestAuthRequest build() => _build();

  _$GuestAuthRequest _build() {
    final _$result = _$v ??
        new _$GuestAuthRequest._(
            deviceId: BuiltValueNullFieldError.checkNotNull(
                deviceId, r'GuestAuthRequest', 'deviceId'),
            platform: BuiltValueNullFieldError.checkNotNull(
                platform, r'GuestAuthRequest', 'platform'),
            appVersion: appVersion,
            osVersion: osVersion);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
