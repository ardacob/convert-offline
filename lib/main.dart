import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import 'conversion_catalog.dart';
import 'conversion_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FFmpegKitExtended.initialize();
  runApp(const ConvertApp());
}

class ConvertApp extends StatelessWidget {
  const ConvertApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Convert',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6554D4)),
          scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        ),
        home: const ConvertHome(),
      );
}

class ConvertHome extends StatefulWidget {
  const ConvertHome({super.key});

  @override
  State<ConvertHome> createState() => _ConvertHomeState();
}

class _ConvertHomeState extends State<ConvertHome> {
  final _service = ConversionService();
  File? _input;
  ConversionOption? _selected;
  bool _busy = false;
  String? _error;
  List<File> _outputs = const [];

  Future<void> _pickFile() async {
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: false,
      allowMultiple: false,
    );
    if (!mounted || selection == null) return;
    final path = selection.files.single.path;
    setState(() {
      _input = path == null ? null : File(path);
      _selected = null;
      _outputs = const [];
      _error = path == null ? 'Dosya yoluna erişilemedi.' : null;
    });
  }

  Future<void> _convert() async {
    final input = _input;
    final selected = _selected;
    if (input == null || selected == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _outputs = const [];
    });
    try {
      final outputs = await _service.convert(input, selected);
      if (mounted) setState(() => _outputs = outputs);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extension = _input == null
        ? ''
        : p.extension(_input!.path).replaceFirst('.', '').toLowerCase();
    final options = ConversionCatalog.forExtension(extension);
    return Scaffold(
      appBar: AppBar(title: const Text('Convert'), centerTitle: false),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.transform_rounded, size: 64, color: Color(0xFF6554D4)),
              const SizedBox(height: 12),
              Text('Dosyanı dönüştür', style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Dosyalar cihazında işlenir. İnternet bağlantısı gerekmez.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('1  Dosya seç', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Dosya seç'),
                    ),
                    if (_input != null) ...[
                      const SizedBox(height: 8),
                      SelectableText(p.basename(_input!.path)),
                    ],
                    if (_input != null && options.isEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Bu uzantı için henüz bir dönüşüm yok.'),
                    ],
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('2  Hedef biçim', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ConversionOption>(
                      value: _selected,
                      hint: const Text('Biçim seç'),
                      items: options.map((option) => DropdownMenuItem(
                        value: option, child: Text(option.label),
                      )).toList(),
                      onChanged: _busy ? null : (value) => setState(() => _selected = value),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _busy || _selected == null ? null : _convert,
                      icon: const Icon(Icons.autorenew),
                      label: Text(_busy ? 'Dönüştürülüyor…' : 'Dönüştür'),
                    ),
                    if (_busy) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ]),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              if (_outputs.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Tamamlandı: ${_outputs.length} dosya',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._outputs.map((file) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(p.basename(file.path)),
                    subtitle: SelectableText(file.path),
                  ),
                )),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(files: _outputs.map((file) => XFile(file.path)).toList()),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('Dosyaları paylaş / kaydet'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
