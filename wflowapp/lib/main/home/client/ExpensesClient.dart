import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/home/client/ExpensesResponse.dart';

class ExpensesClient {
  final String url;
  final String path;

  const ExpensesClient({required this.url, required this.path});

  Future<ExpensesResponse> getExpenses(String token) async {
    String body = jsonEncode(<String, String>{'token': token});
    log(name: 'HTTP', 'Calling $path with body: $body');
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return ExpensesResponse.fromResponse(response);
  }
}
