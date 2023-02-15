import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deviantika/box_card.dart';
import 'bottom_tabs.dart';
import 'colors.dart' as color;
import 'package:http/http.dart' as http;
import 'store.dart';

class PopularCoursePage extends StatefulWidget {
  const PopularCoursePage({Key? key}) : super(key: key);

  @override
  State<PopularCoursePage> createState() => _PopularCoursePageState();
}

class _PopularCoursePageState extends State<PopularCoursePage> {
  List popularCourses = [];
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
      List popularCourseData = json.decode(response.body);
      popularCourseData
          .sort((a, b) => b["likes"].length.compareTo(a["likes"].length));
      setState(() {
        popularCourses = popularCourseData.sublist(0, 5);
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
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 2;
    return Container(
        color: color.AppColor.homePageBackground,
        child: SafeArea(
            child: Scaffold(
          body: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(left: 15, right: 20, top: 10),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 30,
                        ),
                      ),
                      const Text("Popular Course",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          )),
                      const Icon(
                        Icons.headphones_rounded,
                        size: 30,
                      ),
                    ],
                  )),
              Divider(
                color: color.AppColor.audioGreyBackground,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: popularCourses.length,
                    itemBuilder: (_, i) {
                      return Container(
                          padding: const EdgeInsets.only(
                              bottom: 30, left: 30, right: 30),
                          child: BoxCard(course: popularCourses[i], index: i));
                    }),
              )
            ],
          ),
          bottomNavigationBar: BottomTabs(currentIndex: currentIndex),
        )));
  }
}
