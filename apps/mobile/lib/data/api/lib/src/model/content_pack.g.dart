// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_pack.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContentPack extends ContentPack {
  @override
  final String id;
  @override
  final int jlptLevel;
  @override
  final ContentPackKind kind;
  @override
  final int version;
  @override
  final String sha256;
  @override
  final int sizeBytes;
  @override
  final String storageKey;
  @override
  final String? downloadUrl;
  @override
  final String minAppVersion;
  @override
  final bool isPremium;
  @override
  final DateTime? publishedAt;

  factory _$ContentPack([void Function(ContentPackBuilder)? updates]) =>
      (new ContentPackBuilder()..update(updates))._build();

  _$ContentPack._(
      {required this.id,
      required this.jlptLevel,
      required this.kind,
      required this.version,
      required this.sha256,
      required this.sizeBytes,
      required this.storageKey,
      this.downloadUrl,
      required this.minAppVersion,
      required this.isPremium,
      this.publishedAt})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'ContentPack', 'id');
    BuiltValueNullFieldError.checkNotNull(
        jlptLevel, r'ContentPack', 'jlptLevel');
    BuiltValueNullFieldError.checkNotNull(kind, r'ContentPack', 'kind');
    BuiltValueNullFieldError.checkNotNull(version, r'ContentPack', 'version');
    BuiltValueNullFieldError.checkNotNull(sha256, r'ContentPack', 'sha256');
    BuiltValueNullFieldError.checkNotNull(
        sizeBytes, r'ContentPack', 'sizeBytes');
    BuiltValueNullFieldError.checkNotNull(
        storageKey, r'ContentPack', 'storageKey');
    BuiltValueNullFieldError.checkNotNull(
        minAppVersion, r'ContentPack', 'minAppVersion');
    BuiltValueNullFieldError.checkNotNull(
        isPremium, r'ContentPack', 'isPremium');
  }

  @override
  ContentPack rebuild(void Function(ContentPackBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentPackBuilder toBuilder() => new ContentPackBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContentPack &&
        id == other.id &&
        jlptLevel == other.jlptLevel &&
        kind == other.kind &&
        version == other.version &&
        sha256 == other.sha256 &&
        sizeBytes == other.sizeBytes &&
        storageKey == other.storageKey &&
        downloadUrl == other.downloadUrl &&
        minAppVersion == other.minAppVersion &&
        isPremium == other.isPremium &&
        publishedAt == other.publishedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, jlptLevel.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jc(_$hash, sizeBytes.hashCode);
    _$hash = $jc(_$hash, storageKey.hashCode);
    _$hash = $jc(_$hash, downloadUrl.hashCode);
    _$hash = $jc(_$hash, minAppVersion.hashCode);
    _$hash = $jc(_$hash, isPremium.hashCode);
    _$hash = $jc(_$hash, publishedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContentPack')
          ..add('id', id)
          ..add('jlptLevel', jlptLevel)
          ..add('kind', kind)
          ..add('version', version)
          ..add('sha256', sha256)
          ..add('sizeBytes', sizeBytes)
          ..add('storageKey', storageKey)
          ..add('downloadUrl', downloadUrl)
          ..add('minAppVersion', minAppVersion)
          ..add('isPremium', isPremium)
          ..add('publishedAt', publishedAt))
        .toString();
  }
}

class ContentPackBuilder implements Builder<ContentPack, ContentPackBuilder> {
  _$ContentPack? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _jlptLevel;
  int? get jlptLevel => _$this._jlptLevel;
  set jlptLevel(int? jlptLevel) => _$this._jlptLevel = jlptLevel;

  ContentPackKind? _kind;
  ContentPackKind? get kind => _$this._kind;
  set kind(ContentPackKind? kind) => _$this._kind = kind;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  int? _sizeBytes;
  int? get sizeBytes => _$this._sizeBytes;
  set sizeBytes(int? sizeBytes) => _$this._sizeBytes = sizeBytes;

  String? _storageKey;
  String? get storageKey => _$this._storageKey;
  set storageKey(String? storageKey) => _$this._storageKey = storageKey;

  String? _downloadUrl;
  String? get downloadUrl => _$this._downloadUrl;
  set downloadUrl(String? downloadUrl) => _$this._downloadUrl = downloadUrl;

  String? _minAppVersion;
  String? get minAppVersion => _$this._minAppVersion;
  set minAppVersion(String? minAppVersion) =>
      _$this._minAppVersion = minAppVersion;

  bool? _isPremium;
  bool? get isPremium => _$this._isPremium;
  set isPremium(bool? isPremium) => _$this._isPremium = isPremium;

  DateTime? _publishedAt;
  DateTime? get publishedAt => _$this._publishedAt;
  set publishedAt(DateTime? publishedAt) => _$this._publishedAt = publishedAt;

  ContentPackBuilder() {
    ContentPack._defaults(this);
  }

  ContentPackBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _jlptLevel = $v.jlptLevel;
      _kind = $v.kind;
      _version = $v.version;
      _sha256 = $v.sha256;
      _sizeBytes = $v.sizeBytes;
      _storageKey = $v.storageKey;
      _downloadUrl = $v.downloadUrl;
      _minAppVersion = $v.minAppVersion;
      _isPremium = $v.isPremium;
      _publishedAt = $v.publishedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContentPack other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ContentPack;
  }

  @override
  void update(void Function(ContentPackBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContentPack build() => _build();

  _$ContentPack _build() {
    final _$result = _$v ??
        new _$ContentPack._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'ContentPack', 'id'),
            jlptLevel: BuiltValueNullFieldError.checkNotNull(
                jlptLevel, r'ContentPack', 'jlptLevel'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'ContentPack', 'kind'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'ContentPack', 'version'),
            sha256: BuiltValueNullFieldError.checkNotNull(
                sha256, r'ContentPack', 'sha256'),
            sizeBytes: BuiltValueNullFieldError.checkNotNull(
                sizeBytes, r'ContentPack', 'sizeBytes'),
            storageKey: BuiltValueNullFieldError.checkNotNull(
                storageKey, r'ContentPack', 'storageKey'),
            downloadUrl: downloadUrl,
            minAppVersion: BuiltValueNullFieldError.checkNotNull(
                minAppVersion, r'ContentPack', 'minAppVersion'),
            isPremium: BuiltValueNullFieldError.checkNotNull(
                isPremium, r'ContentPack', 'isPremium'),
            publishedAt: publishedAt);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
