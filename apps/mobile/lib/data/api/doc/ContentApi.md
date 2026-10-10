# nihonpath_api.api.ContentApi

## Load the API package
```dart
import 'package:nihonpath_api/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getContentManifest**](ContentApi.md#getcontentmanifest) | **GET** /content/manifest | Ambil manifest paket konten


# **getContentManifest**
> ContentManifestResponse getContentManifest(level, ifNoneMatch)

Ambil manifest paket konten

Mengembalikan daftar paket konten (core, audio, strokes, passages, tests) berdasarkan level dengan checksum SHA-256 dan ukuran (§8.2, §9.3).

### Example
```dart
import 'package:nihonpath_api/api.dart';

final api = NihonpathApi().getContentApi();
final int level = 56; // int | Filter level JLPT (0 = Kana, 5 = N5, 4 = N4, 3 = N3, 2 = N2, 1 = N1)
final String ifNoneMatch = ifNoneMatch_example; // String | Hash ETag dari manifest sebelumnya untuk HTTP 304 Not Modified

try {
    final response = api.getContentManifest(level, ifNoneMatch);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->getContentManifest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **level** | **int**| Filter level JLPT (0 = Kana, 5 = N5, 4 = N4, 3 = N3, 2 = N2, 1 = N1) | [optional] 
 **ifNoneMatch** | **String**| Hash ETag dari manifest sebelumnya untuk HTTP 304 Not Modified | [optional] 

### Return type

[**ContentManifestResponse**](ContentManifestResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

