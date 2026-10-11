// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_manifest_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContentManifestResponse extends ContentManifestResponse {
  @override
  final BuiltList<ContentPack> packs;
  @override
  final DateTime generatedAt;

  factory _$ContentManifestResponse(
          [void Function(ContentManifestResponseBuilder)? updates]) =>
      (new ContentManifestResponseBuilder()..update(updates))._build();

  _$ContentManifestResponse._({required this.packs, required this.generatedAt})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        packs, r'ContentManifestResponse', 'packs');
    BuiltValueNullFieldError.checkNotNull(
        generatedAt, r'ContentManifestResponse', 'generatedAt');
  }

  @override
  ContentManifestResponse rebuild(
          void Function(ContentManifestResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentManifestResponseBuilder toBuilder() =>
      new ContentManifestResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContentManifestResponse &&
        packs == other.packs &&
        generatedAt == other.generatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, packs.hashCode);
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContentManifestResponse')
          ..add('packs', packs)
          ..add('generatedAt', generatedAt))
        .toString();
  }
}

class ContentManifestResponseBuilder
    implements
        Builder<ContentManifestResponse, ContentManifestResponseBuilder> {
  _$ContentManifestResponse? _$v;

  ListBuilder<ContentPack>? _packs;
  ListBuilder<ContentPack> get packs =>
      _$this._packs ??= new ListBuilder<ContentPack>();
  set packs(ListBuilder<ContentPack>? packs) => _$this._packs = packs;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  ContentManifestResponseBuilder() {
    ContentManifestResponse._defaults(this);
  }

  ContentManifestResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _packs = $v.packs.toBuilder();
      _generatedAt = $v.generatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContentManifestResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ContentManifestResponse;
  }

  @override
  void update(void Function(ContentManifestResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContentManifestResponse build() => _build();

  _$ContentManifestResponse _build() {
    _$ContentManifestResponse _$result;
    try {
      _$result = _$v ??
          new _$ContentManifestResponse._(
              packs: packs.build(),
              generatedAt: BuiltValueNullFieldError.checkNotNull(
                  generatedAt, r'ContentManifestResponse', 'generatedAt'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'packs';
        packs.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ContentManifestResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
