// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncPushResponse extends SyncPushResponse {
  @override
  final BuiltList<SyncOpResult> results;
  @override
  final int nextCursor;
  @override
  final DateTime serverTime;

  factory _$SyncPushResponse(
          [void Function(SyncPushResponseBuilder)? updates]) =>
      (new SyncPushResponseBuilder()..update(updates))._build();

  _$SyncPushResponse._(
      {required this.results,
      required this.nextCursor,
      required this.serverTime})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        results, r'SyncPushResponse', 'results');
    BuiltValueNullFieldError.checkNotNull(
        nextCursor, r'SyncPushResponse', 'nextCursor');
    BuiltValueNullFieldError.checkNotNull(
        serverTime, r'SyncPushResponse', 'serverTime');
  }

  @override
  SyncPushResponse rebuild(void Function(SyncPushResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncPushResponseBuilder toBuilder() =>
      new SyncPushResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncPushResponse &&
        results == other.results &&
        nextCursor == other.nextCursor &&
        serverTime == other.serverTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncPushResponse')
          ..add('results', results)
          ..add('nextCursor', nextCursor)
          ..add('serverTime', serverTime))
        .toString();
  }
}

class SyncPushResponseBuilder
    implements Builder<SyncPushResponse, SyncPushResponseBuilder> {
  _$SyncPushResponse? _$v;

  ListBuilder<SyncOpResult>? _results;
  ListBuilder<SyncOpResult> get results =>
      _$this._results ??= new ListBuilder<SyncOpResult>();
  set results(ListBuilder<SyncOpResult>? results) => _$this._results = results;

  int? _nextCursor;
  int? get nextCursor => _$this._nextCursor;
  set nextCursor(int? nextCursor) => _$this._nextCursor = nextCursor;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  SyncPushResponseBuilder() {
    SyncPushResponse._defaults(this);
  }

  SyncPushResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _results = $v.results.toBuilder();
      _nextCursor = $v.nextCursor;
      _serverTime = $v.serverTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncPushResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SyncPushResponse;
  }

  @override
  void update(void Function(SyncPushResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncPushResponse build() => _build();

  _$SyncPushResponse _build() {
    _$SyncPushResponse _$result;
    try {
      _$result = _$v ??
          new _$SyncPushResponse._(
              results: results.build(),
              nextCursor: BuiltValueNullFieldError.checkNotNull(
                  nextCursor, r'SyncPushResponse', 'nextCursor'),
              serverTime: BuiltValueNullFieldError.checkNotNull(
                  serverTime, r'SyncPushResponse', 'serverTime'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'SyncPushResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
