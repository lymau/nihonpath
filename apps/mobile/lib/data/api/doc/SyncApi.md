# nihonpath_api.api.SyncApi

## Load the API package
```dart
import 'package:nihonpath_api/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**pullSyncChanges**](SyncApi.md#pullsyncchanges) | **GET** /sync/pull | Tarik mutasi perubahan dari perangkat lain
[**pushSyncOps**](SyncApi.md#pushsyncops) | **POST** /sync/push | Dorong mutasi offline lokal ke server


# **pullSyncChanges**
> SyncPullResponse pullSyncChanges(cursor, limit, entities)

Tarik mutasi perubahan dari perangkat lain

Mengambil urutan mutasi perubahan data user_seq > cursor dari perangkat lain (§7.2).

### Example
```dart
import 'package:nihonpath_api/api.dart';

final api = NihonpathApi().getSyncApi();
final int cursor = 789; // int | Posisi urutan terakhir yang diterima klien (user_seq)
final int limit = 56; // int | Jumlah maksimum item perubahan yang ditarik (maksimal 500)
final String entities = entities_example; // String | Filter daftar entitas dipisahkan koma (cards,settings,progress,logs,tests)

try {
    final response = api.pullSyncChanges(cursor, limit, entities);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SyncApi->pullSyncChanges: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **int**| Posisi urutan terakhir yang diterima klien (user_seq) | [optional] [default to 0]
 **limit** | **int**| Jumlah maksimum item perubahan yang ditarik (maksimal 500) | [optional] [default to 500]
 **entities** | **String**| Filter daftar entitas dipisahkan koma (cards,settings,progress,logs,tests) | [optional] [default to 'cards,settings,progress,logs']

### Return type

[**SyncPullResponse**](SyncPullResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pushSyncOps**
> SyncPushResponse pushSyncOps(syncPushRequest)

Dorong mutasi offline lokal ke server

Menerima mutasi perubahan lokal (maksimum 200 op dan 512 KB per request) secara idempoten dan mengembalikan status penerimaan serta cursor baru (§7.2).

### Example
```dart
import 'package:nihonpath_api/api.dart';

final api = NihonpathApi().getSyncApi();
final SyncPushRequest syncPushRequest = ; // SyncPushRequest | 

try {
    final response = api.pushSyncOps(syncPushRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SyncApi->pushSyncOps: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **syncPushRequest** | [**SyncPushRequest**](SyncPushRequest.md)|  | 

### Return type

[**SyncPushResponse**](SyncPushResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

