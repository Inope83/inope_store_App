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
    final dollar = price ~/ 1;
    final cent = ((price - dollar) * 100).round();
    final formattedDollar = dollar.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$currencySymbol$formattedDollar,${cent.toString().padLeft(2, '0')}';
  }
}
