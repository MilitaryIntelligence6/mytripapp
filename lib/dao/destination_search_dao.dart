import "dart:async";
import "dart:convert";

import "package:flutter_ctrip/model/destination_search_model.dart";
import "package:flutter_ctrip/model/travel_search_model.dart";
import "package:http/http.dart" as http;

//旅拍搜索接口
class DestinationSearchDao {

  DestinationSearchDao._();

  static const Map<String, Object> PARAMS = {
    "contentType":"json",
    "head":{
      "cid":"09031043410934928682",
      "ctok":"",
      "cver":"1.0",
      "lang":"01",
      "sid":"8888",
      "syscode":"09",
      "auth":"",
      "extension":[]
    },
    "keyword":"h",
    "channel":"H5",
    "sourceVersion":"823000",
    "tab":"1",
    "saleCity":2,
    "departureCity":2
  };

  static Future<DestinationSearchModel> fetch(
      String url, String keyword) async {
    PARAMS["keyword"] = keyword;

    final response = await http.post(url, body: jsonEncode(PARAMS));
    if (response.statusCode == 200) {
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      DestinationSearchModel model = DestinationSearchModel.fromJson(result);
      model.keyword = keyword;
      return model;
    } else {
      throw Exception("Failed to load travel");
    }
  }
}
