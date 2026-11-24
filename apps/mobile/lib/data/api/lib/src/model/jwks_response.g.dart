// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwks_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$JwksResponse extends JwksResponse {
  @override
  final BuiltList<JsonWebKey> keys;

  factory _$JwksResponse([void Function(JwksResponseBuilder)? updates]) =>
      (JwksResponseBuilder()..update(updates))._build();

  _$JwksResponse._({required this.keys}) : super._();
  @override
  JwksResponse rebuild(void Function(JwksResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  JwksResponseBuilder toBuilder() => JwksResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is JwksResponse && keys == other.keys;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, keys.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'JwksResponse')..add('keys', keys))
        .toString();
  }
}

class JwksResponseBuilder
    implements Builder<JwksResponse, JwksResponseBuilder> {
  _$JwksResponse? _$v;

  ListBuilder<JsonWebKey>? _keys;
  ListBuilder<JsonWebKey> get keys =>
      _$this._keys ??= ListBuilder<JsonWebKey>();
  set keys(ListBuilder<JsonWebKey>? keys) => _$this._keys = keys;

  JwksResponseBuilder() {
    JwksResponse._defaults(this);
  }

  JwksResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _keys = $v.keys.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(JwksResponse other) {
    _$v = other as _$JwksResponse;
  }

  @override
  void update(void Function(JwksResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  JwksResponse build() => _build();

  _$JwksResponse _build() {
    _$JwksResponse _$result;
    try {
      _$result = _$v ??
          _$JwksResponse._(
            keys: keys.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'keys';
        keys.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'JwksResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
