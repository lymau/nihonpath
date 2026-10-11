// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_details.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProblemDetails extends ProblemDetails {
  @override
  final String type;
  @override
  final String title;
  @override
  final int status;
  @override
  final String? detail;
  @override
  final String? instance;
  @override
  final ErrorCode code;
  @override
  final String traceId;
  @override
  final BuiltList<InvalidParam>? invalidParams;

  factory _$ProblemDetails([void Function(ProblemDetailsBuilder)? updates]) =>
      (new ProblemDetailsBuilder()..update(updates))._build();

  _$ProblemDetails._(
      {required this.type,
      required this.title,
      required this.status,
      this.detail,
      this.instance,
      required this.code,
      required this.traceId,
      this.invalidParams})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(type, r'ProblemDetails', 'type');
    BuiltValueNullFieldError.checkNotNull(title, r'ProblemDetails', 'title');
    BuiltValueNullFieldError.checkNotNull(status, r'ProblemDetails', 'status');
    BuiltValueNullFieldError.checkNotNull(code, r'ProblemDetails', 'code');
    BuiltValueNullFieldError.checkNotNull(
        traceId, r'ProblemDetails', 'traceId');
  }

  @override
  ProblemDetails rebuild(void Function(ProblemDetailsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProblemDetailsBuilder toBuilder() =>
      new ProblemDetailsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProblemDetails &&
        type == other.type &&
        title == other.title &&
        status == other.status &&
        detail == other.detail &&
        instance == other.instance &&
        code == other.code &&
        traceId == other.traceId &&
        invalidParams == other.invalidParams;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, detail.hashCode);
    _$hash = $jc(_$hash, instance.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, traceId.hashCode);
    _$hash = $jc(_$hash, invalidParams.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProblemDetails')
          ..add('type', type)
          ..add('title', title)
          ..add('status', status)
          ..add('detail', detail)
          ..add('instance', instance)
          ..add('code', code)
          ..add('traceId', traceId)
          ..add('invalidParams', invalidParams))
        .toString();
  }
}

class ProblemDetailsBuilder
    implements Builder<ProblemDetails, ProblemDetailsBuilder> {
  _$ProblemDetails? _$v;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  int? _status;
  int? get status => _$this._status;
  set status(int? status) => _$this._status = status;

  String? _detail;
  String? get detail => _$this._detail;
  set detail(String? detail) => _$this._detail = detail;

  String? _instance;
  String? get instance => _$this._instance;
  set instance(String? instance) => _$this._instance = instance;

  ErrorCode? _code;
  ErrorCode? get code => _$this._code;
  set code(ErrorCode? code) => _$this._code = code;

  String? _traceId;
  String? get traceId => _$this._traceId;
  set traceId(String? traceId) => _$this._traceId = traceId;

  ListBuilder<InvalidParam>? _invalidParams;
  ListBuilder<InvalidParam> get invalidParams =>
      _$this._invalidParams ??= new ListBuilder<InvalidParam>();
  set invalidParams(ListBuilder<InvalidParam>? invalidParams) =>
      _$this._invalidParams = invalidParams;

  ProblemDetailsBuilder() {
    ProblemDetails._defaults(this);
  }

  ProblemDetailsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _title = $v.title;
      _status = $v.status;
      _detail = $v.detail;
      _instance = $v.instance;
      _code = $v.code;
      _traceId = $v.traceId;
      _invalidParams = $v.invalidParams?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProblemDetails other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ProblemDetails;
  }

  @override
  void update(void Function(ProblemDetailsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProblemDetails build() => _build();

  _$ProblemDetails _build() {
    _$ProblemDetails _$result;
    try {
      _$result = _$v ??
          new _$ProblemDetails._(
              type: BuiltValueNullFieldError.checkNotNull(
                  type, r'ProblemDetails', 'type'),
              title: BuiltValueNullFieldError.checkNotNull(
                  title, r'ProblemDetails', 'title'),
              status: BuiltValueNullFieldError.checkNotNull(
                  status, r'ProblemDetails', 'status'),
              detail: detail,
              instance: instance,
              code: BuiltValueNullFieldError.checkNotNull(
                  code, r'ProblemDetails', 'code'),
              traceId: BuiltValueNullFieldError.checkNotNull(
                  traceId, r'ProblemDetails', 'traceId'),
              invalidParams: _invalidParams?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'invalidParams';
        _invalidParams?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ProblemDetails', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
