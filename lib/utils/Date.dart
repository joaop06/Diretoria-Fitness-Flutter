import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Date {
  Object? date = Date.now();

  Date({
    this.date,
  });

  static DateTime now() {
    return DateTime.now();
  }

  DateTime add(int days) {
    date ??= Date.now();
    return (date as DateTime).add(Duration(days: days));
  }

  static DateTime year(int year) {
    return DateTime(year);
  }

  static DateTime parse(Object? date) {
    return DateTime.parse(date.toString());
  }

  static DateTimeRange range({
    DateTime? end,
    DateTime? start,
    bool? now = false,
  }) {
    end = now == true || end == null ? Date.now() : end;
    start = now == true || start == null ? Date.now() : start;

    if (start.isAfter(end)) {
      end = start;
    }

    return DateTimeRange(end: end, start: start);
  }

  String format([String? type = 'dd/MM/yyyy']) {
    date ??= Date.now();
    if (date is DateTime) {
      return DateFormat(type).format((date as DateTime));
    } else if (date is String) {
      try {
        final parsedDate = Date.parse(date);
        return DateFormat(type).format(parsedDate);
      } catch (e) {
        throw ArgumentError('O valor fornecido não é uma data válida.');
      }
    } else {
      throw ArgumentError('O parâmetro date deve ser uma String ou DateTime.');
    }
  }
}
