import 'dart:async';
import 'dart:math';
import 'package:djubli/utils/util.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart' hide Image;
import 'hero.dart';

typedef DoubleClickAnimationListener = void Function();

class ImageDetailInfo {
  ImageDetailInfo({
    required this.imageDRect,
    required this.pageSize,
    required this.imageInfo,
  });
  final GlobalKey<State<StatefulWidget>> key = GlobalKey<State>();

  final Rect imageDRect;

  final Size pageSize;

  final ImageInfo imageInfo;

  double? _maxImageDetailY;
  double get imageBottom => imageDRect.bottom - 20;
  double get maxImageDetailY {
    try {
      //
      return _maxImageDetailY ??= max(
          key.currentContext!.size!.height - (pageSize.height - imageBottom),
          0.1);
    } catch (e) {
      //currentContext is not ready
      return 100.0;
    }
  }
}

class PicSwiperItem {
  PicSwiperItem({
    required this.picUrl,
    this.des = '',
  });
  final String picUrl;
  final String? des;
}

class PicSwiper extends StatefulWidget {
  const PicSwiper({
    this.index,
    this.pics,
  });
  final int? index;
  final List<String>? pics;
  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper> with TickerProviderStateMixin {
  final StreamController<int> rebuildIndex = StreamController<int>.broadcast();
  final StreamController<bool> rebuildSwiper =
      StreamController<bool>.broadcast();
  final StreamController<double> rebuildDetail =
      StreamController<double>.broadcast();
  final Map<int, ImageDetailInfo> detailKeys = <int, ImageDetailInfo>{};
  late AnimationController _doubleClickAnimationController;
  late AnimationController _slideEndAnimationController;
  late Animation<double> _slideEndAnimation;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
  int? _currentIndex = 0;
  bool _showSwiper = true;
  double _imageDetailY = 0;
  Rect? imageDRect;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    imageDRect = Offset.zero & size;
    Widget result = Material(

        /// if you use ExtendedImageSlidePage and slideType =SlideType.onlyImage,
        /// make sure your page is transparent background
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ExtendedImageGesturePageView.builder(
              controller: ExtendedPageController(
                initialPage: widget.index!,
                pageSpacing: 50,
                shouldIgnorePointerWhenScrolling: false,
              ),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              canScrollPage: (GestureDetails? gestureDetails) {
                return _imageDetailY >= 0;
                //return (gestureDetails?.totalScale ?? 1.0) <= 1.0;
              },
              itemBuilder: (BuildContext context, int index) {
                final String item = widget.pics![index];

                Widget image = ExtendedImage.network(
                  item,
                  fit: BoxFit.contain,
                  enableSlideOutPage: true,
                  mode: ExtendedImageMode.gesture,
                  imageCacheName: '',
                  initGestureConfigHandler: (ExtendedImageState state) {
                    double? initialScale = 1.0;

                    if (state.extendedImageInfo != null) {
                      initialScale = initScale(
                          size: size,
                          initialScale: initialScale,
                          imageSize: Size(
                              state.extendedImageInfo!.image.width.toDouble(),
                              state.extendedImageInfo!.image.height
                                  .toDouble()));
                    }
                    return GestureConfig(
                      inPageView: true,
                      initialScale: initialScale!,
                      maxScale: max(initialScale, 5.0),
                      animationMaxScale: max(initialScale, 5.0),
                      initialAlignment: InitialAlignment.center,
                      //you can cache gesture state even though page view page change.
                      //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                      cacheGesture: false,
                    );
                  },
                  onDoubleTap: (ExtendedImageGestureState state) {
                    ///you can use define pointerDownPosition as you can,
                    ///default value is double tap pointer down postion.
                    final Offset? pointerDownPosition =
                        state.pointerDownPosition;
                    final double? begin = state.gestureDetails!.totalScale;
                    double end;

                    //remove old
                    _doubleClickAnimation
                        ?.removeListener(_doubleClickAnimationListener);

                    //stop pre
                    _doubleClickAnimationController.stop();

                    //reset to use
                    _doubleClickAnimationController.reset();

                    if (begin == doubleTapScales[0]) {
                      end = doubleTapScales[1];
                    } else {
                      end = doubleTapScales[0];
                    }

                    _doubleClickAnimationListener = () {
                      //print(_animation.value);
                      state.handleDoubleTap(
                          scale: _doubleClickAnimation!.value,
                          doubleTapPosition: pointerDownPosition);
                    };
                    _doubleClickAnimation = _doubleClickAnimationController
                        .drive(Tween<double>(begin: begin, end: end));

                    _doubleClickAnimation!
                        .addListener(_doubleClickAnimationListener);

                    _doubleClickAnimationController.forward();
                  },
                  loadStateChanged: (ExtendedImageState state) {
                    if (state.extendedImageLoadState == LoadState.completed) {
                      final Rect imageDRect = getDestinationRect(
                        rect: Offset.zero & size,
                        inputSize: Size(
                          state.extendedImageInfo!.image.width.toDouble(),
                          state.extendedImageInfo!.image.height.toDouble(),
                        ),
                        fit: BoxFit.contain,
                      );

                      detailKeys[index] ??= ImageDetailInfo(
                        imageDRect: imageDRect,
                        pageSize: size,
                        imageInfo: state.extendedImageInfo!,
                      );
                      final ImageDetailInfo? imageDetailInfo =
                          detailKeys[index];
                      return StreamBuilder<double>(
                        builder:
                            (BuildContext context, AsyncSnapshot<double> data) {
                          return ExtendedImageGesture(
                            state,
                            canScaleImage: (_) => _imageDetailY == 0,
                            imageBuilder: (Widget image) {
                              return Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: image,
                                    top: _imageDetailY,
                                    bottom: -_imageDetailY,
                                  ),
                                  Positioned(
                                    left: 0.0,
                                    right: 0.0,
                                    top: imageDetailInfo!.imageBottom +
                                        _imageDetailY,
                                    child: Opacity(
                                      opacity: _imageDetailY == 0
                                          ? 0
                                          : min(
                                              1,
                                              _imageDetailY.abs() /
                                                  (imageDetailInfo
                                                          .maxImageDetailY /
                                                      4.0),
                                            ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        initialData: _imageDetailY,
                        stream: rebuildDetail.stream,
                      );
                    }
                    return null;
                  },
                );

                if (index < min(9, widget.pics!.length)) {
                  image = HeroWidget(
                    child: image,
                    tag: item,
                    slideType: SlideType.onlyImage,
                    slidePagekey: slidePagekey,
                  );
                }

                image = GestureDetector(
                  child: image,
                  onTap: () {
                    if (_imageDetailY != 0) {
                      _imageDetailY = 0;
                      rebuildDetail.sink.add(_imageDetailY);
                    } else {
                      slidePagekey.currentState!.popPage();
                      Navigator.pop(context);
                    }
                  },
                );

                return image;
              },
              itemCount: widget.pics!.length,
              onPageChanged: (int index) {
                _currentIndex = index;
                rebuildIndex.add(index);
                if (_imageDetailY != 0) {
                  _imageDetailY = 0;
                  rebuildDetail.sink.add(_imageDetailY);
                }
                _showSwiper = true;
                rebuildSwiper.add(_showSwiper);
              },
            ),
          ],
        ));

    result = ExtendedImageSlidePage(
      key: slidePagekey,
      child: result,
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.onlyImage,
      slideScaleHandler: (
        Offset offset, {
        ExtendedImageSlidePageState? state,
      }) {
        //image is ready and it's not sliding.
        if (state != null &&
            detailKeys[_currentIndex!] != null &&
            state.scale == 1.0) {
          //don't slide page if scale of image is more than 1.0
          if (state.imageGestureState!.gestureDetails!.totalScale! > 1.0) {
            return 1.0;
          }
          //or slide down into detail mode
          if (offset.dy < 0 || _imageDetailY < 0) {
            return 1.0;
          }
        }

        return null;
      },
      slideOffsetHandler: (
        Offset offset, {
        ExtendedImageSlidePageState? state,
      }) {
        //image is ready and it's not sliding.
        if (state != null &&
            detailKeys[_currentIndex!] != null &&
            state.scale == 1.0) {
          //don't slide page if scale of image is more than 1.0

          if (state.imageGestureState!.gestureDetails!.totalScale! > 1.0) {
            return Offset.zero;
          }

          //or slide down into detail mode
          if (offset.dy < 0 || _imageDetailY < 0) {
            _imageDetailY += offset.dy;

            // print(offset.dy);
            _imageDetailY = max(
                -detailKeys[_currentIndex!]!.maxImageDetailY, _imageDetailY);
            rebuildDetail.sink.add(_imageDetailY);
            return Offset.zero;
          }

          if (_imageDetailY != 0) {
            _imageDetailY = 0;
            _showSwiper = true;
            rebuildSwiper.add(_showSwiper);
            rebuildDetail.sink.add(_imageDetailY);
          }
        }
        return null;
      },
      slideEndHandler: (
        Offset offset, {
        ExtendedImageSlidePageState? state,
        ScaleEndDetails? details,
      }) {
        if (_imageDetailY != 0 && state!.scale == 1) {
          if (!_slideEndAnimationController.isAnimating) {
// get magnitude from gesture velocity
            final double magnitude = details!.velocity.pixelsPerSecond.distance;

            // do a significant magnitude

            if (magnitude.greaterThanOrEqualTo(minMagnitude)) {
              final Offset direction =
                  details.velocity.pixelsPerSecond / magnitude * 1000;

              _slideEndAnimation =
                  _slideEndAnimationController.drive(Tween<double>(
                begin: _imageDetailY,
                end: (_imageDetailY + direction.dy)
                    .clamp(-detailKeys[_currentIndex!]!.maxImageDetailY, 0.0),
              ));
              _slideEndAnimationController.reset();
              _slideEndAnimationController.forward();
            }
          }
          return false;
        }

        return null;
      },
      onSlidingPage: (ExtendedImageSlidePageState state) {
        ///you can change other widgets' state on page as you want
        ///base on offset/isSliding etc
        //var offset= state.offset;
        final bool showSwiper = !state.isSliding;
        if (showSwiper != _showSwiper) {
          // do not setState directly here, the image state will change,
          // you should only notify the widgets which are needed to change
          // setState(() {
          // _showSwiper = showSwiper;
          // });

          _showSwiper = showSwiper;
          rebuildSwiper.add(_showSwiper);
        }
      },
    );

    return result;
  }

  @override
  void dispose() {
    rebuildIndex.close();
    rebuildSwiper.close();
    rebuildDetail.close();
    _doubleClickAnimationController.dispose();
    _slideEndAnimationController.dispose();
    clearGestureDetailsCache();
    //cancelToken?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    _slideEndAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _slideEndAnimationController.addListener(() {
      _imageDetailY = _slideEndAnimation.value;
      if (_imageDetailY == 0) {
        _showSwiper = true;
        rebuildSwiper.add(_showSwiper);
      }
      rebuildDetail.sink.add(_imageDetailY);
    });
  }
}
