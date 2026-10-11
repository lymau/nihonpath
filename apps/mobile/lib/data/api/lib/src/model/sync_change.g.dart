// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_change.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncChange extends SyncChange {
  @override
  final int seq;
  @override
  final SyncEntityName entity;
  @override
  final BuiltMap<String, JsonObject?> data;

  factory _$SyncChange([void Function(SyncChangeBuilder)? updates]) =>
      (new SyncChangeBuilder()..update(updates))._build();

  _$SyncChange._({required this.seq, required this.entity, required this.data})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(seq, r'SyncChange', 'seq');
    BuiltValueNullFieldError.checkNotNull(entity, r'SyncChange', 'entity');
    BuiltValueNullFieldError.checkNotNull(data, r'SyncChange', 'data');
  }

  @override
  SyncChange rebuild(void Function(SyncChangeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncChangeBuilder toBuilder() => new SyncChangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncChange &&
        seq == other.seq &&
        entity == other.entity &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, entity.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncChange')
          ..add('seq', seq)
          ..add('entity', entity)
          ..add('data', data))
        .toString();
  }
}

class SyncChangeBuilder implements Builder<SyncChange, SyncChangeBuilder> {
  _$SyncChange? _$v;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  SyncEntityName? _entity;
  SyncEntityName? get entity => _$this._entity;
  set entity(SyncEntityName? entity) => _$this._entity = entity;

  MapBuilder<String, JsonObject?>? _data;
  MapBuilder<String, JsonObject?> get data =>
      _$this._data ??= new MapBuilder<String, JsonObject?>();
  set data(MapBuilder<String, JsonObject?>? data) => _$this._data = data;

  SyncChangeBuilder() {
    SyncChange._defaults(this);
  }

  SyncChangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _seq = $v.seq;
      _entity = $v.entity;
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncChange other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SyncChange;
  }

  @override
  void update(void Function(SyncChangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncChange build() => _build();

  _$SyncChange _build() {
    _$SyncChange _$result;
    try {
      _$result = _$v ??
          new _$SyncChange._(
              seq: BuiltValueNullFieldError.checkNotNull(
                  seq, r'SyncChange', 'seq'),
              entity: BuiltValueNullFieldError.checkNotNull(
                  entity, r'SyncChange', 'entity'),
              data: data.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'SyncChange', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
