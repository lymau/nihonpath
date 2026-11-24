# nihonpath_api.api.AuthApi

## Load the API package
```dart
import 'package:nihonpath_api/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createGuestAccount**](AuthApi.md#createguestaccount) | **POST** /auth/guest | Buat akun guest dan dapatkan token otentikasi
[**getAuthJwks**](AuthApi.md#getauthjwks) | **GET** /.well-known/jwks.json | Ambil JSON Web Key Set untuk verifikasi access token
[**logoutAuthDevice**](AuthApi.md#logoutauthdevice) | **POST** /auth/logout | Logout dari perangkat
[**refreshAuthToken**](AuthApi.md#refreshauthtoken) | **POST** /auth/refresh | Rotasi refresh token


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

# **getAuthJwks**
> JwksResponse getAuthJwks()

Ambil JSON Web Key Set untuk verifikasi access token

### Example
```dart
import 'package:nihonpath_api/api.dart';

final api = NihonpathApi().getAuthApi();

try {
    final response = api.getAuthJwks();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->getAuthJwks: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JwksResponse**](JwksResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logoutAuthDevice**
> logoutAuthDevice(refreshTokenRequest)

Logout dari perangkat

Mencabut seluruh refresh token dalam family perangkat berdasarkan refresh token peminta.

### Example
```dart
import 'package:nihonpath_api/api.dart';

final api = NihonpathApi().getAuthApi();
final RefreshTokenRequest refreshTokenRequest =
    RefreshTokenRequest((b) => b..refreshToken = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');

try {
    api.logoutAuthDevice(refreshTokenRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->logoutAuthDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshTokenRequest** | [**RefreshTokenRequest**](RefreshTokenRequest.md)| Request body containing the refresh token. |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshAuthToken**
> AuthResponse refreshAuthToken(refreshTokenRequest)

Rotasi refresh token

Menerbitkan pasangan token baru dan mencabut refresh token sebelumnya; reuse mencabut seluruh family (§8.3, §12.1).

### Example
```dart
import 'package:nihonpath_api/api.dart';

final api = NihonpathApi().getAuthApi();
final RefreshTokenRequest refreshTokenRequest =
    RefreshTokenRequest((b) => b..refreshToken = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');

try {
    final response = api.refreshAuthToken(refreshTokenRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->refreshAuthToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshTokenRequest** | [**RefreshTokenRequest**](RefreshTokenRequest.md)| Request body containing the refresh token. |

### Return type

[**AuthResponse**](AuthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
