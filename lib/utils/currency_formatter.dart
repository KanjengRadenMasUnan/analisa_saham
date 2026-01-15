import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;
    
    double value = double.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    String newText = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(value).trim();
    
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}