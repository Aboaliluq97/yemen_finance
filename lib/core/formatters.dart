String formatAmount(
  double amount, {
  bool arabicDigits = false,
  int decimalDigits = 0,
}) {
  final bool isNegative = amount.isNegative;

  final String source = amount.abs().toStringAsFixed(
        decimalDigits,
      );

  final List<String> parts = source.split('.');

  final String integerPart = parts.first;

  final StringBuffer formattedInteger = StringBuffer();

  for (int index = 0; index < integerPart.length; index++) {
    final int remaining = integerPart.length - index;

    formattedInteger.write(integerPart[index]);

    if (remaining > 1 && remaining % 3 == 1) {
      formattedInteger.write(',');
    }
  }

  String result = formattedInteger.toString();

  if (parts.length > 1 && decimalDigits > 0) {
    result = '$result.${parts.last}';
  }

  if (isNegative) {
    result = '-$result';
  }

  if (arabicDigits) {
    result = toArabicDigits(result);
  }

  return result;
}

String toArabicDigits(String value) {
  const Map<String, String> digits = <String, String>{
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  return value
      .split('')
      .map(
        (String character) => digits[character] ?? character,
      )
      .join();
}

double? parseFinancialAmount(String value) {
  final String normalized = value
      .trim()
      .replaceAll(',', '')
      .replaceAll('٬', '')
      .replaceAll('٫', '.');

  if (normalized.isEmpty) {
    return null;
  }

  return double.tryParse(normalized);
}
