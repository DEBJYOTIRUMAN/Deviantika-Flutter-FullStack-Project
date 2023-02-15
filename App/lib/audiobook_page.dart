import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deviantika/audio_listview.dart';
import 'package:deviantika/audio_tabs.dart';
import 'package:deviantika/search.dart';
import 'audioplay_page.dart';
import 'bottom_tabs.dart';
import 'colors.dart' as color;
import 'package:http/http.dart' as http;
import 'store.dart';

class AudioBookPage extends StatefulWidget {
  const AudioBookPage({Key? key}) : super(key: key);

  @override
  State<AudioBookPage> createState() => _AudioBookPageState();
}

class _AudioBookPageState extends State<AudioBookPage>
    with SingleTickerProviderStateMixin {
  List popularBooks = [];
  List books = [];
  List recommendBooks = [];
  int currentIndex = 3;
  late TabController _tabController;
  late ScrollController _scrollController;
  _initData() async {
    const url = "https://deviantika-t930.onrender.com/api/audiobook";
    final accessToken = box.read("token")["access_token"];
    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      List popularBooksdata = json.decode(response.body);
      popularBooksdata
          .sort((a, b) => b["likes"].length.compareTo(a["likes"].length));
      List recommendBooksdata = json.decode(response.body).where((book) {
        return book["recommend"] == true;
      }).toList();
      setState(() {
        popularBooks = popularBooksdata.sublist(0, 5);
        books = jsonDecode(response.body);
        recommendBooks = recommendBooksdata;
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
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: color.AppColor.background,
        child: SafeArea(
            child: Scaffold(
          body: Column(children: [
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.to(
                            const Search(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(seconds: 1),
                            arguments: ["audiobook", recommendBooks],
                          );
                        },
                        icon: const Icon(
                          Icons.search,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.headphones,
                          size: 30,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: const Text("Popular Books",
                        style: TextStyle(fontSize: 30)))
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Stack(children: [
                Positioned(
                  top: 0,
                  left: -20,
                  right: 0,
                  child: SizedBox(
                      height: 180,
                      child: PageView.builder(
                          controller: PageController(viewportFraction: 0.8),
                          itemCount:
                              // ignore: unnecessary_null_comparison
                              popularBooks == null ? 0 : popularBooks.length,
                          itemBuilder: (_, i) {
                            return InkWell(
                              onTap: () {
                                Get.to(
                                  const AudioPlayPage(),
                                  transition: Transition.rightToLeftWithFade,
                                  duration: const Duration(seconds: 1),
                                  arguments: [popularBooks, i, recommendBooks],
                                );
                              },
                              child: Container(
                                height: 180,
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: color.AppColor.audioGreyBackground,
                                      style: BorderStyle.solid,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            popularBooks[i]["thumbnailCover"]),
                                        fit: BoxFit.fill)),
                              ),
                            );
                          })),
                ),
              ]),
            ),
            Expanded(
                child: NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (BuildContext context, bool isScroll) {
                      return [
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: color.AppColor.background,
                          automaticallyImplyLeading: false,
                          bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(50),
                              child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 20, left: 10),
                                  child: TabBar(
                                    indicatorPadding: const EdgeInsets.all(0),
                                    indicatorSize: TabBarIndicatorSize.label,
                                    labelPadding:
                                        const EdgeInsets.only(right: 10),
                                    controller: _tabController,
                                    isScrollable: true,
                                    indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              blurRadius: 7,
                                              offset: const Offset(0, 0))
                                        ]),
                                    tabs: [
                                      AudioTabs(
                                        color: color.AppColor.menu1Color,
                                        text: "New",
                                      ),
                                      AudioTabs(
                                          color: color.AppColor.menu2Color,
                                          text: "Popular"),
                                      AudioTabs(
                                          color: color.AppColor.menu3Color,
                                          text: "Recommend"),
                                    ],
                                  ))),
                        )
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        AudioListView(
                            books: books, recommendBooks: recommendBooks),
                        AudioListView(
                            books: popularBooks,
                            recommendBooks: recommendBooks),
                        AudioListView(
                            books: recommendBooks,
                            recommendBooks: recommendBooks),
                      ],
                    )))
          ]),
          bottomNavigationBar: BottomTabs(currentIndex: currentIndex),
        )));
  }
}
