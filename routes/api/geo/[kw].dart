import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String kw) {
  return Response(body: 'post location keyword: $kw');
}
