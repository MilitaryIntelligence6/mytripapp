import 'dart:async';
import 'dart:convert';
import 'package:flutter_ctrip/model/home_model.dart';
import 'package:http/http.dart' as Http;

/// 首页大接口
class HomeDao {

  static const String HOME_URL =
      "https://cdn.lishaoy.net/ctrip/homeConfig.json";

  static Future<HomeModel> fetch() async {
    final Http.Response response = await Http.get(HOME_URL);
    if (response.statusCode == 200) {
      Utf8Decoder utf8decoder = new Utf8Decoder();
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      return HomeModel.fromJson(result);
    } else {
      throw new Exception("Failed to load home_page.json");
    }
  }
}
