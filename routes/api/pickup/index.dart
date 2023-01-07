import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import '../../../main.dart' show httpr;
import 'package:dio/dio.dart' as d;

Future<Response> onRequest(RequestContext context) async {
  var param = context.request.uri.queryParameters;
  if (!param.containsKey("order_id") && !param.containsKey("time")) {
    return Response.json(body: {"status": "ERROR", "msg": "please provide order_id and time pickup"});
  }
  var payload = {
    "data": {
      "order_activation": {
        "order_id": [param['order_id']],
        "pickup_time": param['time']
      }
    }
  };
//  print(json.encode(payload));
  var r = await httpr.post("/pickup", data: payload, options: d.Options(validateStatus: (status) {
    return status! < 500;
  }));
  //print("Resrp: ${r.data}");
  return Response.json(body: {"status": "OK", "msg": "berhasil request pickup", "data": r.data['data']});
}
