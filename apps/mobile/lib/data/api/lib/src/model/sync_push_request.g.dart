// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncPushRequest extends SyncPushRequest {
  @override
  final String deviceId;
  @override
  final BuiltList<SyncOperation> ops;

  factory _$SyncPushRequest([void Function(SyncPushRequestBuilder)? updates]) =>
      (new SyncPushRequestBuilder()..update(updates))._build();

  _$SyncPushRequest._({required this.deviceId, required this.ops}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        deviceId, r'SyncPushRequest', 'deviceId');
    BuiltValueNullFieldError.checkNotNull(ops, r'SyncPushRequest', 'ops');
  }

  @override
  SyncPushRequest rebuild(void Function(SyncPushRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncPushRequestBuilder toBuilder() =>
      new SyncPushRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncPushRequest &&
        deviceId == other.deviceId &&
        ops == other.ops;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, ops.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncPushRequest')
          ..add('deviceId', deviceId)
          ..add('ops', ops))
        .toString();
  }
}

class SyncPushRequestBuilder
    implements Builder<SyncPushRequest, SyncPushRequestBuilder> {
  _$SyncPushRequest? _$v;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  ListBuilder<SyncOperation>? _ops;
  ListBuilder<SyncOperation> get ops =>
      _$this._ops ??= new ListBuilder<SyncOperation>();
  set ops(ListBuilder<SyncOperation>? ops) => _$this._ops = ops;

  SyncPushRequestBuilder() {
    SyncPushRequest._defaults(this);
  }

  SyncPushRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceId = $v.deviceId;
      _ops = $v.ops.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncPushRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SyncPushRequest;
  }

  @override
  void update(void Function(SyncPushRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncPushRequest build() => _build();

  _$SyncPushRequest _build() {
    _$SyncPushRequest _$result;
    try {
      _$result = _$v ??
          new _$SyncPushRequest._(
              deviceId: BuiltValueNullFieldError.checkNotNull(
                  deviceId, r'SyncPushRequest', 'deviceId'),
              ops: ops.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ops';
        ops.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'SyncPushRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
