import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SdkLogFileManager {
  static const String _logDirName = 'sdk_logs';
  static const String _exportDirName = 'sdk_log_exports';

  Future<Directory> _logDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory logDir = Directory(p.join(appDir.path, _logDirName));
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return logDir;
  }

  Future<Directory> _exportDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory exportDir = Directory(p.join(appDir.path, _exportDirName));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  String _datePart(DateTime dateTime) {
    final String year = dateTime.year.toString().padLeft(4, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _timePart(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _exportTimestamp(DateTime dateTime) {
    final String date = _datePart(dateTime).replaceAll('-', '');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String second = dateTime.second.toString().padLeft(2, '0');
    return '${date}_$hour$minute$second';
  }

  Future<File> appendLog(String log) async {
    final DateTime now = DateTime.now();
    final Directory logDir = await _logDirectory();
    final File logFile =
        File(p.join(logDir.path, 'sdk_log_${_datePart(now)}.log'));
    final String line = '${_datePart(now)} ${_timePart(now)} | $log\n';
    return logFile.writeAsString(line, mode: FileMode.append, flush: true);
  }

  Future<List<File>> listLogFiles() async {
    final Directory logDir = await _logDirectory();
    final List<File> files = await logDir
        .list()
        .where((FileSystemEntity entity) =>
            entity is File && entity.path.endsWith('.log'))
        .cast<File>()
        .toList();
    files.sort((File a, File b) => a.path.compareTo(b.path));
    return files;
  }

  Future<int> logFileCount() async {
    final List<File> files = await listLogFiles();
    return files.length;
  }

  Future<File?> exportAllLogsAsZip() async {
    final List<File> logFiles = await listLogFiles();
    if (logFiles.isEmpty) {
      return null;
    }

    final Archive archive = Archive();
    for (final File file in logFiles) {
      final List<int> bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile.bytes(p.basename(file.path), bytes));
    }

    final List<int> zipBytes = ZipEncoder().encode(archive);
    final Directory exportDir = await _exportDirectory();
    final File zipFile = File(
      p.join(
          exportDir.path, 'sdk_logs_${_exportTimestamp(DateTime.now())}.zip'),
    );
    await zipFile.writeAsBytes(zipBytes, flush: true);
    return zipFile;
  }
}
