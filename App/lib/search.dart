import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deviantika/audio_listview.dart';
import 'package:deviantika/bottom_tabs.dart';
import 'colors.dart' as color;
import 'package:http/http.dart' as http;
import 'course_listview.dart';
import 'store.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _Search();
}

class _Search extends State<Search> {
  List queryResults = [];
  String searchPageName = Get.arguments[0];
  List recommendBooks = Get.arguments[0] == "audiobook" ? Get.arguments[1] : [];
  int currentIndex = 1;
  void searchQuery(String query) async {
    if (query.length < 3) {
      return;
    }
    String searchUrl = "";
    if (searchPageName == "audiobook") {
      searchUrl =
          "https://deviantika-t930.onrender.com/api/audiobook/search/$query";
    } else {
      searchUrl = "https://deviantika-t930.onrender.com/api/course/$query";
    }
    final accessToken = box.read("token")["access_token"];
    final response = await http.get(
      Uri.parse(searchUrl),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        queryResults = jsonDecode(response.body);
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
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: color.AppColor.background,
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
                      const Text("Search",
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
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: CupertinoSearchTextField(
                  padding: const EdgeInsets.all(16),
                  onChanged: (value) {
                    searchQuery(value);
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                  child: searchPageName == "audiobook"
                      ? AudioListView(
                          books: queryResults, recommendBooks: recommendBooks)
                      : CourseListView(
                          courses: queryResults,
                        )),
            ],
          ),
          bottomNavigationBar: BottomTabs(currentIndex: currentIndex),
        )));
  }
}
