import 'dart:convert';
import 'package:http/http.dart';
import 'package:wflowapp/main/home/client/MonthExpense.dart';

class ExpensesResponse {
  final int code;
  final List<MonthExpense> months;
  final String message;

  const ExpensesResponse(
      {required this.code, required this.months, required this.message});

  factory ExpensesResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    List<dynamic> _dmonths = json['months'];
    List<MonthExpense> months = [];
    for (var _dmonth in _dmonths) {
      MonthExpense month = MonthExpense(
          date: _dmonth['date'],
          cost: _dmonth['cost'],
          total: _dmonth['total']);
      months.add(month);
    }
    return ExpensesResponse(
      code: response.statusCode,
      months: months,
      message: json['message'],
    );
  }
}
