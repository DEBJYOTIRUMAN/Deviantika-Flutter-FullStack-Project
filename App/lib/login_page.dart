import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deviantika/home_page.dart';
import 'package:deviantika/signup_page.dart';
import 'package:deviantika/store.dart';
import 'colors.dart' as color;
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool changeButton = false;
  String email = "";
  String password = "";
  final _formKey = GlobalKey<FormState>();
  final url1 = "https://deviantika-t930.onrender.com/api/login";
  final url2 = "https://deviantika-t930.onrender.com/api/me";
  moveToHome(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse(url1),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "email": email,
          "password": password,
        }),
      );
      final decodeToken = jsonDecode(response.body);
      if (response.statusCode == 200) {
        box.write("token", decodeToken);
      } else {
        Get.snackbar("Login Error", "",
            snackPosition: SnackPosition.BOTTOM,
            icon: const Icon(
              Icons.face,
              size: 30,
              color: Colors.white,
            ),
            backgroundColor: color.AppColor.gradientSecond,
            colorText: Colors.white,
            messageText: const Text(
              "Email or Password is incorrect",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ));
        return;
      }
      // User Details Server Call
      final response2 = await http.get(
        Uri.parse(url2),
        headers: {
          HttpHeaders.authorizationHeader:
              "Bearer ${decodeToken["access_token"]}",
        },
      );
      final decodeUser = jsonDecode(response2.body);
      if (response.statusCode == 200) {
        box.write("user", decodeUser);
        setState(() {
          changeButton = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        Get.to(
          () => const HomePage(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(seconds: 1),
        );
        setState(() {
          changeButton = false;
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
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
          color: color.AppColor.creamColor,
          child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/login.png",
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 32.0),
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  hintText: "Enter email",
                                  labelText: "Email",
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Email cannot be empty";
                                  }
                                  return GetUtils.isEmail(value)
                                      ? null
                                      : "Enter a valid email address";
                                },
                                onChanged: (value) {
                                  email = value;
                                  setState(() {});
                                },
                              ),
                              TextFormField(
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: "Enter password",
                                  labelText: "Password",
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Password cannot be empty";
                                  } else if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  password = value;
                                  setState(() {});
                                },
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Material(
                                  color: color.AppColor
                                      .coursePageContainerGradient1stColor,
                                  borderRadius: BorderRadius.circular(
                                      changeButton ? 50 : 8),
                                  child: InkWell(
                                      onTap: () {
                                        moveToHome(context);
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
                                                  "Login",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))))
                            ],
                          )),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: 18,
                              color: color.AppColor.loginButtonColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Get.to(() => const SignupPage());
                            },
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color.AppColor.gradientSecond,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )))),
    );
  }
}
