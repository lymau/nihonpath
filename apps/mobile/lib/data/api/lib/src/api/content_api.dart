//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:nihonpath_api/src/api_util.dart';
import 'package:nihonpath_api/src/model/content_manifest_response.dart';
import 'package:nihonpath_api/src/model/problem_details.dart';

class ContentApi {
  final Dio _dio;

  final Serializers _serializers;

  const ContentApi(this._dio, this._serializers);

  /// Ambil manifest paket konten
  /// Mengembalikan daftar paket konten (core, audio, strokes, passages, tests) berdasarkan level dengan checksum SHA-256 dan ukuran (§8.2, §9.3).
  ///
  /// Parameters:
  /// * [level] - Filter level JLPT (0 = Kana, 5 = N5, 4 = N4, 3 = N3, 2 = N2, 1 = N1)
  /// * [ifNoneMatch] - Hash ETag dari manifest sebelumnya untuk HTTP 304 Not Modified
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ContentManifestResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ContentManifestResponse>> getContentManifest({
    int? level,
    String? ifNoneMatch,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/content/manifest';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (ifNoneMatch != null) r'If-None-Match': ifNoneMatch,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (level != null)
        r'level':
            encodeQueryParameter(_serializers, level, const FullType(int)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    ContentManifestResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ContentManifestResponse),
            ) as ContentManifestResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ContentManifestResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
