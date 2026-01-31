String _formatNumber(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  var intPart = parts[0];
  final decPart = parts[1];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    final pos = intPart.length - i;
    buffer.write(intPart[i]);
    if (pos > 1 && pos % 3 == 1) buffer.write(',');
  }
  // The above writes incorrectly (left-to-right); fix with reverse approach
  final rev = intPart.split('').reversed.toList();
  final chunks = <String>[];
  for (var i = 0; i < rev.length; i += 3) {
    chunks.add(rev.skip(i).take(3).toList().reversed.join());
  }
  final joined = chunks.reversed.join(',');
  return '$joined.$decPart';
}

String formatCurrency(double value, String symbol) {
  return '$symbol${_formatNumber(value)}';
}
