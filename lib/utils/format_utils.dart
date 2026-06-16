class FormatUtils {
  static const String currencySymbol = r'$';

  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static String formatPrice(double price) {
    final intPart = price.toInt();
    final hasDecimal = (price - intPart) > 0.01;
    final formatted = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    if (hasDecimal) {
      final dec = ((price - intPart) * 100).round().toString().padLeft(2, '0');
      return '$currencySymbol$formatted,$dec';
    }
    return '$currencySymbol$formatted';
  }
}
