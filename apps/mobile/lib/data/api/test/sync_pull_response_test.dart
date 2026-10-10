import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

// tests for SyncPullResponse
void main() {
  final instance = SyncPullResponseBuilder();
  // TODO add properties to the builder and call build()

  group(SyncPullResponse, () {
    // BuiltList<SyncChange> changes
    test('to test the property `changes`', () async {
      // TODO
    });

    // Sequence tertinggi yang ditarik
    // int nextCursor
    test('to test the property `nextCursor`', () async {
      // TODO
    });

    // Bernilai true jika masih ada halaman perubahan berikutnya
    // bool hasMore
    test('to test the property `hasMore`', () async {
      // TODO
    });

    // Waktu server saat ini untuk kalkulasi clock offset
    // DateTime serverTime
    test('to test the property `serverTime`', () async {
      // TODO
    });
  });
}
