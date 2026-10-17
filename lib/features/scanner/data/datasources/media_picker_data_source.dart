import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scanner_capabilities.dart';

/// Abstraction over the platform media pickers.
abstract interface class MediaPickerDataSource {
  ScannerCapabilities get capabilities;

  /// Returns `null` when the user cancels.
  Future<ScanMedia?> pick(MediaOrigin origin);
}

/// Picks media with graceful per-platform degradation:
///
/// * **iOS / Android** — native camera + photo library via `image_picker`.
/// * **Web / desktop** — no camera API is relied upon; "camera" and
///   "gallery" both fall back to the system file explorer via `file_picker`
///   (an `<input type=file>` on the web), so no platform error can surface.
/// * Audio always goes through `file_picker` with an extension allow-list,
///   which avoids media-library permissions on iOS.
final class PlatformMediaPickerDataSource implements MediaPickerDataSource {
  PlatformMediaPickerDataSource({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  static const int maxFileSizeBytes = 25 * 1024 * 1024;
  static const List<String> imageExtensions = <String>[
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
    'bmp',
  ];
  static const List<String> audioExtensions = <String>[
    'mp3',
    'wav',
    'm4a',
    'aac',
    'ogg',
    'flac',
  ];

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  ScannerCapabilities get capabilities => ScannerCapabilities(
    cameraAvailable:
        _isMobile && _imagePicker.supportsImageSource(ImageSource.camera),
    maxFileSizeBytes: maxFileSizeBytes,
    imageExtensions: imageExtensions,
    audioExtensions: audioExtensions,
  );

  @override
  Future<ScanMedia?> pick(MediaOrigin origin) async {
    try {
      return switch (origin) {
        MediaOrigin.camera when capabilities.cameraAvailable =>
          await _pickWithImagePicker(ImageSource.camera),
        MediaOrigin.gallery when _isMobile => await _pickWithImagePicker(
          ImageSource.gallery,
        ),
        // Web & desktop: camera/gallery degrade to the file explorer.
        MediaOrigin.camera ||
        MediaOrigin.gallery => await _pickFile(MediaKind.image),
        MediaOrigin.audioFile => await _pickFile(MediaKind.audio),
      };
    } on PlatformException catch (error) {
      throw MediaPickException(_describePlatformError(error));
    } on MediaValidationException {
      rethrow;
    } on Exception catch (error) {
      debugPrint('Media picker failed: $error');
      throw const MediaPickException('Fayl seçilə bilmədi. Yenidən cəhd edin.');
    }
  }

  Future<ScanMedia?> _pickWithImagePicker(ImageSource source) async {
    final XFile? file = await _imagePicker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    final Uint8List bytes = await file.readAsBytes();
    return _build(name: file.name, kind: MediaKind.image, bytes: bytes);
  }

  Future<ScanMedia?> _pickFile(MediaKind kind) async {
    final PlatformFile? file = await FilePicker.pickFile(
      dialogTitle: kind == MediaKind.image
          ? 'Skan üçün şəkil seçin'
          : 'Skan üçün audio seçin',
      type: kind == MediaKind.image ? FileType.image : FileType.custom,
      allowedExtensions: kind == MediaKind.audio ? audioExtensions : null,
    );
    if (file == null) return null;

    final int? knownLength = file.lengthSync();
    if (knownLength != null && knownLength > maxFileSizeBytes) {
      throw MediaValidationException(_tooLargeMessage);
    }
    final String extension = (file.extension ?? '').toLowerCase();
    final List<String> allowed = kind == MediaKind.image
        ? imageExtensions
        : audioExtensions;
    if (extension.isNotEmpty && !allowed.contains(extension)) {
      throw MediaValidationException(
        '.$extension formatı dəstəklənmir. İcazə verilən: '
        '${allowed.map((String e) => '.$e').join(', ')}',
      );
    }
    final Uint8List bytes = await file.readAsBytes();
    return _build(name: file.name, kind: kind, bytes: bytes);
  }

  ScanMedia _build({
    required String name,
    required MediaKind kind,
    required Uint8List bytes,
  }) {
    if (bytes.isEmpty) {
      throw const MediaValidationException('Seçilmiş fayl boşdur.');
    }
    if (bytes.length > maxFileSizeBytes) {
      throw MediaValidationException(_tooLargeMessage);
    }
    return ScanMedia(
      id: '${DateTime.now().microsecondsSinceEpoch}-$name',
      name: name,
      kind: kind,
      sizeInBytes: bytes.length,
      bytes: bytes,
    );
  }

  static String get _tooLargeMessage =>
      'Fayl çox böyükdür. Maksimum ölçü: '
      '${maxFileSizeBytes ~/ (1024 * 1024)} MB.';

  static String _describePlatformError(PlatformException error) {
    return switch (error.code) {
      'camera_access_denied' ||
      'camera_access_restricted' => 'Kameraya giriş icazəsi verilməyib.',
      'photo_access_denied' ||
      'photo_access_restricted' => 'Qalereyaya giriş icazəsi verilməyib.',
      'no_available_camera' => 'Bu cihazda kamera tapılmadı.',
      _ => 'Platforma xətası: ${error.message ?? error.code}',
    };
  }
}
