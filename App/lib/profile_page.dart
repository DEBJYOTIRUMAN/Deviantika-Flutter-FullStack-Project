import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deviantika/login_page.dart';
import 'bottom_tabs.dart';
import 'colors.dart' as color;
import 'store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool changeButton = false;
  int currentIndex = 4;
  moveToLogin(BuildContext context) async {
    setState(() {
      changeButton = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    box.remove("token");
    box.remove("user");
    Get.to(
      () => const LoginPage(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(seconds: 1),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.AppColor.background,
      child: Scaffold(
        body: SingleChildScrollView(
            child: Column(
          children: [
            Stack(children: [
              Image.asset(
                "assets/account.png",
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/user.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              box.read("user")["name"],
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color.AppColor.homePageTitle,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Prime Member",
              style: TextStyle(
                fontSize: 16,
                color: color.AppColor.homePageSubtitle,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Material(
                color: color.AppColor.coursePageContainerGradient1stColor,
                borderRadius: BorderRadius.circular(changeButton ? 50 : 8),
                child: InkWell(
                    onTap: () {
                      moveToLogin(context);
                    },
                    child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: changeButton ? 50 : 150,
                        height: 50,
                        alignment: Alignment.center,
                        child: changeButton
                            ? const Icon(
                                Icons.done,
                                color: Colors.white,
                              )
                            : const Text(
                                "Logout",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ))))
          ],
        )),
        bottomNavigationBar: BottomTabs(currentIndex: currentIndex),
      ),
    );
  }
}
