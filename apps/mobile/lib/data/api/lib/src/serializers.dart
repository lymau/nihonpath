//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:nihonpath_api/src/date_serializer.dart';
import 'package:nihonpath_api/src/model/date.dart';

import 'package:nihonpath_api/src/model/app_config_response.dart';
import 'package:nihonpath_api/src/model/auth_response.dart';
import 'package:nihonpath_api/src/model/content_manifest_response.dart';
import 'package:nihonpath_api/src/model/content_pack.dart';
import 'package:nihonpath_api/src/model/content_pack_kind.dart';
import 'package:nihonpath_api/src/model/error_code.dart';
import 'package:nihonpath_api/src/model/guest_auth_request.dart';
import 'package:nihonpath_api/src/model/invalid_param.dart';
import 'package:nihonpath_api/src/model/problem_details.dart';
import 'package:nihonpath_api/src/model/sync_change.dart';
import 'package:nihonpath_api/src/model/sync_entity_name.dart';
import 'package:nihonpath_api/src/model/sync_op_result.dart';
import 'package:nihonpath_api/src/model/sync_op_status.dart';
import 'package:nihonpath_api/src/model/sync_op_type.dart';
import 'package:nihonpath_api/src/model/sync_operation.dart';
import 'package:nihonpath_api/src/model/sync_pull_response.dart';
import 'package:nihonpath_api/src/model/sync_push_request.dart';
import 'package:nihonpath_api/src/model/sync_push_response.dart';

part 'serializers.g.dart';

@SerializersFor([
  AppConfigResponse,
  AuthResponse,
  ContentManifestResponse,
  ContentPack,
  ContentPackKind,
  ErrorCode,
  GuestAuthRequest,
  InvalidParam,
  ProblemDetails,
  SyncChange,
  SyncEntityName,
  SyncOpResult,
  SyncOpStatus,
  SyncOpType,
  SyncOperation,
  SyncPullResponse,
  SyncPushRequest,
  SyncPushResponse,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SyncOperation)]),
        () => ListBuilder<SyncOperation>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(InvalidParam)]),
        () => ListBuilder<InvalidParam>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
        () => MapBuilder<String, JsonObject?>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ContentPack)]),
        () => ListBuilder<ContentPack>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(bool)]),
        () => MapBuilder<String, bool>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SyncOpResult)]),
        () => ListBuilder<SyncOpResult>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SyncChange)]),
        () => ListBuilder<SyncChange>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
