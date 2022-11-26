import 'package:dart_frog/dart_frog.dart';
import 'package:dio/dio.dart' as d;
import 'dart:convert';

import '../../../main.dart' show httpr;

Future<Response> onRequest(RequestContext context) async {
  var param = context.request.uri.queryParameters;
  if (!param.containsKey("kw")) {
    return Response.json(body: {"status": "ERROR", "msg": "please provide keyword"});
  }
  var r = await httpr.get(
    "/location?keyword=${Uri.encodeFull(param['kw'] ?? "")}&limit=${param['limit'] ?? 30}",
  );
  var data = (r.data['data'] as List<dynamic>).map((e) {
    var d = {};
    var ids = {};
    e.forEach((key, value) {
      if (value is Map) {
        var m = Map<String, dynamic>.from(value);
        if (['area', 'suburb'].contains(m['type']) && key != "adm_level_cur") {
          ids["${m['type']}"] = m['id'];
        }
        if (m.containsKey("geo_coord")) {
          if ((m['geo_coord'] as Map<String, dynamic>)['lat'] != 0) {
            if (m['type'] == "area") {
              d['geo_coord'] = m['geo_coord'];
            } else if (m['type'] == "suburb") {
              d['geo_coord'] = m['geo_coord'];
            } else if (m['type'] == "city") {
              d['geo_coord'] = m['geo_coord'];
            }
          }
        }
        d[m['type']] = m['name'];
      }
    });
    //_${d['geo_coord']['lat']}:${d['geo_coord']['lng']}
    d['id'] = base64.encode(utf8.encode("${ids['suburb']}_${ids['area']}"));
    d['display_txt'] = e['display_txt'];
    return d;
  }).toList();

  return Response.json(body: {"status": "OK", "msg": "berhasil mendapatkan lokasi", "data": data});
}
