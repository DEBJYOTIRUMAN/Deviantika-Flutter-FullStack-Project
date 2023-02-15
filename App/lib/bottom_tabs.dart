import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deviantika/home_page.dart';
import 'package:deviantika/popular_course_page.dart';
import 'package:deviantika/profile_page.dart';
import 'package:deviantika/search.dart';
import 'audiobook_page.dart';

// ignore: must_be_immutable
class BottomTabs extends StatefulWidget {
  int currentIndex;
  BottomTabs({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<BottomTabs> createState() => _BottomTabsState();
}

class _BottomTabsState extends State<BottomTabs> {
  late int currentIndex;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
      if (currentIndex == 0) {
        Get.to(
          const HomePage(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(seconds: 1),
        );
      } else if (currentIndex == 1) {
        Get.to(
          const Search(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(seconds: 1),
          arguments: ["course"],
        );
      } else if (currentIndex == 2) {
        Get.to(
          const PopularCoursePage(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(seconds: 1),
        );
      } else if (currentIndex == 3) {
        Get.to(
          const AudioBookPage(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(seconds: 1),
        );
      } else if (currentIndex == 4) {
        Get.to(
          const ProfilePage(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(seconds: 1),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    currentIndex = widget.currentIndex;
    return BottomNavigationBar(
      unselectedFontSize: 0,
      selectedFontSize: 0,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey.withOpacity(0.8),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      // backgroundColor: color.AppColor.loopColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, size: 30),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.important_devices, size: 30),
          label: "Popular",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book, size: 30),
          label: "Book",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 30),
          label: "Person",
        ),
      ],
    );
  }
}
