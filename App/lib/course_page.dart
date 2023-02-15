import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import "colors.dart" as color;
import 'package:http/http.dart' as http;
import 'store.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key}) : super(key: key);

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  bool _playArea = false;
  bool _isPlaying = false;
  bool _disposed = false;
  int _isPlayingIndex = -1;
  bool _fullScreen = false;
  bool isLike = false;
  VideoPlayerController? _controller;
  var courseContent = Get.arguments[0];
  int courseNo = Get.arguments[1] + 1;
  List courseVideos = [];
  _initData() async {
    final url =
        "https://deviantika-t930.onrender.com/api/video/course/${courseContent["name"]}";
    final accessToken = box.read("token")["access_token"];
    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        courseVideos = jsonDecode(response.body);
      });
    } else {
      Get.snackbar("Something Wrong !", "",
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(
            Icons.face,
            size: 30,
            color: Colors.white,
          ),
          backgroundColor: color.AppColor.gradientSecond,
          colorText: Colors.white,
          messageText: const Text(
            "An error occurred, please try again later.",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ));
    }
    isLike = courseContent["likes"].contains(box.read("user")["_id"]);
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void handleLike() async {
    List likes = courseContent["likes"];
    if (isLike) {
      likes.remove(box.read("user")["_id"]);
      setState(() {
        isLike = false;
      });
    } else {
      likes.add(box.read("user")["_id"]);
      setState(() {
        isLike = true;
      });
    }
    final url =
        "https://deviantika-t930.onrender.com/api/course/like/${courseContent["_id"]}";
    final accessToken = box.read("token")["access_token"];
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      },
      body: jsonEncode(<String, List>{
        "likes": likes,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Success");
    } else {
      Get.snackbar("Something Wrong !", "",
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(
            Icons.face,
            size: 30,
            color: Colors.white,
          ),
          backgroundColor: color.AppColor.gradientSecond,
          colorText: Colors.white,
          messageText: const Text(
            "An error occurred, please try again later.",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_fullScreen
          ? Container(
              decoration: _playArea == false
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.AppColor.gradientFirst.withOpacity(0.9),
                          color.AppColor.gradientSecond
                        ],
                        begin: const FractionalOffset(0.0, 0.4),
                        end: Alignment.topRight,
                      ),
                    )
                  : BoxDecoration(color: color.AppColor.gradientSecond),
              child: Column(
                children: [
                  _playArea == false
                      ? Container(
                          padding: const EdgeInsets.only(
                              top: 70, left: 30, right: 20),
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      size: 25,
                                      color: color.AppColor.coursePageIconColor,
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  IconButton(
                                    icon: ImageIcon(
                                      AssetImage(
                                        isLike
                                            ? "assets/liked.png"
                                            : "assets/like.png",
                                      ),
                                      size: 25,
                                      color: isLike
                                          ? color.AppColor.menu2Color
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        handleLike();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Text(
                                "Learn ${courseContent["name"]}",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: color.AppColor.coursePageTitleColor,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                courseContent["caption"],
                                style: TextStyle(
                                    fontSize: 25,
                                    color: color.AppColor.coursePageTitleColor),
                              ),
                              const SizedBox(height: 50),
                              Row(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            color.AppColor
                                                .coursePageContainerGradient1stColor,
                                            color.AppColor
                                                .coursePageContainerGradient2ndColor
                                          ],
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight,
                                        )),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 20,
                                            color: color
                                                .AppColor.coursePageIconColor,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            courseContent["duration"],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: color
                                                  .AppColor.coursePageIconColor,
                                            ),
                                          )
                                        ]),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    width: 220,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            color.AppColor
                                                .coursePageContainerGradient1stColor,
                                            color.AppColor
                                                .coursePageContainerGradient2ndColor
                                          ],
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight,
                                        )),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_outline_outlined,
                                            size: 20,
                                            color: color
                                                .AppColor.coursePageIconColor,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            courseContent["instructors"],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: color
                                                  .AppColor.coursePageIconColor,
                                            ),
                                          )
                                        ]),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              height: 100,
                              padding: const EdgeInsets.only(
                                  top: 40, left: 10, right: 10),
                              child: Row(children: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    size: 25,
                                    color:
                                        color.AppColor.coursePageTopIconColor,
                                  ),
                                ),
                                Expanded(child: Container()),
                                _fullscreenButton(),
                              ]),
                            ),
                            _playView(context),
                            _controlView(context)
                          ],
                        ),
                  Expanded(
                      child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(70))),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    "Course $courseNo: ${courseContent["name"]}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: color.AppColor.circuitsColor),
                                  ),
                                  Expanded(child: Container()),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 30,
                                        color: color.AppColor.loopColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        courseContent["rating"].toString(),
                                        style: TextStyle(
                                          color: color.AppColor.circuitsColor,
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Expanded(child: _listView())
                            ],
                          )))
                ],
              ))
          : Container(
              color: Colors.black,
              child: Stack(children: [
                Center(child: _playViewLandscape(context)),
                Positioned(bottom: 0, child: _fullscreenControlView(context)),
                Positioned(
                  top: 20,
                  left: 10,
                  child: TextButton(
                    onPressed: () {
                      _fullScreen = false;
                      setAllOrientations();
                      setState(() {});
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: color.AppColor.coursePageIconColor,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 30,
                  child: Center(
                    child: InkWell(
                      onDoubleTap: () {
                        rewindVideo();
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 60,
                        height: MediaQuery.of(context).size.height - 120,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 30,
                  child: Center(
                    child: InkWell(
                      onDoubleTap: () {
                        forwardVideo();
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 60,
                        height: MediaQuery.of(context).size.height - 120,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
    );
  }

  Future rewindVideo() async {
    if (_controller!.value.position.inMilliseconds > 10000) {
      await _controller!.seekTo(Duration(
          milliseconds: _controller!.value.position.inMilliseconds - 10000));
    }
  }

  Future forwardVideo() async {
    if (_controller!.value.position.inMilliseconds <
        _controller!.value.duration.inMilliseconds - 10000) {
      await _controller!.seekTo(Duration(
          milliseconds: _controller!.value.position.inMilliseconds + 10000));
    } else {
      await _controller!.seekTo(
          Duration(milliseconds: _controller!.value.duration.inMilliseconds));
    }
  }

  Future setAllOrientations() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    await Wakelock.disable();
  }

  Future setLandscape() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await Wakelock.enable();
  }

  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget _fullscreenControlView(BuildContext context) {
    final duration = _duration?.inSeconds ?? 0;
    final head = _position?.inSeconds ?? 0;
    final remained = max(0, duration - head);
    final mins = convertTwo(remained ~/ 60.0);
    final secs = convertTwo(remained % 60);
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(children: [
          _playButtonIconFullscreen(),
          _durationShow(mins, secs),
          Expanded(child: _customSlider(context)),
          _fullscreenButton(),
        ]));
  }

  Widget _controlView(BuildContext context) {
    final noMute = (_controller?.value.volume ?? 0) > 0;
    final duration = _duration?.inSeconds ?? 0;
    final head = _position?.inSeconds ?? 0;
    final remained = max(0, duration - head);
    final mins = convertTwo(remained ~/ 60.0);
    final secs = convertTwo(remained % 60);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      _customSlider(context),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                child: Container(
                    decoration:
                        const BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                        offset: Offset(0.0, 0.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(50, 0, 0, 0),
                      )
                    ]),
                    child: Icon(
                      noMute ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                    )),
                onPressed: () {
                  if (noMute) {
                    _controller?.setVolume(0);
                  } else {
                    _controller?.setVolume(1.0);
                  }
                  setState(() {});
                }),
            TextButton(
                onPressed: () async {
                  final index = _isPlayingIndex - 1;
                  // ignore: prefer_is_empty
                  if (index >= 0 && courseVideos.length >= 0) {
                    _initializeVideo(index);
                  } else {
                    Get.snackbar("Video List", "",
                        snackPosition: SnackPosition.BOTTOM,
                        icon: const Icon(
                          Icons.face,
                          size: 30,
                          color: Colors.white,
                        ),
                        backgroundColor: color.AppColor.gradientSecond,
                        colorText: Colors.white,
                        messageText: const Text(
                          "No videos ahead !",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ));
                  }
                },
                child: const Icon(Icons.fast_rewind,
                    size: 30, color: Colors.white)),
            _playButtonIcon(),
            TextButton(
                onPressed: () async {
                  final index = _isPlayingIndex + 1;
                  if (index <= courseVideos.length - 1) {
                    _initializeVideo(index);
                  } else {
                    Get.snackbar("Video List", "",
                        snackPosition: SnackPosition.BOTTOM,
                        icon: const Icon(
                          Icons.face,
                          size: 30,
                          color: Colors.white,
                        ),
                        backgroundColor: color.AppColor.gradientSecond,
                        colorText: Colors.white,
                        messageText: const Text(
                          "You have finished watching all the videos. Congrats !",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ));
                  }
                },
                child: const Icon(Icons.fast_forward,
                    size: 30, color: Colors.white)),
            _durationShow(mins, secs),
          ],
        ),
      ),
    ]);
  }

  Widget _playViewLandscape(BuildContext context) {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayer(controller),
      );
    } else {
      return const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
              child: Text("Preparing...",
                  style: TextStyle(fontSize: 20, color: Colors.white60))));
    }
  }

  Widget _playView(BuildContext context) {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayer(controller),
      );
    } else {
      return const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
              child: Text("Preparing...",
                  style: TextStyle(fontSize: 20, color: Colors.white60))));
    }
  }

  Widget _durationShow(String mins, String secs) {
    return Text("$mins:$secs",
        style: const TextStyle(color: Colors.white, shadows: <Shadow>[
          Shadow(
            offset: Offset(0.0, 0.1),
            blurRadius: 4.0,
            color: Color.fromARGB(150, 0, 0, 0),
          )
        ]));
  }

  Widget _customSlider(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
          activeTrackColor: Colors.red[700],
          inactiveTrackColor: Colors.red[100],
          trackShape: const RoundedRectSliderTrackShape(),
          trackHeight: 2.0,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 12.0,
          ),
          thumbColor: Colors.redAccent,
          overlayColor: Colors.red.withAlpha(32),
          overlayShape: const RoundSliderOverlayShape(
            overlayRadius: 28,
          ),
          tickMarkShape: const RoundSliderTickMarkShape(),
          activeTickMarkColor: Colors.red[700],
          inactiveTickMarkColor: Colors.red[100],
          valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
          valueIndicatorColor: Colors.redAccent,
          valueIndicatorTextStyle: const TextStyle(color: Colors.white)),
      child: Slider(
          value: max(0, min(_progress * 100, 100)),
          min: 0,
          max: 100,
          divisions: 100,
          label: _position?.toString().split(".")[0],
          onChanged: (value) {
            setState(() {
              _progress = value * 0.01;
            });
          },
          onChangeStart: (value) {
            _controller?.pause();
          },
          onChangeEnd: (value) {
            final duration = _controller?.value.duration;
            if (duration != null) {
              var newValue = max(0, min(value, 99)) * 0.01;
              var millis = (duration.inMilliseconds * newValue).toInt();
              _controller?.seekTo(Duration(milliseconds: millis));
              _controller?.play();
            }
          }),
    );
  }

  Widget _fullscreenButton() {
    return TextButton(
        child: Icon(
          _fullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          if (_fullScreen) {
            _fullScreen = false;
            setAllOrientations();
          } else {
            _fullScreen = true;
            setLandscape();
          }
          setState(() {});
        });
  }

  Widget _playButtonIconFullscreen() {
    return TextButton(
        onPressed: () async {
          if (_isPlaying) {
            setState(() {
              _isPlaying = false;
            });
            _controller?.pause();
          } else {
            setState(() {
              _isPlaying = true;
            });
            _controller?.play();
          }
        },
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
            size: 30, color: Colors.white));
  }

  Widget _playButtonIcon() {
    return TextButton(
        onPressed: () async {
          if (_isPlaying) {
            setState(() {
              _isPlaying = false;
            });
            _controller?.pause();
          } else {
            setState(() {
              _isPlaying = true;
            });
            _controller?.play();
          }
        },
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
            size: 30, color: Colors.white));
  }

  // ignore: prefer_typing_uninitialized_variables
  var _onUpdateControllerTime;
  Duration? _duration;
  Duration? _position;
  var _progress = 0.0;
  void _onControllerUpdate() async {
    if (_disposed) {
      return;
    }
    _onUpdateControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_onUpdateControllerTime > now) {
      return;
    }
    _onUpdateControllerTime = now + 500;
    final controller = _controller;
    if (controller == null) {
      return;
    }
    if (!controller.value.isInitialized) {
      return;
    }
    _duration ??= _controller?.value.duration;
    var duration = _duration;
    if (duration == null) {
      return;
    }
    var position = await controller.position;
    _position = position;
    final playing = controller.value.isPlaying;
    if (playing) {
      if (_disposed) return;
      setState(() {
        _progress = position!.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }
    _isPlaying = playing;
  }

  _initializeVideo(int index) async {
    final videoName = await courseVideos[index]["videoUrl"].split("/").last;
    final controller = VideoPlayerController.network(
        "https://deviantika-t930.onrender.com/api/video/$videoName");
    final old = _controller;
    _controller = controller;
    if (old != null) {
      old.removeListener(_onControllerUpdate);
      old.pause();
    }
    setState(() {});
    // ignore: avoid_single_cascade_in_expression_statements
    controller
      ..initialize().then((_) {
        old?.dispose();
        _isPlayingIndex = index;
        controller.addListener(_onControllerUpdate);
        controller.play();
        setState(() {});
      });
  }

  _onTapVideo(int index) {
    _initializeVideo(index);
  }

  _listView() {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        itemCount: courseVideos.length,
        itemBuilder: (_, int index) {
          return GestureDetector(
              onTap: () {
                _onTapVideo(index);
                setState(() {
                  if (_playArea == false) {
                    _playArea = true;
                  }
                });
              },
              child: _buildCard(index));
        });
  }

  _buildCard(int index) {
    return SizedBox(
      height: 135,
      child: Column(children: [
        Row(children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                border: Border.all(
                  color: color.AppColor.audioGreyBackground,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: NetworkImage(courseVideos[index]["thumbnail"]),
                    fit: BoxFit.cover)),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseVideos[index]["title"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  courseVideos[index]["time"],
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            ],
          )
        ]),
        const SizedBox(
          height: 18,
        ),
        Row(
          children: [
            Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFeaeefc),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  courseVideos[index]["language"],
                  style: const TextStyle(
                    color: Color(0xFF839fed),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (int i = 0; i < 80; i++)
                  i.isEven
                      ? Container(
                          width: 3,
                          height: 1,
                          decoration: BoxDecoration(
                            color: const Color(0xFF839fed),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : Container(
                          width: 3,
                          height: 1,
                          color: Colors.white,
                        )
              ],
            )
          ],
        )
      ]),
    );
  }
}
