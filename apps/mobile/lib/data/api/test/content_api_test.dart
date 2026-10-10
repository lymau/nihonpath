import 'package:test/test.dart';
import 'package:nihonpath_api/nihonpath_api.dart';

/// tests for ContentApi
void main() {
  final instance = NihonpathApi().getContentApi();

  group(ContentApi, () {
    // Ambil manifest paket konten
    //
    // Mengembalikan daftar paket konten (core, audio, strokes, passages, tests) berdasarkan level dengan checksum SHA-256 dan ukuran (§8.2, §9.3).
    //
    //Future<ContentManifestResponse> getContentManifest({ int level, String ifNoneMatch }) async
    test('test getContentManifest', () async {
      // TODO
    });
  });
}
