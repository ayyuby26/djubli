import 'dart:convert';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:djubli/model/car_model.dart';
import 'package:djubli/provider/car_provider.dart';
import 'package:djubli/repository/scatter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var trigger = '';
  var extraScript = '';
  var option = '';
  var highlightPoint = '';
  final repo = Repository();

  List<CarModel>? data;
  void fetch() async {
    final ddc = await CarProvider.fetch();
    if (ddc != null) {
      setState(() {
        data = ddc;
        extraScript = repo.extraScript(data!);
        option = repo.optionData;

        // FlutterClipboard.copy(option);
      });
    }
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Djubli"),
          actions: [
            Container(
              decoration: BoxDecoration(),
              child: Row(
                children: [
                  Icon(Icons.search),
                  Text("Cari Mobil"),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                child: extraScript.isEmpty
                    ? const CircularProgressIndicator()
                    : Echarts(
                        key: UniqueKey(),
                        captureAllGestures: true,
                        onMessage: (p0) {
                          print("==================== $p0");
                        },
                        // theme: 'dark',
                        extraScript: extraScript,
                        option: option,
                      ),
                width: double.maxFinite,
                height: 450,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final optionTemp = extraScript;
                      extraScript = optionTemp + repo.highlightPoint(0);
                    });
                  },
                  child: Text("data"))
            ],
          ),
        ),
      ),
    );
  }
}
