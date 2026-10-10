// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_op_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncOpResult extends SyncOpResult {
  @override
  final String opId;
  @override
  final SyncOpStatus status;
  @override
  final String? code;

  factory _$SyncOpResult([void Function(SyncOpResultBuilder)? updates]) =>
      (new SyncOpResultBuilder()..update(updates))._build();

  _$SyncOpResult._({required this.opId, required this.status, this.code})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(opId, r'SyncOpResult', 'opId');
    BuiltValueNullFieldError.checkNotNull(status, r'SyncOpResult', 'status');
  }

  @override
  SyncOpResult rebuild(void Function(SyncOpResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncOpResultBuilder toBuilder() => new SyncOpResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncOpResult &&
        opId == other.opId &&
        status == other.status &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, opId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncOpResult')
          ..add('opId', opId)
          ..add('status', status)
          ..add('code', code))
        .toString();
  }
}

class SyncOpResultBuilder
    implements Builder<SyncOpResult, SyncOpResultBuilder> {
  _$SyncOpResult? _$v;

  String? _opId;
  String? get opId => _$this._opId;
  set opId(String? opId) => _$this._opId = opId;

  SyncOpStatus? _status;
  SyncOpStatus? get status => _$this._status;
  set status(SyncOpStatus? status) => _$this._status = status;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  SyncOpResultBuilder() {
    SyncOpResult._defaults(this);
  }

  SyncOpResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _opId = $v.opId;
      _status = $v.status;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncOpResult other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SyncOpResult;
  }

  @override
  void update(void Function(SyncOpResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncOpResult build() => _build();

  _$SyncOpResult _build() {
    final _$result = _$v ??
        new _$SyncOpResult._(
            opId: BuiltValueNullFieldError.checkNotNull(
                opId, r'SyncOpResult', 'opId'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'SyncOpResult', 'status'),
            code: code);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
