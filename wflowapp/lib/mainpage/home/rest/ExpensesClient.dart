import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wflowapp/mainpage/home/rest/ExpensesResponse.dart';

class ExpensesClient {
  final String url;
  final String path;

  const ExpensesClient({required this.url, required this.path});

  Future<ExpensesResponse> getExpenses(String token) async {
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'token': token}),
    );
    return ExpensesResponse.fromResponse(response);
  }
}
