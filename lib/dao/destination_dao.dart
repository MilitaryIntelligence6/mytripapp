import "dart:async";
import "dart:convert";

import "package:flutter_ctrip/model/destination_model.dart";
import "package:http/http.dart" as http;

//旅拍搜索接口
class DestinationDao {

  DestinationDao._();

  static const Map<String, Object> PARAMS = {
    "contentType":"json",
    "head":{
      "cid":"09031043410934928682",
      "ctok":"",
      "cver":"1.0",
      "lang":"01",
      "sid":"8888",
      "syscode":"09",
      "auth":"","extension": []
    },
    "channel":"H5",
    "businessUnit":14,
    "startCity":2
  };

  static const String URL = "https://sec-m.ctrip.com/restapi/soa2/14422/navigationInfo?_fxpcqlniredt=09031043410934928682";

  static Future<DestinationModel> fetch() async {
    final response = await http.post(URL, body: jsonEncode(PARAMS));
    if (response.statusCode == 200) {
      // fix 中文乱码;
      Utf8Decoder utf8decoder = Utf8Decoder();
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      return DestinationModel.fromJson(result);
    } else {
      throw Exception("Failed to load travel");
    }
  }
}
