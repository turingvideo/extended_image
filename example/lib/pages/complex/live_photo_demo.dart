import 'package:example/assets.dart';

import 'package:example/common/utils/extension.dart';
import 'package:example/common/widget/hero.dart';
import 'package:example/example_routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

@FFRoute(
  name: 'fluttercandies://LivePhotoPage',
  routeName: 'LivePhotoPage',
  description: 'Simple demo for PhotoView.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 5,
  },
)
class LivePhotoPage extends StatefulWidget {
  @override
  _LivePhotoPageState createState() => _LivePhotoPageState();
}

class _LivePhotoPageState extends State<LivePhotoPage> {
  List<String> images = <String>[
    Assets.assets_c8abd91c6f1a5dbf4e4cc6811b0173d8_jpg,
    'https://photo.tuchong.com/14649482/f/601672690.jpg',
    'https://photo.tuchong.com/17325605/f/641585173.jpg',
    'https://photo.tuchong.com/3541468/f/256561232.jpg',
    'https://photo.tuchong.com/16709139/f/278778447.jpg',
    'https://photo.tuchong.com/15195571/f/233361383.jpg',
    'https://photo.tuchong.com/5040418/f/43305517.jpg',
    'https://photo.tuchong.com/3019649/f/302699092.jpg'
  ];
  bool _stopPlayLivePhotoWhenSlidingPage = false;
  bool _stopPlayLivePhotoWhenGesture = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Photo'),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text('stop play live photo when sliding page : '),
                  Checkbox(
                    value: _stopPlayLivePhotoWhenSlidingPage,
                    onChanged: (bool? value) {
                      setState(() {
                        _stopPlayLivePhotoWhenSlidingPage = value!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  const Text('stop play live photo when gesture : '),
                  Checkbox(
                    value: _stopPlayLivePhotoWhenGesture,
                    onChanged: (bool? value) {
                      setState(() {
                        _stopPlayLivePhotoWhenGesture = value!;
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final String url = images[index];

                    late ImageProvider image;

                    if (url.startsWith('https')) {
                      image = ExtendedNetworkImageProvider(url);
                    } else {
                      image = ExtendedAssetImageProvider(url);
                    }
                    return GestureDetector(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Hero(
                          tag: url,
                          child: ExtendedImage(
                            image: image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Routes.fluttercandiesLivePhotoPicsWiper.name,
                          arguments: Routes.fluttercandiesLivePhotoPicsWiper.d(
                            url: url,
                            images: images,
                            stopPlayLivePhotoWhenGesture:
                                _stopPlayLivePhotoWhenGesture,
                            stopPlayLivePhotoWhenSlidingPage:
                                _stopPlayLivePhotoWhenSlidingPage,
                          ),
                        );
                      },
                    );
                  },
                  itemCount: images.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@FFRoute(
  name: 'fluttercandies://LivePhotoPicsWiper',
  routeName: 'LivePhotoPicsWiper',
  description: 'demo for LivePhoto Pics Wiper.',
  pageRouteType: PageRouteType.transparent,
)
class LivePhotoPicsWiper extends StatefulWidget {
  const LivePhotoPicsWiper({
    super.key,
    required this.url,
    required this.images,
    this.stopPlayLivePhotoWhenSlidingPage = false,
    this.stopPlayLivePhotoWhenGesture = false,
  });
  final String url;
  final List<String> images;
  final bool stopPlayLivePhotoWhenSlidingPage;
  final bool stopPlayLivePhotoWhenGesture;
  @override
  State<LivePhotoPicsWiper> createState() => _LivePhotoPicsWiperState();
}

class _LivePhotoPicsWiperState extends State<LivePhotoPicsWiper> {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();

  final List<int> _cachedIndexes = <int>[];
  final BoxFit _fit = BoxFit.contain;
  final ValueNotifier<bool> _isSliding = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _gestureDetailsIsChanging =
      ValueNotifier<bool>(false);

  late VoidFunction _gestureDetailsChangeCompleted;

  @override
  void initState() {
    super.initState();

    _gestureDetailsChangeCompleted = () {
      _gestureDetailsIsChanging.value = false;
    }.debounce(const Duration(milliseconds: 100));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int index = widget.images.indexOf(widget.url);
    _preloadImage(index - 1);
    _preloadImage(index + 1);
  }

  void _preloadImage(int index) {
    if (_cachedIndexes.contains(index)) {
      return;
    }
    if (0 <= index && index < widget.images.length) {
      final String url = widget.images[index];
      if (url.startsWith('https:')) {
        precacheImage(ExtendedNetworkImageProvider(url, cache: true), context);
      }

      _cachedIndexes.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ExtendedImageSlidePage(
        key: slidePagekey,
        onSlidingPage: widget.stopPlayLivePhotoWhenSlidingPage
            ? (ExtendedImageSlidePageState state) {
                _isSliding.value = state.isSliding;
              }
            : null,
        child: GestureDetector(
          child: ExtendedImageGesturePageView.builder(
            controller: ExtendedPageController(
              initialPage: widget.images.indexOf(widget.url),
              pageSpacing: 50,
              shouldIgnorePointerWhenScrolling: false,
            ),
            itemCount: widget.images.length,
            onPageChanged: (int page) {
              _preloadImage(page - 1);
              _preloadImage(page + 1);
            },
            itemBuilder: (BuildContext context, int index) {
              final String url = widget.images[index];

              late ImageProvider image;

              if (url.startsWith('https')) {
                image = ExtendedNetworkImageProvider(url, cache: true);
              } else {
                image = ExtendedAssetImageProvider(url);
              }

              return HeroWidget(
                tag: url,
                slideType: SlideType.wholePage,
                slidePagekey: slidePagekey,
                child: ExtendedImage(
                  image: image,
                  fit: _fit,
                  mode: ExtendedImageMode.gesture,
                  enableSlideOutPage: true,
                  initGestureConfigHandler: (ExtendedImageState state) {
                    return GestureConfig(
                      //you must set inPageView true if you want to use ExtendedImageGesturePageView
                      inPageView: true,
                      initialScale: 1.0,
                      maxScale: 5.0,
                      animationMaxScale: 6.0,
                      initialAlignment: InitialAlignment.center,
                      gestureDetailsIsChanged:
                          widget.stopPlayLivePhotoWhenGesture
                              ? (GestureDetails? details) {
                                  _gestureDetailsIsChanging.value = true;
                                  _gestureDetailsChangeCompleted();
                                }
                              : null,
                    );
                  },
                  loadStateChanged: (ExtendedImageState state) {
                    if (state.extendedImageLoadState == LoadState.completed &&
                        state.imageProvider is ExtendedAssetImageProvider) {
                      String assetName =
                          (state.imageProvider as ExtendedAssetImageProvider)
                              .assetName;
                      assetName = assetName.replaceAll(
                          path.extension(assetName), '.mov');
                      return LivePhotoWidget(
                        videoUrl: assetName,
                        fit: _fit,
                        state: state,
                        isSliding: _isSliding,
                        gestureDetailsIsChanging: _gestureDetailsIsChanging,
                      );
                    }
                    return null;
                  },
                ),
              );
            },
          ),
          onTap: () {
            slidePagekey.currentState!.popPage();
            Navigator.pop(context);
          },
        ),
        slideAxis: SlideAxis.both,
        slideType: SlideType.wholePage,
      ),
    );
  }
}

class LivePhotoWidget extends StatefulWidget {
  const LivePhotoWidget({
    super.key,
    required this.videoUrl,
    required this.fit,
    required this.state,
    required this.isSliding,
    required this.gestureDetailsIsChanging,
  });

  final String videoUrl;
  final BoxFit fit;
  final ExtendedImageState state;
  final ValueNotifier<bool> isSliding;
  final ValueNotifier<bool> gestureDetailsIsChanging;
  @override
  State<LivePhotoWidget> createState() => _LivePhotoWidgetState();
}

class _LivePhotoWidgetState extends State<LivePhotoWidget> {
  final ValueNotifier<bool> _showVideo = ValueNotifier<bool>(false);
  late VideoPlayerController _controller;

  bool _pointerDown = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.videoUrl,
    );

    _controller.initialize().then((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showVideo.value = true;
        if (!widget.gestureDetailsIsChanging.value && !widget.isSliding.value) {
          _controller.play();
        }
      });
    });

    _controller.addListener(_notfiy);

    widget.isSliding.addListener(_isSlidingChanged);
    widget.gestureDetailsIsChanging.addListener(_onGestureDetailsIsChanged);
  }

  void _onGestureDetailsIsChanged() {
    if (!_showVideo.value) {
      return;
    }
    if (widget.gestureDetailsIsChanging.value) {
      _controller.pause();
    } else if (!_pointerDown) {
      continuePlay();
    }
  }

  void continuePlay() {
    if (_showVideo.value && _controller.value.position != Duration.zero) {
      _controller.play();
    }
  }

  void _isSlidingChanged() {
    if (!_showVideo.value) {
      return;
    }
    if (widget.isSliding.value) {
      _controller.pause();
    } else {
      continuePlay();
    }
  }

  void _notfiy() {
    if (_controller.value.position >= _controller.value.duration) {
      _controller.seekTo(Duration.zero);
      _showVideo.value = false;
    }
  }

  @override
  void dispose() {
    widget.gestureDetailsIsChanging.removeListener(_onGestureDetailsIsChanged);
    widget.isSliding.removeListener(_isSlidingChanged);
    _controller.pause();
    _controller.removeListener(_notfiy);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _pointerDown = true;
      },
      onPointerUp: (PointerUpEvent event) {
        _pointerDown = false;

        SchedulerBinding.instance.addPostFrameCallback((_) {
          continuePlay();
        });
      },
      onPointerCancel: (PointerCancelEvent event) {
        _pointerDown = false;

        SchedulerBinding.instance.addPostFrameCallback((_) {
          continuePlay();
        });
      },
      child: GestureDetector(
        onLongPress: () {
          _showVideo.value = true;
          _controller.play();
        },
        onLongPressUp: () {
          _showVideo.value = false;
          _controller.pause();
          _controller.seekTo(Duration.zero);
        },
        child: ExtendedImageGesture(
          widget.state,
          imageBuilder: (
            Widget image, {
            ExtendedImageGestureState? imageGestureState,
          }) {
            return ValueListenableBuilder<bool>(
              valueListenable: _showVideo,
              builder: (BuildContext b, bool showVideo, Widget? child) {
                if (showVideo) {
                  // may be you want to stop video when slide page
                  // ignore: unused_local_variable

                  // if (totalScale != 1) {
                  //   _controller.pause();
                  // } else {
                  //   _controller.play();

                  // }
                  return imageGestureState!
                      .wrapGestureWidget(VideoPlayer(_controller));
                  // final GestureDetails? gestureDetails =
                  //     imageGestureState?.gestureDetails;
                  // Rect rect = Offset.zero & widget.size;
                  // if (gestureDetails != null &&
                  //     gestureDetails.slidePageOffset != null) {
                  //   rect = rect.shift(-gestureDetails.slidePageOffset!);
                  // }

                  // Rect destinationRect = getDestinationRect(
                  //   rect: rect,
                  //   inputSize: Size(
                  //     widget.state.extendedImageInfo!.image.width.toDouble(),
                  //     widget.state.extendedImageInfo!.image.height.toDouble(),
                  //   ),
                  //   fit: widget.fit,
                  // );

                  // if (gestureDetails != null) {
                  //   destinationRect = gestureDetails
                  //       .calculateFinalDestinationRect(rect, destinationRect);

                  //   if (gestureDetails.slidePageOffset != null) {
                  //     destinationRect =
                  //         destinationRect.shift(gestureDetails.slidePageOffset!);
                  //   }
                  // }
                  // final ExtendedImageSlidePageState? extendedImageSlidePageState =
                  //     imageGestureState?.extendedImageSlidePageState;

                  // Widget child = VideoPlayer(_controller);
                  // if (extendedImageSlidePageState != null) {
                  //   child = imageGestureState?.widget.extendedImageState
                  //           .imageWidget.heroBuilderForSlidingPage
                  //           ?.call(child) ??
                  //       child;
                  //   if (extendedImageSlidePageState.widget.slideType ==
                  //       SlideType.onlyImage) {
                  //     child = Transform.translate(
                  //       offset: extendedImageSlidePageState.offset,
                  //       child: Transform.scale(
                  //         scale: extendedImageSlidePageState.scale,
                  //         child: child,
                  //       ),
                  //     );
                  //   }
                  // }

                  // return Stack(
                  //   children: <Widget>[
                  //     Positioned.fromRect(
                  //       rect: destinationRect,
                  //       child: child,
                  //     ),
                  //   ],
                  // );
                }
                return image;
              },
              child: image,
            );
          },
        ),
      ),
    );
  }
}