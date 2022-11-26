import 'package:dart_frog/dart_frog.dart';
import '../../../main.dart' show httpr;
import 'package:dio/dio.dart' as d;

Future<Response> onRequest(RequestContext context) async {
  var param = context.request.uri.queryParameters;
  if (!param.containsKey("order_id")) {
    return Response.json(body: {"status": "ERROR", "msg": "please provide order_id"});
  }
  var r = await httpr.get("/order/${param['order_id']}");
  return Response.json(body: {"status": "OK", "msg": "berhasil mendapatkan status", "data": r.data['data']});
}
