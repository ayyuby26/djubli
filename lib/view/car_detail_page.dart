import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:djubli/cons/const.dart';
import 'package:djubli/helper/helper.dart';
import 'package:djubli/model/car_model.dart';
import 'package:djubli/widget/pic_swiper.dart';
import 'package:djubli/widget/ripple_button_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class CarDetailPage extends StatefulWidget {
  final CarModel data;
  const CarDetailPage(this.data, {Key? key}) : super(key: key);

  @override
  _CarDetailPageState createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  final CarouselController _controller = CarouselController();
  int _current = 0;
  var controller = MapController(location: LatLng(35.68, 51.41));

  @override
  void initState() {
    if (mounted) {
      final loc = widget.data.location.split(",");
      final lat = double.tryParse(loc[0]) ?? 0.0;
      final long = double.tryParse(loc[1]) ?? 0.0;
      setState(() {
        controller = MapController(
          location: LatLng(lat, long),
        );
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar,
      body: SafeArea(
        child: ListView(
          children: [
            imagesSlider,
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      price,
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black87,
                        ),
                        child: Text(
                          "${widget.data.usedFrom}",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.data.brandName + " - " + widget.data.groupModelName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    idrFormat(widget.data.km) + " KM",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Interior",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.data.interiorGalery.length,
                      itemBuilder: (context, index) {
                        final data = widget.data.interiorGalery[index];
                        return interior(data, index);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  desc,
                ],
              ),
            ),
            map,
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    widget.data.address,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle_rounded,
                        color: Colors.black54,
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  "User",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.check,
                                  size: 15,
                                  color: Colors.green,
                                )
                              ],
                            ),
                            Text(widget.data.user.email),
                            const SizedBox(height: 7),
                            Text(widget.data.user.phone),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  get map => SizedBox(
        width: double.maxFinite,
        height: 150,
        child: MapLayoutBuilder(
          controller: controller,
          builder: (context, transformer) {
            final centerLocation = Offset(
                transformer.constraints.biggest.width / 2,
                transformer.constraints.biggest.height / 2);

            final centerMarkerWidget =
                _buildMarkerWidget(centerLocation, Colors.purple);

            return Listener(
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  Map(
                    controller: controller,
                    builder: (context, x, y, z) {
                      return CachedNetworkImage(
                        imageUrl: mapUrl(x, y, z),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  centerMarkerWidget,
                ],
              ),
            );
          },
        ),
      );
  Text get price => Text(
        "Rp" + idrFormat(widget.data.price),
        maxLines: 3,
        style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 20,
          // color: Colors.blueGrey,
        ),
      );

  get desc => Text(
        widget.data.description,
        maxLines: 3,
        style: const TextStyle(
          fontSize: 14,
          // color: Colors.blueGrey,
        ),
      );

  get topBar => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          splashRadius: 20,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.black87,
            size: 18,
          ),
        ),
        title: Text(
          widget.data.modelName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      );

  get dotImages => Container(
        height: 280,
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.data.exteriorGalery.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      );

  get imagesSlider => Stack(
        children: [
          SizedBox(
            width: double.maxFinite,
            height: 300,
            child: CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                enableInfiniteScroll: false,
                height: 400.0,
                viewportFraction: 1,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
              items: widget.data.exteriorGalery
                  .map(
                    (e) => RippleButtonWidget(
                        borderRadius: BorderRadius.circular(0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                final _images = (widget.data.exteriorGalery
                                    .map((e) => e.file.fileUrl)
                                    .toList());
                                return PicSwiper(
                                  index: _current,
                                  pics: _images,
                                );
                              },
                            ),
                          );
                        },
                        child: Images(e)),
                  )
                  .toList(),
            ),
          ),
          dotImages,
        ],
      );

  Widget _buildMarkerWidget(Offset pos, Color color) {
    return Positioned(
      left: pos.dx - 16,
      top: pos.dy - 16,
      width: 24,
      height: 24,
      child: Icon(Icons.location_on, color: color),
    );
  }

  Widget interior(GaleryCarModel e, int i) {
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: RippleButtonWidget(
        borderRadius: BorderRadius.circular(0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                final _images = (widget.data.interiorGalery
                    .map((e) => e.file.fileUrl)
                    .toList());
                return PicSwiper(
                  index: i,
                  pics: _images,
                );
              },
            ),
          );
        },
        child: Image.network(
          e.file.fileUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black12,
            width: 70,
            height: 70,
            child: const Icon(
              Icons.error,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class Images extends StatelessWidget {
  GaleryCarModel images;
  Images(this.images, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Image.network(
        images.file.fileUrl,
        width: double.maxFinite,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.black12,
          width: double.maxFinite,
          height: 300,
          child: const Icon(
            Icons.error,
            color: Colors.black54,
          ),
        ),
      );
    });
  }
}
