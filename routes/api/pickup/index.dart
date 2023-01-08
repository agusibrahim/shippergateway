import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import '../../../main.dart' show httpr;
import 'package:dio/dio.dart' as d;

Future<Response> onRequest(RequestContext context) async {
  var param = context.request.uri.queryParameters;
  if (!param.containsKey("order_id")) {
    return Response.json(body: {"status": "ERROR", "msg": "please provide order_id"});
  }
  var payload = {};
  var hastime = 0;
  if (param.containsKey("time")) {
    payload = {
      "data": {
        "order_activation": {
          "order_id": [param['order_id']],
          "pickup_time": param["time"]
        }
      }
    };
    hastime = 1;
  } else if (param.containsKey("start") && param.containsKey("end")) {
    payload = {
      "data": {
        "order_activation": {
          "order_id": [param['order_id']],
          "timezone": "Asia/Jakarta",
          "start_time": param["start"],
          "end_time": param["end"]
        }
      }
    };
    hastime = 2;
  }
  if (hastime == 0) {
    return Response.json(body: {"status": "ERROR", "msg": "please provide time or start/end time"});
  }
  print(json.encode(payload));
  var r =
      await httpr.post("/pickup${hastime == 2 ? '/timeslot' : ''}", data: payload, options: d.Options(validateStatus: (status) {
    return status! < 500;
  }));
  print("Resrp: ${r.data}");
  return Response.json(body: {"status": "OK", "msg": "berhasil request pickup", "data": r.data['data']});
}
