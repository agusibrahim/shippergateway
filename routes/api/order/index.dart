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
      !param.containsKey("tinggi") ||
      !param.containsKey("lebar") || //batas
      !param.containsKey("penerima_name") ||
      !param.containsKey("penerima_phone") ||
      !param.containsKey("pengirim_name") ||
      !param.containsKey("pengirim_phone") ||
      !param.containsKey("jenis") ||
      !param.containsKey("des_addr") ||
      !param.containsKey("org_addr") ||
      !param.containsKey("fare_id") ||
      !param.containsKey("berat") || //end batas
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
    "consignee": {"name": param['penerima_name'], "phone_number": param['penerima_phone']},
    "consigner": {
      "name": param['pengirim_name'],
      "email": "agusibrahim@gmail.com",
      "phone_number": param['pengirim_phone']
    },
    "courier": {"cod": false, "rate_id": int.parse(param['fare_id'] ?? '0'), "use_insurance": true},
    "coverage": "domestic",
    "destination": {
      "address": param['des_addr'],
      "area_id": int.parse(des_areaid[1]),
      "lat": param['des_lat'],
      "lng": param['des_lng']
    },
//    "external_id": "KRN00313121JOSS",
    "origin": {
      "address": param['org_addr'],
      "area_id": int.parse(org_areaid[1]),
      "lat": param['org_lat'],
      "lng": param['org_lng']
    },
    "package": {
      "height": int.parse(param['tinggi'] ?? '5'),
      "length": int.parse(param['panjang'] ?? '5'),
      "items": [
        {"name": param['jenis'], "price": int.parse(param['harga'] ?? '50000'), "qty": 1}
      ],
      "package_type": 2,
      "price": int.parse(param['harga'] ?? '50000'),
      "weight": double.parse(param['berat'] ?? '1.1'),
      "width": int.parse(param['lebar'] ?? '5')
    },
    "payment_type": "postpay"
  };
  var r = await httpr.post("/order", data: q, options: d.Options(
    validateStatus: (status) {
      return status! < 500;
    },
  ));

  return Response.json(body: {"status": "OK", "msg": "berhasil mendapatkan harga", "data": r.data['data']});
}
