enum ConversionKind { image, document, audio, video }

class ConversionOption {
  const ConversionOption(this.label, this.extension, this.kind);
  final String label;
  final String extension;
  final ConversionKind kind;
}

class ConversionCatalog {
  static final Map<String, List<ConversionOption>> options = {
    'jpg': _image,
    'jpeg': _image,
    'png': _image,
    'webp': _image,
    'bmp': _image,
    'pdf': const [ConversionOption('PNG (sayfalar)', 'png', ConversionKind.document)],
    'mp4': _video,
    'mov': _video,
    'mkv': _video,
    'webm': _video,
    'avi': _video,
    'mp3': _audio,
    'wav': _audio,
    'm4a': _audio,
    'aac': _audio,
    'flac': _audio,
    'ogg': _audio,
  };

  static const _image = [
    ConversionOption('JPG', 'jpg', ConversionKind.image),
    ConversionOption('PNG', 'png', ConversionKind.image),
    ConversionOption('WebP', 'webp', ConversionKind.image),
    ConversionOption('PDF', 'pdf', ConversionKind.document),
  ];
  static const _video = [
    ConversionOption('MP4', 'mp4', ConversionKind.video),
    ConversionOption('MOV', 'mov', ConversionKind.video),
    ConversionOption('WebM', 'webm', ConversionKind.video),
    ConversionOption('MP3 (ses)', 'mp3', ConversionKind.audio),
    ConversionOption('WAV (ses)', 'wav', ConversionKind.audio),
  ];
  static const _audio = [
    ConversionOption('MP3', 'mp3', ConversionKind.audio),
    ConversionOption('WAV', 'wav', ConversionKind.audio),
    ConversionOption('M4A', 'm4a', ConversionKind.audio),
    ConversionOption('FLAC', 'flac', ConversionKind.audio),
  ];

  static List<ConversionOption> forExtension(String extension) =>
      (options[extension.toLowerCase()] ?? const [])
          .where((option) => option.extension != extension.toLowerCase())
          .toList();
}
