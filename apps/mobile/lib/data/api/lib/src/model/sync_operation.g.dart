// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncOperation extends SyncOperation {
  @override
  final String opId;
  @override
  final SyncOpType type;
  @override
  final BuiltMap<String, JsonObject?> data;

  factory _$SyncOperation([void Function(SyncOperationBuilder)? updates]) =>
      (new SyncOperationBuilder()..update(updates))._build();

  _$SyncOperation._(
      {required this.opId, required this.type, required this.data})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(opId, r'SyncOperation', 'opId');
    BuiltValueNullFieldError.checkNotNull(type, r'SyncOperation', 'type');
    BuiltValueNullFieldError.checkNotNull(data, r'SyncOperation', 'data');
  }

  @override
  SyncOperation rebuild(void Function(SyncOperationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncOperationBuilder toBuilder() => new SyncOperationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncOperation &&
        opId == other.opId &&
        type == other.type &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, opId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncOperation')
          ..add('opId', opId)
          ..add('type', type)
          ..add('data', data))
        .toString();
  }
}

class SyncOperationBuilder
    implements Builder<SyncOperation, SyncOperationBuilder> {
  _$SyncOperation? _$v;

  String? _opId;
  String? get opId => _$this._opId;
  set opId(String? opId) => _$this._opId = opId;

  SyncOpType? _type;
  SyncOpType? get type => _$this._type;
  set type(SyncOpType? type) => _$this._type = type;

  MapBuilder<String, JsonObject?>? _data;
  MapBuilder<String, JsonObject?> get data =>
      _$this._data ??= new MapBuilder<String, JsonObject?>();
  set data(MapBuilder<String, JsonObject?>? data) => _$this._data = data;

  SyncOperationBuilder() {
    SyncOperation._defaults(this);
  }

  SyncOperationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _opId = $v.opId;
      _type = $v.type;
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncOperation other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SyncOperation;
  }

  @override
  void update(void Function(SyncOperationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncOperation build() => _build();

  _$SyncOperation _build() {
    _$SyncOperation _$result;
    try {
      _$result = _$v ??
          new _$SyncOperation._(
              opId: BuiltValueNullFieldError.checkNotNull(
                  opId, r'SyncOperation', 'opId'),
              type: BuiltValueNullFieldError.checkNotNull(
                  type, r'SyncOperation', 'type'),
              data: data.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'SyncOperation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
