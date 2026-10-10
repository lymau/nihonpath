# nihonpath_api.api.AuthApi

## Load the API package
```dart
import 'package:nihonpath_api/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createGuestAccount**](AuthApi.md#createguestaccount) | **POST** /auth/guest | Buat akun guest dan dapatkan token otentikasi


# **createGuestAccount**
> AuthResponse createGuestAccount(guestAuthRequest)

Buat akun guest dan dapatkan token otentikasi

Mendaftarkan perangkat tamu tanpa kredensial dan menerbitkan access token JWT serta refresh token (§8.2, §8.3).

### Example
```dart
import 'package:nihonpath_api/api.dart';

final api = NihonpathApi().getAuthApi();
final GuestAuthRequest guestAuthRequest = ; // GuestAuthRequest | 

try {
    final response = api.createGuestAccount(guestAuthRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->createGuestAccount: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **guestAuthRequest** | [**GuestAuthRequest**](GuestAuthRequest.md)|  | 

### Return type

[**AuthResponse**](AuthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

