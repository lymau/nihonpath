// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add(AppConfigResponse.serializer)
      ..add(AuthResponse.serializer)
      ..add(ContentManifestResponse.serializer)
      ..add(ContentPack.serializer)
      ..add(ContentPackKind.serializer)
      ..add(ErrorCode.serializer)
      ..add(GuestAuthRequest.serializer)
      ..add(GuestAuthRequestPlatformEnum.serializer)
      ..add(InvalidParam.serializer)
      ..add(ProblemDetails.serializer)
      ..add(SyncChange.serializer)
      ..add(SyncEntityName.serializer)
      ..add(SyncOpResult.serializer)
      ..add(SyncOpStatus.serializer)
      ..add(SyncOpType.serializer)
      ..add(SyncOperation.serializer)
      ..add(SyncPullResponse.serializer)
      ..add(SyncPushRequest.serializer)
      ..add(SyncPushResponse.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ContentPack)]),
          () => new ListBuilder<ContentPack>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(InvalidParam)]),
          () => new ListBuilder<InvalidParam>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(SyncChange)]),
          () => new ListBuilder<SyncChange>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(SyncOpResult)]),
          () => new ListBuilder<SyncOpResult>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(SyncOperation)]),
          () => new ListBuilder<SyncOperation>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(bool)]),
          () => new MapBuilder<String, bool>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => new MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => new MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => new MapBuilder<String, JsonObject?>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
