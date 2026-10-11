import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

// tests for AuthResponse
void main() {
  final instance = AuthResponseBuilder();
  // TODO add properties to the builder and call build()

  group(AuthResponse, () {
    // Pengenal unik akun pengguna
    // String userId
    test('to test the property `userId`', () async {
      // TODO
    });

    // JWT access token berumur 15 menit (§8.3)
    // String accessToken
    test('to test the property `accessToken`', () async {
      // TODO
    });

    // Refresh token acak 256-bit berumur 30 hari (§8.3)
    // String refreshToken
    test('to test the property `refreshToken`', () async {
      // TODO
    });

    // Masa berlaku access token dalam detik (default 900)
    // int expiresIn
    test('to test the property `expiresIn`', () async {
      // TODO
    });

    // Tipe otentikasi token
    // String tokenType (default value: 'Bearer')
    test('to test the property `tokenType`', () async {
      // TODO
    });
  });
}
