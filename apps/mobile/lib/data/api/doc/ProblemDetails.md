# nihonpath_api.model.ProblemDetails

## Load the model package
```dart
import 'package:nihonpath_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**type** | **String** | URI referensi tipe masalah | 
**title** | **String** | Ringkasan singkat jenis masalah | 
**status** | **int** | Kode status HTTP | 
**detail** | **String** | Penjelasan detail masalah yang terjadi | [optional] 
**instance** | **String** | URI kejadian masalah spesifik | [optional] 
**code** | [**ErrorCode**](ErrorCode.md) |  | 
**traceId** | **String** | ID penelusuran terdistribusi W3C / UUID untuk korelasi log (§10.1) | 
**invalidParams** | [**BuiltList&lt;InvalidParam&gt;**](InvalidParam.md) | Daftar parameter yang gagal validasi jika ada | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


