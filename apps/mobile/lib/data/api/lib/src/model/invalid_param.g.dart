// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invalid_param.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InvalidParam extends InvalidParam {
  @override
  final String name;
  @override
  final String reason;

  factory _$InvalidParam([void Function(InvalidParamBuilder)? updates]) =>
      (new InvalidParamBuilder()..update(updates))._build();

  _$InvalidParam._({required this.name, required this.reason}) : super._() {
    BuiltValueNullFieldError.checkNotNull(name, r'InvalidParam', 'name');
    BuiltValueNullFieldError.checkNotNull(reason, r'InvalidParam', 'reason');
  }

  @override
  InvalidParam rebuild(void Function(InvalidParamBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InvalidParamBuilder toBuilder() => new InvalidParamBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InvalidParam &&
        name == other.name &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InvalidParam')
          ..add('name', name)
          ..add('reason', reason))
        .toString();
  }
}

class InvalidParamBuilder
    implements Builder<InvalidParam, InvalidParamBuilder> {
  _$InvalidParam? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  InvalidParamBuilder() {
    InvalidParam._defaults(this);
  }

  InvalidParamBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InvalidParam other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$InvalidParam;
  }

  @override
  void update(void Function(InvalidParamBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InvalidParam build() => _build();

  _$InvalidParam _build() {
    final _$result = _$v ??
        new _$InvalidParam._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'InvalidParam', 'name'),
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'InvalidParam', 'reason'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
