import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

// tests for AppConfigResponse
void main() {
  final instance = AppConfigResponseBuilder();
  // TODO add properties to the builder and call build()

  group(AppConfigResponse, () {
    // Versi minimum aplikasi yang diperbolehkan berjalan (§8.1)
    // String minAppVersion
    test('to test the property `minAppVersion`', () async {
      // TODO
    });

    // Versi aplikasi terbaru yang tersedia di store
    // String latestAppVersion
    test('to test the property `latestAppVersion`', () async {
      // TODO
    });

    // Status pemeliharaan sistem
    // bool maintenance
    test('to test the property `maintenance`', () async {
      // TODO
    });

    // Feature flag boolean aktif untuk klien
    // BuiltMap<String, bool> features
    test('to test the property `features`', () async {
      // TODO
    });

    // Parameter jarak jauh untuk konfigurasi algoritma seperti FSRS
    // BuiltMap<String, JsonObject> remoteParams
    test('to test the property `remoteParams`', () async {
      // TODO
    });
  });
}
