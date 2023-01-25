import 'dart:convert';

import 'package:http/http.dart';

class House {
  final String name;
  final int consumes;

  const House({required this.name, required this.consumes});
}
