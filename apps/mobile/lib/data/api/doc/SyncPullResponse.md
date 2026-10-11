# nihonpath_api.model.SyncPullResponse

## Load the model package
```dart
import 'package:nihonpath_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**changes** | [**BuiltList&lt;SyncChange&gt;**](SyncChange.md) |  | 
**nextCursor** | **int** | Sequence tertinggi yang ditarik | 
**hasMore** | **bool** | Bernilai true jika masih ada halaman perubahan berikutnya | 
**serverTime** | [**DateTime**](DateTime.md) | Waktu server saat ini untuk kalkulasi clock offset | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


