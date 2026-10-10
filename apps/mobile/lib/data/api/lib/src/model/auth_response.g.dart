// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthResponse extends AuthResponse {
  @override
  final String userId;
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final int expiresIn;
  @override
  final String tokenType;

  factory _$AuthResponse([void Function(AuthResponseBuilder)? updates]) =>
      (new AuthResponseBuilder()..update(updates))._build();

  _$AuthResponse._(
      {required this.userId,
      required this.accessToken,
      required this.refreshToken,
      required this.expiresIn,
      required this.tokenType})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(userId, r'AuthResponse', 'userId');
    BuiltValueNullFieldError.checkNotNull(
        accessToken, r'AuthResponse', 'accessToken');
    BuiltValueNullFieldError.checkNotNull(
        refreshToken, r'AuthResponse', 'refreshToken');
    BuiltValueNullFieldError.checkNotNull(
        expiresIn, r'AuthResponse', 'expiresIn');
    BuiltValueNullFieldError.checkNotNull(
        tokenType, r'AuthResponse', 'tokenType');
  }

  @override
  AuthResponse rebuild(void Function(AuthResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthResponseBuilder toBuilder() => new AuthResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthResponse &&
        userId == other.userId &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        expiresIn == other.expiresIn &&
        tokenType == other.tokenType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jc(_$hash, tokenType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthResponse')
          ..add('userId', userId)
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('expiresIn', expiresIn)
          ..add('tokenType', tokenType))
        .toString();
  }
}

class AuthResponseBuilder
    implements Builder<AuthResponse, AuthResponseBuilder> {
  _$AuthResponse? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  String? _tokenType;
  String? get tokenType => _$this._tokenType;
  set tokenType(String? tokenType) => _$this._tokenType = tokenType;

  AuthResponseBuilder() {
    AuthResponse._defaults(this);
  }

  AuthResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _expiresIn = $v.expiresIn;
      _tokenType = $v.tokenType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AuthResponse;
  }

  @override
  void update(void Function(AuthResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthResponse build() => _build();

  _$AuthResponse _build() {
    final _$result = _$v ??
        new _$AuthResponse._(
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'AuthResponse', 'userId'),
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'AuthResponse', 'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'AuthResponse', 'refreshToken'),
            expiresIn: BuiltValueNullFieldError.checkNotNull(
                expiresIn, r'AuthResponse', 'expiresIn'),
            tokenType: BuiltValueNullFieldError.checkNotNull(
                tokenType, r'AuthResponse', 'tokenType'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
