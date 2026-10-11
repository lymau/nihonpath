// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppConfigResponse extends AppConfigResponse {
  @override
  final String minAppVersion;
  @override
  final String latestAppVersion;
  @override
  final bool maintenance;
  @override
  final BuiltMap<String, bool> features;
  @override
  final BuiltMap<String, JsonObject?>? remoteParams;

  factory _$AppConfigResponse(
          [void Function(AppConfigResponseBuilder)? updates]) =>
      (new AppConfigResponseBuilder()..update(updates))._build();

  _$AppConfigResponse._(
      {required this.minAppVersion,
      required this.latestAppVersion,
      required this.maintenance,
      required this.features,
      this.remoteParams})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        minAppVersion, r'AppConfigResponse', 'minAppVersion');
    BuiltValueNullFieldError.checkNotNull(
        latestAppVersion, r'AppConfigResponse', 'latestAppVersion');
    BuiltValueNullFieldError.checkNotNull(
        maintenance, r'AppConfigResponse', 'maintenance');
    BuiltValueNullFieldError.checkNotNull(
        features, r'AppConfigResponse', 'features');
  }

  @override
  AppConfigResponse rebuild(void Function(AppConfigResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppConfigResponseBuilder toBuilder() =>
      new AppConfigResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppConfigResponse &&
        minAppVersion == other.minAppVersion &&
        latestAppVersion == other.latestAppVersion &&
        maintenance == other.maintenance &&
        features == other.features &&
        remoteParams == other.remoteParams;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minAppVersion.hashCode);
    _$hash = $jc(_$hash, latestAppVersion.hashCode);
    _$hash = $jc(_$hash, maintenance.hashCode);
    _$hash = $jc(_$hash, features.hashCode);
    _$hash = $jc(_$hash, remoteParams.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppConfigResponse')
          ..add('minAppVersion', minAppVersion)
          ..add('latestAppVersion', latestAppVersion)
          ..add('maintenance', maintenance)
          ..add('features', features)
          ..add('remoteParams', remoteParams))
        .toString();
  }
}

class AppConfigResponseBuilder
    implements Builder<AppConfigResponse, AppConfigResponseBuilder> {
  _$AppConfigResponse? _$v;

  String? _minAppVersion;
  String? get minAppVersion => _$this._minAppVersion;
  set minAppVersion(String? minAppVersion) =>
      _$this._minAppVersion = minAppVersion;

  String? _latestAppVersion;
  String? get latestAppVersion => _$this._latestAppVersion;
  set latestAppVersion(String? latestAppVersion) =>
      _$this._latestAppVersion = latestAppVersion;

  bool? _maintenance;
  bool? get maintenance => _$this._maintenance;
  set maintenance(bool? maintenance) => _$this._maintenance = maintenance;

  MapBuilder<String, bool>? _features;
  MapBuilder<String, bool> get features =>
      _$this._features ??= new MapBuilder<String, bool>();
  set features(MapBuilder<String, bool>? features) =>
      _$this._features = features;

  MapBuilder<String, JsonObject?>? _remoteParams;
  MapBuilder<String, JsonObject?> get remoteParams =>
      _$this._remoteParams ??= new MapBuilder<String, JsonObject?>();
  set remoteParams(MapBuilder<String, JsonObject?>? remoteParams) =>
      _$this._remoteParams = remoteParams;

  AppConfigResponseBuilder() {
    AppConfigResponse._defaults(this);
  }

  AppConfigResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minAppVersion = $v.minAppVersion;
      _latestAppVersion = $v.latestAppVersion;
      _maintenance = $v.maintenance;
      _features = $v.features.toBuilder();
      _remoteParams = $v.remoteParams?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppConfigResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AppConfigResponse;
  }

  @override
  void update(void Function(AppConfigResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppConfigResponse build() => _build();

  _$AppConfigResponse _build() {
    _$AppConfigResponse _$result;
    try {
      _$result = _$v ??
          new _$AppConfigResponse._(
              minAppVersion: BuiltValueNullFieldError.checkNotNull(
                  minAppVersion, r'AppConfigResponse', 'minAppVersion'),
              latestAppVersion: BuiltValueNullFieldError.checkNotNull(
                  latestAppVersion, r'AppConfigResponse', 'latestAppVersion'),
              maintenance: BuiltValueNullFieldError.checkNotNull(
                  maintenance, r'AppConfigResponse', 'maintenance'),
              features: features.build(),
              remoteParams: _remoteParams?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        features.build();
        _$failedField = 'remoteParams';
        _remoteParams?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'AppConfigResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
