// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_pull_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncPullResponse extends SyncPullResponse {
  @override
  final BuiltList<SyncChange> changes;
  @override
  final int nextCursor;
  @override
  final bool hasMore;
  @override
  final DateTime serverTime;

  factory _$SyncPullResponse(
          [void Function(SyncPullResponseBuilder)? updates]) =>
      (new SyncPullResponseBuilder()..update(updates))._build();

  _$SyncPullResponse._(
      {required this.changes,
      required this.nextCursor,
      required this.hasMore,
      required this.serverTime})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        changes, r'SyncPullResponse', 'changes');
    BuiltValueNullFieldError.checkNotNull(
        nextCursor, r'SyncPullResponse', 'nextCursor');
    BuiltValueNullFieldError.checkNotNull(
        hasMore, r'SyncPullResponse', 'hasMore');
    BuiltValueNullFieldError.checkNotNull(
        serverTime, r'SyncPullResponse', 'serverTime');
  }

  @override
  SyncPullResponse rebuild(void Function(SyncPullResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncPullResponseBuilder toBuilder() =>
      new SyncPullResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncPullResponse &&
        changes == other.changes &&
        nextCursor == other.nextCursor &&
        hasMore == other.hasMore &&
        serverTime == other.serverTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, changes.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncPullResponse')
          ..add('changes', changes)
          ..add('nextCursor', nextCursor)
          ..add('hasMore', hasMore)
          ..add('serverTime', serverTime))
        .toString();
  }
}

class SyncPullResponseBuilder
    implements Builder<SyncPullResponse, SyncPullResponseBuilder> {
  _$SyncPullResponse? _$v;

  ListBuilder<SyncChange>? _changes;
  ListBuilder<SyncChange> get changes =>
      _$this._changes ??= new ListBuilder<SyncChange>();
  set changes(ListBuilder<SyncChange>? changes) => _$this._changes = changes;

  int? _nextCursor;
  int? get nextCursor => _$this._nextCursor;
  set nextCursor(int? nextCursor) => _$this._nextCursor = nextCursor;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  SyncPullResponseBuilder() {
    SyncPullResponse._defaults(this);
  }

  SyncPullResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _changes = $v.changes.toBuilder();
      _nextCursor = $v.nextCursor;
      _hasMore = $v.hasMore;
      _serverTime = $v.serverTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncPullResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SyncPullResponse;
  }

  @override
  void update(void Function(SyncPullResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncPullResponse build() => _build();

  _$SyncPullResponse _build() {
    _$SyncPullResponse _$result;
    try {
      _$result = _$v ??
          new _$SyncPullResponse._(
              changes: changes.build(),
              nextCursor: BuiltValueNullFieldError.checkNotNull(
                  nextCursor, r'SyncPullResponse', 'nextCursor'),
              hasMore: BuiltValueNullFieldError.checkNotNull(
                  hasMore, r'SyncPullResponse', 'hasMore'),
              serverTime: BuiltValueNullFieldError.checkNotNull(
                  serverTime, r'SyncPullResponse', 'serverTime'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'changes';
        changes.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'SyncPullResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
