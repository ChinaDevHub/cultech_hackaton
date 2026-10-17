import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum MediaKind {
  image('Şəkil'),
  audio('Audio');

  const MediaKind(this.label);

  final String label;
}

/// Where the user wants to take media from.
enum MediaOrigin { camera, gallery, audioFile }

/// A piece of media submitted for AI DNA analysis.
final class ScanMedia extends Equatable {
  const ScanMedia({
    required this.id,
    required this.name,
    required this.kind,
    required this.sizeInBytes,
    this.bytes,
    this.sampleId,
  });

  /// Unique per selection; used for equality instead of the raw bytes so
  /// state comparisons stay O(1) even for multi-megabyte files.
  final String id;
  final String name;
  final MediaKind kind;
  final int sizeInBytes;
  final Uint8List? bytes;

  /// Set for built-in demo samples (rendered procedurally, no bytes).
  final String? sampleId;

  bool get isSample => sampleId != null;

  @override
  List<Object?> get props => <Object?>[id, name, kind, sizeInBytes, sampleId];
}
