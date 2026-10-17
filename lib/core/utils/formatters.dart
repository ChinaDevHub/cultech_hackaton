/// Pure, allocation-light formatting helpers (no `intl` dependency needed).
abstract final class Formatters {
  /// `1240` → `1,240`
  static String thousands(int value) {
    final String digits = value.abs().toString();
    final StringBuffer buffer = StringBuffer(value < 0 ? '-' : '');
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// `12400` → `$12.4K`, `1250000` → `$1.3M`, `950` → `$950`
  static String compactUsd(double value) {
    final double abs = value.abs();
    final String sign = value < 0 ? '-' : '';
    if (abs >= 1e6) return '$sign\$${_trim(abs / 1e6)}M';
    if (abs >= 1e3) return '$sign\$${_trim(abs / 1e3)}K';
    return '$sign\$${abs.toStringAsFixed(0)}';
  }

  /// `2400` → `$2,400`
  static String usd(double value) => '\$${thousands(value.round())}';

  /// `0.968` → `96.8%`
  static String percent(double ratio, {int fractionDigits = 1}) {
    return '${(ratio * 100).toStringAsFixed(fractionDigits)}%';
  }

  /// `DateTime` → `14:05:09`
  static String clock(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }

  /// `2516582` → `2.4 MB`
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String _trim(double value) {
    final String fixed = value.toStringAsFixed(1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }
}
