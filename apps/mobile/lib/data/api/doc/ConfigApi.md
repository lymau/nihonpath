# nihonpath_api.api.ConfigApi

## Load the API package
```dart
import 'package:nihonpath_api/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAppConfig**](ConfigApi.md#getappconfig) | **GET** /config | Ambil konfigurasi aplikasi dan parameter remote


# **getAppConfig**
> AppConfigResponse getAppConfig(xAppVersion, xDeviceId)

Ambil konfigurasi aplikasi dan parameter remote

Mengembalikan versi minimum aplikasi yang didukung, status pemeliharaan, feature flag, dan parameter FSRS remote (§8.1, §8.2).

### Example
```dart
import 'package:nihonpath_api/api.dart';

final api = NihonpathApi().getConfigApi();
final String xAppVersion = 0.1.0; // String | Versi aplikasi mobile peminta
final String xDeviceId = 0190a1b2-c3d4-7e8f-9012-3456789abcde; // String | Pengenal unik perangkat peminta

try {
    final response = api.getAppConfig(xAppVersion, xDeviceId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConfigApi->getAppConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAppVersion** | **String**| Versi aplikasi mobile peminta | [optional] 
 **xDeviceId** | **String**| Pengenal unik perangkat peminta | [optional] 

### Return type

[**AppConfigResponse**](AppConfigResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

