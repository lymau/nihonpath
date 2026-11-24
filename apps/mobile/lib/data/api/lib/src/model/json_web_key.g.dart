// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_web_key.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$JsonWebKey extends JsonWebKey {
  @override
  final String kty;
  @override
  final String crv;
  @override
  final String x;
  @override
  final String y;
  @override
  final String use;
  @override
  final String alg;
  @override
  final String kid;
  @override
  final BuiltList<String> keyOps;

  factory _$JsonWebKey([void Function(JsonWebKeyBuilder)? updates]) =>
      (JsonWebKeyBuilder()..update(updates))._build();

  _$JsonWebKey._(
      {required this.kty,
      required this.crv,
      required this.x,
      required this.y,
      required this.use,
      required this.alg,
      required this.kid,
      required this.keyOps})
      : super._();
  @override
  JsonWebKey rebuild(void Function(JsonWebKeyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  JsonWebKeyBuilder toBuilder() => JsonWebKeyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is JsonWebKey &&
        kty == other.kty &&
        crv == other.crv &&
        x == other.x &&
        y == other.y &&
        use == other.use &&
        alg == other.alg &&
        kid == other.kid &&
        keyOps == other.keyOps;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kty.hashCode);
    _$hash = $jc(_$hash, crv.hashCode);
    _$hash = $jc(_$hash, x.hashCode);
    _$hash = $jc(_$hash, y.hashCode);
    _$hash = $jc(_$hash, use.hashCode);
    _$hash = $jc(_$hash, alg.hashCode);
    _$hash = $jc(_$hash, kid.hashCode);
    _$hash = $jc(_$hash, keyOps.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'JsonWebKey')
          ..add('kty', kty)
          ..add('crv', crv)
          ..add('x', x)
          ..add('y', y)
          ..add('use', use)
          ..add('alg', alg)
          ..add('kid', kid)
          ..add('keyOps', keyOps))
        .toString();
  }
}

class JsonWebKeyBuilder implements Builder<JsonWebKey, JsonWebKeyBuilder> {
  _$JsonWebKey? _$v;

  String? _kty;
  String? get kty => _$this._kty;
  set kty(String? kty) => _$this._kty = kty;

  String? _crv;
  String? get crv => _$this._crv;
  set crv(String? crv) => _$this._crv = crv;

  String? _x;
  String? get x => _$this._x;
  set x(String? x) => _$this._x = x;

  String? _y;
  String? get y => _$this._y;
  set y(String? y) => _$this._y = y;

  String? _use;
  String? get use => _$this._use;
  set use(String? use) => _$this._use = use;

  String? _alg;
  String? get alg => _$this._alg;
  set alg(String? alg) => _$this._alg = alg;

  String? _kid;
  String? get kid => _$this._kid;
  set kid(String? kid) => _$this._kid = kid;

  ListBuilder<String>? _keyOps;
  ListBuilder<String> get keyOps => _$this._keyOps ??= ListBuilder<String>();
  set keyOps(ListBuilder<String>? keyOps) => _$this._keyOps = keyOps;

  JsonWebKeyBuilder() {
    JsonWebKey._defaults(this);
  }

  JsonWebKeyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kty = $v.kty;
      _crv = $v.crv;
      _x = $v.x;
      _y = $v.y;
      _use = $v.use;
      _alg = $v.alg;
      _kid = $v.kid;
      _keyOps = $v.keyOps.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(JsonWebKey other) {
    _$v = other as _$JsonWebKey;
  }

  @override
  void update(void Function(JsonWebKeyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  JsonWebKey build() => _build();

  _$JsonWebKey _build() {
    _$JsonWebKey _$result;
    try {
      _$result = _$v ??
          _$JsonWebKey._(
            kty: BuiltValueNullFieldError.checkNotNull(
                kty, r'JsonWebKey', 'kty'),
            crv: BuiltValueNullFieldError.checkNotNull(
                crv, r'JsonWebKey', 'crv'),
            x: BuiltValueNullFieldError.checkNotNull(x, r'JsonWebKey', 'x'),
            y: BuiltValueNullFieldError.checkNotNull(y, r'JsonWebKey', 'y'),
            use: BuiltValueNullFieldError.checkNotNull(
                use, r'JsonWebKey', 'use'),
            alg: BuiltValueNullFieldError.checkNotNull(
                alg, r'JsonWebKey', 'alg'),
            kid: BuiltValueNullFieldError.checkNotNull(
                kid, r'JsonWebKey', 'kid'),
            keyOps: keyOps.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'keyOps';
        keyOps.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'JsonWebKey', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
