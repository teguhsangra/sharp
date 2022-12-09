import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/model/checklist_result.dart';
import 'package:telkom/model/tenant.dart';

class Network {
  final String _url = 'http://178.128.126.205:3024/api/';
  // 192.168.1.2 is my IP, change with your IP address
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString("token") ?? "\"\"");
  }

  auth(data, apiURL) async {
    var fullUrl = _url + apiURL;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(apiURL) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.get(
      Uri.parse(fullUrl),
      headers: _setHeaders(),
    );
  }

  getTenant(apiURL) async {
    try {
      var url = Uri.parse(_url + apiURL);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = response.body;

        return tenantFromJson(data);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  postUrl(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data),headers: _setHeaders());
  }

  getChecklistDetail(apiURL) async {
    try {
      var url = Uri.parse(_url + apiURL);
      await _getToken();
      var response = await http.get(
        url,
        headers: _setHeaders(),
      );
      if (response.statusCode == 200) {
        var data = response.body;

        log('Checklist Result :$data');

        return ChecklistResult.fromJson(jsonDecode(data));
      }
    } catch (e) {
      log(e.toString());
    }
  }

  postCheckIn(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  postCheckOut(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.put(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  submitChecklist(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.put(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  updateProfile(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  updatePassword(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  postRequestOrder(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  putRequestOrder(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.put(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  postLastPosition(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.put(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  postRequestOTP(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data),headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        });
  }

  postResetPassword(apiURL, data) async {
    var fullUrl = _url + apiURL;
    await _getToken();
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        });
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}