// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dio/dio.dart' as d;

late d.Dio httpr;
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  httpr = d.Dio(
    d.BaseOptions(
      baseUrl: 'https://merchant-api-sandbox.shipper.id/v3',
      headers: {
        'X-API-Key': 'KcFb0nOExMjrAukbtzHYw3RkXvGvR4AR0pdZjTPSYvLxfnQcUrDOvQofPmFXRLtl',
        'Content-Type': 'application/json'
      },
    ),
  );
  return serve(handler, ip, 8082);
}
