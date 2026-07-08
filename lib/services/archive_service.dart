import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:unrar_file/unrar_file.dart';

class ArchiveService {
  /// Extracts the given archive file into a temporary directory
  /// Returns the Directory where the contents were extracted.
  Future<Directory> extractArchiveToTemp(File archiveFile) async {
    final ext = p.extension(archiveFile.path).toLowerCase();
    
    if (ext == '.zip') {
      return _extractZipToTemp(archiveFile);
    } else if (ext == '.rar') {
      return _extractRarToTemp(archiveFile);
    } else {
      throw Exception('Unsupported archive format: $ext');
    }
  }

  Future<Directory> _extractZipToTemp(File zipFile) async {
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

  Future<Directory> _extractRarToTemp(File rarFile) async {
    final tempDir = await getTemporaryDirectory();
    final extractionPath = p.join(tempDir.path, 'project_viewer_${DateTime.now().millisecondsSinceEpoch}');
    final destDir = Directory(extractionPath);
    await destDir.create(recursive: true);

    if (Platform.isWindows) {
      final unrarPath = r'C:\Program Files\WinRAR\UnRAR.exe';
      if (File(unrarPath).existsSync()) {
        final result = await Process.run(unrarPath, ['x', '-y', rarFile.path, '${destDir.path}\\']);
        if (result.exitCode != 0) {
          throw Exception('UnRAR failed: ${result.stderr}');
        }
      } else {
        throw Exception('WinRAR is required to extract .rar files on Windows. Please install WinRAR in the default directory.');
      }
    } else {
      await UnrarFile.extract_rar(rarFile.path, destDir.path);
    }

    return destDir;
  }
}
