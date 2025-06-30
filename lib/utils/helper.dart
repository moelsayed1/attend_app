import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime parseDateTime(String strDate) {
  if (strDate.contains('/')) {
    // Assuming dd/MM/yyyy format
    return DateFormat('dd/MM/yyyy').parse(strDate);
  } else if (strDate.contains('-')) {
    // Assuming yyyy-MM-dd format
    return DateFormat('yyyy-MM-dd').parse(strDate);
  } else {
    return DateTime.parse(strDate);
  }
}

DateFormat formatDateTime(String format) => DateFormat(format);

String dateFormatted({required String date, required String formatType}) =>
    formatDateTime(formatType).format(parseDateTime(date));

enum FormatType {
  dateTime,
  date,
  time,
  ddMMMYYYY,
  day,
  ddMMyyyy,
}

String getDateFormmatted(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd');
  final formattedDate = formatter.format(date);
  return formattedDate;
}

String formatForDateTime(FormatType formatType) {
  switch (formatType) {
    case FormatType.date:
      {
        return "MMM dd yyyy";
      }
    case FormatType.dateTime:
      {
        return "dd-MM-yyyy hh:mm a";
      }
    case FormatType.time:
      {
        return "hh:mm a";
      }
    case FormatType.ddMMMYYYY:
      {
        return "dd MMM,yyyy";
      }
    case FormatType.day:
      {
        return "EEEE";
      }
    case FormatType.ddMMyyyy:
      {
        return "dd/MM/yyyy";
      }
  }
}

double parseWcPrice(String? price) => (double.tryParse(price ?? "0") ?? 0);

enum SymbolPositionType { left, right }

const SymbolPositionType appCurrencySymbolPosition = SymbolPositionType.left;

class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex = "FF${hex.toUpperCase().replaceAll("#", "")}";
    return int.parse(formattedHex, radix: 16);
  }

  HexColor(final String hex) : super(_getColor(hex));
}
