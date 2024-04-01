//Dart:
import 'dart:convert';
import 'dart:async';

//Http:
import 'package:http/http.dart' as http;

const searchLocationAccessToken =
    "pk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsa3JpOXNudDB2dG8zcXFtN3RqYzk2ZngifQ.OjfZuB4ku290h-qvB-BecA";

const searchLocationSessionToken = '08aed845-b073-4761-88dd-bb2059d0caa8';

Future<Map<String, dynamic>> getSearches(controllerResponseInputSearch) async {
  String inputValue = controllerResponseInputSearch.text;
  var url = Uri.https('api.mapbox.com', '/search/searchbox/v1/suggest', {
    'q': inputValue,
    'language': 'es',
    'country': 'mx',
    'proximity': '-99.23426591658529, 18.921791278067488',
    'session_token': searchLocationSessionToken,
    'access_token': searchLocationAccessToken
  });
  var response = await http.get(url);
  Map<String, dynamic> jsonData = jsonDecode(response.body);
  return jsonData;
}
