import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deviantika/bottom_tabs.dart';
import 'package:deviantika/box_card.dart';
import 'package:deviantika/course_page.dart';
import 'package:deviantika/search.dart';
import 'audiobook_page.dart';
import 'store.dart';
import 'colors.dart' as color;
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List course = [];
  int currentIndex = 0;
  _initData() async {
    const url = "https://deviantika-t930.onrender.com/api/course";
    final accessToken = box.read("token")["access_token"];
    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        course = jsonDecode(response.body);
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
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.AppColor.homePageBackground,
      body: Container(
        padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/logo.png",
                    width: 135,
                    color: color.AppColor.homePageTitle,
                  ),
                  Expanded(child: Container()),
                  InkWell(
                    onTap: () async {
                      await Get.to(const Search(),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(seconds: 1),
                          arguments: ["course"]);
                      _initData();
                    },
                    child: Icon(
                      Icons.search,
                      size: 30,
                      color: color.AppColor.loopColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                      child: Icon(
                        Icons.loop,
                        size: 30,
                        color: color.AppColor.loopColor,
                      ),
                      onTap: () {
                        Get.to(
                          const AudioBookPage(),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(seconds: 1),
                        );
                      }),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Text("New Program",
                      style: TextStyle(
                          fontSize: 20,
                          color: color.AppColor.homePageSubtitle,
                          fontWeight: FontWeight.w700)),
                  Expanded(child: Container()),
                  InkWell(
                    onTap: () => {
                      Get.to(const CoursePage(),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(seconds: 1),
                          arguments: [
                            course[course.length - 1],
                            course.length - 1
                          ])
                    },
                    child: Row(
                      children: [
                        Text("Details",
                            style: TextStyle(
                              fontSize: 20,
                              color: color.AppColor.homePageDetail,
                            )),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.arrow_forward,
                            size: 20, color: color.AppColor.homePageIcons),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              course.isEmpty
                  ? Container()
                  : BoxCard(
                      course: course[course.length - 1],
                      index: course.length - 1),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 180,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 30),
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage("assets/card.jpg"),
                          fit: BoxFit.fill,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 40,
                            offset: const Offset(8, 10),
                            color:
                                color.AppColor.gradientSecond.withOpacity(0.3),
                          ),
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(-1, -5),
                            color:
                                color.AppColor.gradientSecond.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(right: 200, bottom: 30),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/figure.png"),
                        ),
                      ),
                    ),
                    Container(
                        width: double.maxFinite,
                        height: 100,
                        margin: const EdgeInsets.only(left: 150, top: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Never stop learning",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color.AppColor.homePageDetail,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            RichText(
                                text: TextSpan(
                                    text: "Keep it up\n",
                                    style: TextStyle(
                                      color: color.AppColor.homePagePlanColor,
                                      fontSize: 16,
                                    ),
                                    children: const [
                                  TextSpan(
                                    text: "you are doing great",
                                  )
                                ]))
                          ],
                        )),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    "Our Courses",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: color.AppColor.homePageTitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 1.8,
                  child: OverflowBox(
                    maxWidth: MediaQuery.of(context).size.width,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                          itemCount: course.length.toDouble() ~/ 2,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (_, i) {
                            int a = 2 * i;
                            int b = 2 * i + 1;
                            return Row(children: [
                              InkWell(
                                onTap: () => {
                                  Get.to(const CoursePage(),
                                      transition:
                                          Transition.rightToLeftWithFade,
                                      duration: const Duration(seconds: 1),
                                      arguments: [course[a], a])
                                },
                                child: Container(
                                    width: (MediaQuery.of(context).size.width -
                                            90) /
                                        2,
                                    height: 170,
                                    margin: const EdgeInsets.only(
                                        left: 30, bottom: 15, top: 15),
                                    padding: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          course[a]["image_url"],
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 3,
                                          offset: const Offset(5, 5),
                                          color: color.AppColor.gradientSecond
                                              .withOpacity(0.1),
                                        ),
                                        BoxShadow(
                                          blurRadius: 3,
                                          offset: const Offset(-5, -5),
                                          color: color.AppColor.gradientSecond
                                              .withOpacity(0.1),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          course[a]["name"],
                                          style: TextStyle(
                                            fontSize: 20,
                                            color:
                                                color.AppColor.homePageDetail,
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                              InkWell(
                                onTap: () => {
                                  Get.to(const CoursePage(),
                                      transition:
                                          Transition.rightToLeftWithFade,
                                      duration: const Duration(seconds: 1),
                                      arguments: [course[b], b])
                                },
                                child: Container(
                                    width: (MediaQuery.of(context).size.width -
                                            90) /
                                        2,
                                    height: 170,
                                    margin: const EdgeInsets.only(
                                        left: 30, bottom: 15, top: 15),
                                    padding: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          course[b]["image_url"],
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 3,
                                          offset: const Offset(5, 5),
                                          color: color.AppColor.gradientSecond
                                              .withOpacity(0.1),
                                        ),
                                        BoxShadow(
                                          blurRadius: 3,
                                          offset: const Offset(-5, -5),
                                          color: color.AppColor.gradientSecond
                                              .withOpacity(0.1),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          course[b]["name"],
                                          style: TextStyle(
                                            fontSize: 20,
                                            color:
                                                color.AppColor.homePageDetail,
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                            ]);
                          }),
                    ),
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomTabs(currentIndex: currentIndex),
    );
  }
}
