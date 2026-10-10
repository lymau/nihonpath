import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

// tests for ContentPack
void main() {
  final instance = ContentPackBuilder();
  // TODO add properties to the builder and call build()

  group(ContentPack, () {
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Tingkat level JLPT (0 = Kana, 5 = N5, .. 1 = N1)
    // int jlptLevel
    test('to test the property `jlptLevel`', () async {
      // TODO
    });

    // ContentPackKind kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // Versi paket konten numerik incremental
    // int version
    test('to test the property `version`', () async {
      // TODO
    });

    // Checksum SHA-256 berkas zip untuk verifikasi integritas (§9.3)
    // String sha256
    test('to test the property `sha256`', () async {
      // TODO
    });

    // Ukuran file paket dalam bytes
    // int sizeBytes
    test('to test the property `sizeBytes`', () async {
      // TODO
    });

    // Lokasi penyimpanan objek pada bucket
    // String storageKey
    test('to test the property `storageKey`', () async {
      // TODO
    });

    // URL unduhan langsung atau CDN bertanda tangan
    // String downloadUrl
    test('to test the property `downloadUrl`', () async {
      // TODO
    });

    // Versi minimum aplikasi yang mendukung format paket ini
    // String minAppVersion
    test('to test the property `minAppVersion`', () async {
      // TODO
    });

    // Apakah paket ini membutuhkan langganan berbayar (§8.2)
    // bool isPremium
    test('to test the property `isPremium`', () async {
      // TODO
    });

    // Waktu paket dipublikasikan
    // DateTime publishedAt
    test('to test the property `publishedAt`', () async {
      // TODO
    });
  });
}
