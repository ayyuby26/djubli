import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:djubli/model/car_model.dart';
import 'package:flutter/material.dart';

class CarProvider {
  static Future<List<CarModel>?> fetch() async {
    var dio = Dio();
    const api = "https://be-dev.djubli.com/api/cars/testCar?limit=10";
    Response response;

    try {
      response = await dio.get(api);
      final temp = response.data['data'] as List;
      FlutterClipboard.copy("$response.data");
      return temp.map((e) => CarModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Car Provider Error: $e");
    }
  }
}
