import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models.dart';
class ApiClient {
  String get base => kIsWeb ? 'http://127.0.0.1:8000/api/v1' : (Platform.isAndroid ? 'http://10.0.2.2:8000/api/v1' : 'http://127.0.0.1:8000/api/v1');
  Future<PrincessOutfit> generate(BodyType body,String occasion,String style,double? budget) async {
    final r=await http.post(Uri.parse('$base/princess-mode'),headers:{'Content-Type':'application/json'},body:jsonEncode({
      'body_type':body.apiValue,'occasion':occasion,'preferred_style':style,'budget_eur':budget
    }));
    if(r.statusCode<200||r.statusCode>=300) throw Exception('API ${r.statusCode}: ${r.body}');
    return PrincessOutfit.fromJson(jsonDecode(r.body));
  }
}
