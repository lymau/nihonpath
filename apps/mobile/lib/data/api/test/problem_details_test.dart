import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

// tests for ProblemDetails
void main() {
  final instance = ProblemDetailsBuilder();
  // TODO add properties to the builder and call build()

  group(ProblemDetails, () {
    // URI referensi tipe masalah
    // String type
    test('to test the property `type`', () async {
      // TODO
    });

    // Ringkasan singkat jenis masalah
    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // Kode status HTTP
    // int status
    test('to test the property `status`', () async {
      // TODO
    });

    // Penjelasan detail masalah yang terjadi
    // String detail
    test('to test the property `detail`', () async {
      // TODO
    });

    // URI kejadian masalah spesifik
    // String instance
    test('to test the property `instance`', () async {
      // TODO
    });

    // ErrorCode code
    test('to test the property `code`', () async {
      // TODO
    });

    // ID penelusuran terdistribusi W3C / UUID untuk korelasi log (§10.1)
    // String traceId
    test('to test the property `traceId`', () async {
      // TODO
    });

    // Daftar parameter yang gagal validasi jika ada
    // BuiltList<InvalidParam> invalidParams
    test('to test the property `invalidParams`', () async {
      // TODO
    });
  });
}
