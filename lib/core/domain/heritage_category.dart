/// Shared kernel: the families of cultural heritage CultGuard protects.
enum HeritageCategory {
  carpet('Xalça naxışları'),
  mugham('Muğam və musiqi'),
  instrument('Milli alətlər'),
  ornament('Ornament və miniatür');

  const HeritageCategory(this.label);

  final String label;

  static HeritageCategory fromName(String name) {
    return HeritageCategory.values.firstWhere(
      (HeritageCategory c) => c.name == name,
      orElse: () => HeritageCategory.ornament,
    );
  }
}
