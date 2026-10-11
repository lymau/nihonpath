# nihonpath_api.model.AuthResponse

## Load the model package
```dart
import 'package:nihonpath_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**userId** | **String** | Pengenal unik akun pengguna | 
**accessToken** | **String** | JWT access token berumur 15 menit (§8.3) | 
**refreshToken** | **String** | Refresh token acak 256-bit berumur 30 hari (§8.3) | 
**expiresIn** | **int** | Masa berlaku access token dalam detik (default 900) | 
**tokenType** | **String** | Tipe otentikasi token | [default to 'Bearer']

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


