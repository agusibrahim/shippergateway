import 'package:dart_frog/dart_frog.dart';
import 'package:dio/dio.dart' as d;

Future<Response> onRequest(RequestContext context) async {
  return Response(body: "${(await d.Dio().post("https://httpbin.org/post", data: "hello")).data}");
}
