import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

// tests for SyncOpResult
void main() {
  final instance = SyncOpResultBuilder();
  // TODO add properties to the builder and call build()

  group(SyncOpResult, () {
    // ID operasi yang diproses
    // String opId
    test('to test the property `opId`', () async {
      // TODO
    });

    // SyncOpStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // Kode kesalahan jika berstatus rejected (misal SYNC_CLOCK_INVALID, SYNC_OP_REJECTED)
    // String code
    test('to test the property `code`', () async {
      // TODO
    });
  });
}
