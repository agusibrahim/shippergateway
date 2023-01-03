// ignore_for_file: prefer_single_quotes

import 'package:dart_frog/dart_frog.dart';
import 'package:dio/dio.dart' as d;
import 'dart:convert';
import '../../../main.dart' show httpr;

Future<Response> onRequest(RequestContext context) async {
  var param = context.request.uri.queryParameters;
  if (!param.containsKey("org_lat") ||
      !param.containsKey("org_lng") ||
      !param.containsKey("des_lat") ||
      !param.containsKey("des_lng") ||
      !param.containsKey("org_id") ||
      !param.containsKey("des_id") ||
      !param.containsKey("panjang") ||
      !param.containsKey("lebar") ||
      !param.containsKey("tinggi") ||
      !param.containsKey("berat") ||
      !param.containsKey("harga")) {
    return Response.json(body: {"status": "ERROR", "msg": "please provide required param"});
  }
  var org_areaid = utf8.decode(base64.decode(param['org_id'] ?? "")).split("_");
  var des_areaid = utf8.decode(base64.decode(param['des_id'] ?? "")).split("_");
  if (org_areaid.length != 2) {
    return Response.json(body: {"status": "ERROR", "msg": "invalid org_id"});
  }
  if (des_areaid.length != 2) {
    return Response.json(body: {"status": "ERROR", "msg": "invalid des_id"});
  }

  var q = {
    "cod": false,
    "origin": {
      "area_id": int.parse(org_areaid[1]),
      "lat": param['org_lat'],
      "lng": param['org_lng'],
      "suburb_id": int.parse(org_areaid[0]),
    },
    "for_order": true,
    "height": int.parse(param['tinggi'] ?? '5'),
    "item_value": int.parse(param['harga'] ?? '0'),
    "length": int.parse(param['panjang'] ?? '10'),
    "limit": 50,
    "destination": {
      "area_id": int.parse(des_areaid[1]),
      "lat": param['des_lat'],
      "lng": param['des_lng'],
      "suburb_id": int.parse(des_areaid[0])
    },
    "page": 1,
    "sort_by": ["final_price"],
    "weight": int.parse(param['berat'] ?? '1'),
    "width": int.parse(param['lebar'] ?? '5')
  };
//  print(json.encode(q));

  var r = await httpr.post("/pricing/domestic", data: q, options: d.Options(
    validateStatus: (status) {
      return status! < 500;
    },
  ));
  var fares = [];
  r.data['data']['pricings'].forEach((e) {
    var d = {
      "id": e["logistic"]['id'],
      "name": e["logistic"]['name'],
      "logo": e["logistic"]['logo_url'],
      "fare": [],
    };
    if (fares.map((ef) => ef['id']).contains(e['logistic']['id'])) {
      fares = fares.map((f) {
        if (f['id'] == e['logistic']['id']) {
          f['fare'].add({
            "name": e['rate']['name'],
            "fare_id": e['rate']['id'],
            "price": e['final_price'],
            "min_day": e['min_day'],
            "max_day": e['max_day'],
            "type": e['rate']['type'],
            "desc": e['rate']['description']
          });
        }
        return f;
      }).toList();
    } else {
      d['fare'].add({
        "name": e['rate']['name'],
        "fare_id": e['rate']['id'],
        "price": e['final_price'],
        "min_day": e['min_day'],
        "max_day": e['max_day'],
        "insurance_fee": e["insurance_fee"],
        "must_user_insurance": e['must_use_insurance'],
        "type": e['rate']['type'],
        "desc": e['rate']['description']
      });
      fares.add(d);
    }
  });
  return Response.json(body: {
    "status": "OK",
    "msg": "berhasil mendapatkan harga",
    "data": {
      "location": {"org": r.data['data']['origin'], "des": r.data['data']['destination']},
      "fares": fares,
    }
  });
}
