import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:djubli/model/car_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarProvider {
  static Future<List<CarModel>?> fetch() async {
    var dio = Dio();
    const _api = "https://be-dev.djubli.com/api/cars/testCar?limit=10";
    Response response;

    try {
      response = await dio.get(_api);
      final temp = response.data['data'] as List;
      // debugPrint("HGJK: " + .toString(), wrapWidth: 2048);
      FlutterClipboard.copy("$response.data");
      return temp.map((e) => CarModel.fromJson(e)).toList();
    } catch (e) {
      print("Car Provider Error: $e");
    }
  }
}
