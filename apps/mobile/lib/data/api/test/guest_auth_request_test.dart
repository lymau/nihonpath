import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

// tests for GuestAuthRequest
void main() {
  final instance = GuestAuthRequestBuilder();
  // TODO add properties to the builder and call build()

  group(GuestAuthRequest, () {
    // Pengenal unik perangkat (UUIDv4)
    // String deviceId
    test('to test the property `deviceId`', () async {
      // TODO
    });

    // Platform sistem operasi perangkat (§6.3)
    // String platform
    test('to test the property `platform`', () async {
      // TODO
    });

    // Versi aplikasi mobile saat ini
    // String appVersion
    test('to test the property `appVersion`', () async {
      // TODO
    });

    // Versi sistem operasi perangkat
    // String osVersion
    test('to test the property `osVersion`', () async {
      // TODO
    });
  });
}
