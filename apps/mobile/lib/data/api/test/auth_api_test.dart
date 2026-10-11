import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

/// tests for AuthApi
void main() {
  final instance = NihonpathApi().getAuthApi();

  group(AuthApi, () {
    // Buat akun guest dan dapatkan token otentikasi
    //
    // Mendaftarkan perangkat tamu tanpa kredensial dan menerbitkan access token JWT serta refresh token (§8.2, §8.3).
    //
    //Future<AuthResponse> createGuestAccount(GuestAuthRequest guestAuthRequest) async
    test('test createGuestAccount', () async {
      // TODO
    });
  });
}
