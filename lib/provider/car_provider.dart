import 'package:dio/dio.dart';
import 'package:djubli/model/car_model.dart';

class CarProvider {
  static Future<List<CarModel>?> fetch() async {
    var dio = Dio();
    const _api = "https://be-dev.djubli.com/api/cars/testCar?limit=10";
    Response response;

    try {
      response = await dio.get(_api);
      final temp = response.data['data'] as List;
      // print(response.data.toString());
      return temp.map((e) => CarModel.fromJson(e)).toList();
    } catch (e) {
      print("Car Provider Error: $e");
    }
  }
}
