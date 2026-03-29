// Download Progress Tracker

class DownloadException implements Exception {
  final String reason;
  DownloadException(this.reason);

  @override
  String toString() => "DownloadExcpetion: $reason";
}

class DownloadProgress {
  final String fileName;
  final int bytesDownloaded;
  final int totalBytes;

  const DownloadProgress({
    required this.fileName,
    required this.bytesDownloaded,
    required this.totalBytes,
  });

  double get percentage => (bytesDownloaded / totalBytes) * 100;

  bool get isComplete => bytesDownloaded >= totalBytes;

  String get progressBar {
    final filled = (percentage / 5).round();
    final bar = '█' * filled + '░' * (20 - filled);
    return '[$bar] ${percentage.toStringAsFixed(1)}%';
  }

  @override
  String toString() =>
      '$fileName: $progressBar (${bytesDownloaded ~/ 1024}/${totalBytes ~/ 1024} KB)';
}

Stream<DownloadProgress> downloadFile({
  required String fileName,
  required int totalBytes,
  int chunkSize = 51200, // 50 KB
  bool simulateError = false,
}) async* {
  int downloaded = 0;
  int tick = 0;

  while (downloaded < totalBytes) {
    await Future.delayed(Duration(milliseconds: 150));

    if (simulateError && tick == 3) {
      throw DownloadException("Connection reset after 3 chunks!");
    }

    downloaded = (downloaded + chunkSize).clamp(0, totalBytes);
    yield DownloadProgress(
      fileName: fileName,
      bytesDownloaded: downloaded,
      totalBytes: totalBytes,
    );
    tick++;
  }
}

Future<void> runDownload(
  String fileName,
  int size, {
  bool simulateError = false,
}) async {
  print('\nStarting Download: $fileName');
  try {
    await for (final progress in downloadFile(
      fileName: fileName,
      totalBytes: size,
      simulateError: simulateError,
    )) {
      print(progress);
      if (progress.isComplete) print("✅ Download complete!\n");
    }
  } on DownloadException catch (e) {
    print('❌ Download failed: $e');
  } finally {
    print('Cleanup for $fileName');
  }
}

Future<void> downloadAll(List<(String, int)> files) async {
  await Future.wait([
    for (final (name, size) in files) runDownload(name, size),
  ]);
  print('All Downloads Finished');
}

void main(List<String> args) async {
  await runDownload('report.pdf', 512000);
  await runDownload('corrupt.zip', 512000, simulateError: true);

  print('\n---Parallel Downloads---');
  await downloadAll([
    ('image1.png', 204800),
    ('video.mp4', 1048576),
    ('data.csv', 102400),
  ]);
}
