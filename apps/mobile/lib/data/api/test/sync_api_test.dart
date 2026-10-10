import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

/// tests for SyncApi
void main() {
  final instance = NihonpathApi().getSyncApi();

  group(SyncApi, () {
    // Tarik mutasi perubahan dari perangkat lain
    //
    // Mengambil urutan mutasi perubahan data user_seq > cursor dari perangkat lain (§7.2).
    //
    //Future<SyncPullResponse> pullSyncChanges({ int cursor, int limit, String entities }) async
    test('test pullSyncChanges', () async {
      // TODO
    });

    // Dorong mutasi offline lokal ke server
    //
    // Menerima mutasi perubahan lokal (maksimum 200 op dan 512 KB per request) secara idempoten dan mengembalikan status penerimaan serta cursor baru (§7.2).
    //
    //Future<SyncPushResponse> pushSyncOps(SyncPushRequest syncPushRequest) async
    test('test pushSyncOps', () async {
      // TODO
    });
  });
}
