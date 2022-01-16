import 'package:clipboard/clipboard.dart';
import 'package:djubli/helper/helper.dart';
import 'package:djubli/model/car_model.dart';
import 'package:djubli/provider/car_provider.dart';
import 'package:djubli/repository/scatter_repository.dart';
import 'package:djubli/view/car_detail_page.dart';
import 'package:djubli/widget/ripple_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:intl/intl.dart';

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
  final controller = PageController(viewportFraction: .8);

  List<CarModel>? data;
  void fetch() async {
    final ddc = await CarProvider.fetch();
    if (ddc != null) {
      setState(() {
        data = ddc;
        extraScript = repo.extraScript(data!);
        option = repo.optionData;
      });
    }
  }

  void listenCard() {
    controller.addListener(() {
      final i = controller.page;
      if (i != null && (i % 1) == 0) {
        final temp = extraScript;
        final index = i.round();
        final point = repo.highlightPoint(index);
        setState(() {
          extraScript = temp + point;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      listenCard();
      fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/logo.png",
                    width: 85,
                  ),
                ),
                search()
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: extraScript.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Echarts(
                            theme: 'wonderland',
                            key: UniqueKey(),
                            captureAllGestures: true,
                            extraScript: extraScript,
                            option: option,
                          ),
                  ),
                  if (extraScript.isNotEmpty)
                    SizedBox(
                      height: 200,
                      width: double.maxFinite,
                      child: PageView(
                        controller: controller,
                        children: data!.map((e) => CardWidget(e)).toList(),
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  search() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            width: double.maxFinite,
            margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
            // padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RippleButtonWidget(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: const [
                    Icon(
                      Icons.search,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Cari Mobil",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 10, left: 5),
          child: RippleButtonWidget(
            isBlackRipple: true,
            borderRadius: BorderRadius.circular(10),
            onTap: () {},
            child: const Icon(
              Icons.filter_alt,
              color: Colors.black54,
            ),
          ),
        )
      ],
    );
  }
}

class CardWidget extends StatelessWidget {
  final CarModel data;

  const CardWidget(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 20, 25),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withOpacity(.1),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RippleButtonWidget(
        isBlackRipple: true,
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailPage(data),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(10),
              ),
              child: Image.network(
                data.exteriorGalery[0].file.fileUrl,
                width: 120,
                height: 200,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(10),
                      ),
                      color: Colors.black12),
                  width: 120,
                  height: double.maxFinite,
                  child: const Icon(
                    Icons.error,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.modelName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      "Rp" + idrFormat(data.price),
                      maxLines: 3,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        // color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      data.brandName + " - " + data.groupModelName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      "${data.usedFrom}",
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      idrFormat(data.km) + " KM",
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
