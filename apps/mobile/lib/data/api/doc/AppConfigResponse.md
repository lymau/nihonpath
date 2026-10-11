# nihonpath_api.model.AppConfigResponse

## Load the model package
```dart
import 'package:nihonpath_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**minAppVersion** | **String** | Versi minimum aplikasi yang diperbolehkan berjalan (§8.1) | 
**latestAppVersion** | **String** | Versi aplikasi terbaru yang tersedia di store | 
**maintenance** | **bool** | Status pemeliharaan sistem | 
**features** | **BuiltMap&lt;String, bool&gt;** | Feature flag boolean aktif untuk klien | 
**remoteParams** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Parameter jarak jauh untuk konfigurasi algoritma seperti FSRS | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


