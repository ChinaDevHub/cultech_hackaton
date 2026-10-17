import 'package:equatable/equatable.dart';

enum DatasetModality {
  visual('Vizual'),
  audio('Audio'),
  model3d('3D'),
  multimodal('Multimodal');

  const DatasetModality(this.label);

  final String label;

  static DatasetModality fromName(String name) {
    return DatasetModality.values.firstWhere(
      (DatasetModality m) => m.name == name,
      orElse: () => DatasetModality.multimodal,
    );
  }
}

/// An ethically sourced, rights-cleared heritage dataset for B2B licensing.
final class CulturalDataset extends Equatable {
  const CulturalDataset({
    required this.id,
    required this.title,
    required this.description,
    required this.modality,
    required this.itemCount,
    required this.itemUnit,
    required this.sizeLabel,
    required this.formats,
    required this.useCases,
    required this.priceUsd,
    required this.licenseType,
    required this.rating,
  });

  final String id;
  final String title;
  final String description;
  final DatasetModality modality;
  final int itemCount;

  /// Unit for [itemCount], e.g. `nümunə`, `saat`.
  final String itemUnit;
  final String sizeLabel;
  final List<String> formats;
  final List<String> useCases;

  /// Annual commercial license price.
  final double priceUsd;
  final String licenseType;
  final double rating;

  @override
  List<Object?> get props => <Object?>[id];
}
