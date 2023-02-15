import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deviantika/home_page.dart';
import 'package:deviantika/login_page.dart';
import 'package:deviantika/store.dart';
import 'package:http/http.dart' as http;
import 'colors.dart' as color;

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? timer;
  bool isLoading = false;
  @override
  void initState() {
    refreshToken();
    timer =
        Timer.periodic(const Duration(minutes: 5), (Timer t) => refreshToken());
    super.initState();
  }

  void refreshToken() async {
    if (box.read("token") == null) {
      return;
    }
    const url = "https://deviantika-t930.onrender.com/api/refresh";
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "refresh_token": box.read("token")["refresh_token"],
      }),
    );
    if (response.statusCode == 200) {
      final decodeToken = await jsonDecode(response.body);
      box.write("token", decodeToken);
      setState(() {
        isLoading = true;
      });
    } else {
      await Future.delayed(const Duration(seconds: 1));
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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Deviantika App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      home: isLoading ? const HomePage() : const LoginPage(),
    );
  }
}
