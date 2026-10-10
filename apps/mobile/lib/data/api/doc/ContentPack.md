# nihonpath_api.model.ContentPack

## Load the model package
```dart
import 'package:nihonpath_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**jlptLevel** | **int** | Tingkat level JLPT (0 = Kana, 5 = N5, .. 1 = N1) | 
**kind** | [**ContentPackKind**](ContentPackKind.md) |  | 
**version** | **int** | Versi paket konten numerik incremental | 
**sha256** | **String** | Checksum SHA-256 berkas zip untuk verifikasi integritas (§9.3) | 
**sizeBytes** | **int** | Ukuran file paket dalam bytes | 
**storageKey** | **String** | Lokasi penyimpanan objek pada bucket | 
**downloadUrl** | **String** | URL unduhan langsung atau CDN bertanda tangan | [optional] 
**minAppVersion** | **String** | Versi minimum aplikasi yang mendukung format paket ini | 
**isPremium** | **bool** | Apakah paket ini membutuhkan langganan berbayar (§8.2) | 
**publishedAt** | [**DateTime**](DateTime.md) | Waktu paket dipublikasikan | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


