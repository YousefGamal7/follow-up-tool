import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ArchiveService {
  /// Extracts the given zip file into a temporary directory
  /// Returns the Directory where the contents were extracted.
  Future<Directory> extractZipToTemp(File zipFile) async {
    final tempDir = await getTemporaryDirectory();
    final extractionPath = p.join(tempDir.path, 'project_viewer_${DateTime.now().millisecondsSinceEpoch}');
    final destDir = Directory(extractionPath);
    await destDir.create(recursive: true);

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(p.join(destDir.path, filename));
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        await Directory(p.join(destDir.path, filename)).create(recursive: true);
      }
    }

    return destDir;
  }
}
