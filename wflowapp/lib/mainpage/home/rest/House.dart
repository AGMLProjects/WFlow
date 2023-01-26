import 'dart:convert';

import 'package:http/http.dart';

class House {
  final String name;
  final double consumes;

  const House({required this.name, this.consumes = 0});
}
