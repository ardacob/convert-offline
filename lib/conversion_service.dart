import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;

import 'conversion_catalog.dart';

class ConversionService {
  Future<List<File>> convert(File input, ConversionOption option) async {
    if (!await input.exists()) throw StateError('Kaynak dosya bulunamadı.');
    final extension = p.extension(input.path).substring(1).toLowerCase();
    if (!ConversionCatalog.forExtension(extension).any(
      (item) => item.extension == option.extension && item.kind == option.kind,
    )) {
      throw StateError('Bu kaynak ve hedef biçimi desteklenmiyor.');
    }

    final root = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(root.path, 'Convert'));
    await folder.create(recursive: true);
    final name = p.basenameWithoutExtension(input.path);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final output = File(p.join(folder.path, '${name}_$stamp.${option.extension}'));

    if (extension == 'pdf') return _pdfToPng(input, folder, name, stamp);
    if (option.extension == 'pdf') {
      await _imageToPdf(input, output);
      return [output];
    }

    await _ffmpeg(input, output, option);
    if (!await output.exists() || await output.length() == 0) {
      throw StateError('Dönüştürülen dosya oluşturulamadı.');
    }
    return [output];
  }

  Future<void> _imageToPdf(File input, File output) async {
    final document = pw.Document();
    final normalized = File('${output.path}.png');
    try {
      await _ffmpeg(input, normalized,
          const ConversionOption('PNG', 'png', ConversionKind.image));
      final image = pw.MemoryImage(await normalized.readAsBytes());
      document.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
      ));
      await output.writeAsBytes(await document.save(), flush: true);
    } finally {
      if (await normalized.exists()) await normalized.delete();
    }
  }

  Future<List<File>> _pdfToPng(
    File input, Directory folder, String name, int stamp,
  ) async {
    final document = await pdfx.PdfDocument.openFile(input.path);
    final created = <File>[];
    try {
      for (var i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        try {
          final image = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: pdfx.PdfPageImageFormat.PNG,
          );
          if (image == null) throw StateError('$i. sayfa işlenemedi.');
          final output = File(p.join(folder.path, '${name}_${stamp}_$i.png'));
          await output.writeAsBytes(image.bytes, flush: true);
          created.add(output);
        } finally {
          await page.close();
        }
      }
      return created;
    } catch (_) {
      for (final file in created) {
        if (await file.exists()) await file.delete();
      }
      rethrow;
    } finally {
      await document.close();
    }
  }

  Future<void> _ffmpeg(File input, File output, ConversionOption option) async {
    final codec = switch (option.extension) {
      'jpg' => '-frames:v 1 -q:v 2',
      'png' => '-frames:v 1',
      'webp' => '-frames:v 1 -c:v libwebp',
      'mp3' => '-vn -c:a libmp3lame -q:a 2',
      'wav' => '-vn -c:a pcm_s16le',
      'm4a' => '-vn -c:a aac -b:a 192k',
      'flac' => '-vn -c:a flac',
      'mp4' => '-c:v mpeg4 -q:v 4 -pix_fmt yuv420p -c:a aac',
      'mov' => '-c:v mpeg4 -q:v 4 -pix_fmt yuv420p -c:a aac',
      'webm' => '-c:v libvpx-vp9 -c:a libopus',
      _ => throw StateError('Hedef biçim desteklenmiyor.'),
    };
    final command = '-hide_banner -loglevel error -y -i ${_quote(input.path)} '
        '$codec ${_quote(output.path)}';
    final completer = Completer<int>();
    await FFmpegKit.executeAsync(
      command,
      onComplete: (session) => completer.complete(session.getReturnCode()),
    );
    final result = await completer.future;
    if (result != 0) {
      if (await output.exists()) await output.delete();
      throw StateError('Dönüştürme başarısız oldu (FFmpeg kodu: $result).');
    }
  }

  String _quote(String value) => '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';
}
