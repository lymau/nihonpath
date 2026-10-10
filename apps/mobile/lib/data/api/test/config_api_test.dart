import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

/// tests for ConfigApi
void main() {
  final instance = NihonpathApi().getConfigApi();

  group(ConfigApi, () {
    // Ambil konfigurasi aplikasi dan parameter remote
    //
    // Mengembalikan versi minimum aplikasi yang didukung, status pemeliharaan, feature flag, dan parameter FSRS remote (§8.1, §8.2).
    //
    //Future<AppConfigResponse> getAppConfig({ String xAppVersion, String xDeviceId }) async
    test('test getAppConfig', () async {
      // TODO
    });
  });
}
