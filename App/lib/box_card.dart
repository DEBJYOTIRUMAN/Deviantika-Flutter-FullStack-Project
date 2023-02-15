import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart' as color;
import 'course_page.dart';

// ignore: must_be_immutable
class BoxCard extends StatelessWidget {
  Map course;
  int index;
  BoxCard({Key? key, required this.course, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.AppColor.gradientFirst.withOpacity(0.8),
              color.AppColor.gradientSecond.withOpacity(0.9),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(80),
          ),
          boxShadow: [
            BoxShadow(
              color: color.AppColor.gradientSecond.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(5, 10),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => {
            Get.to(const CoursePage(),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(seconds: 1),
                arguments: [course, index])
          },
          child: Container(
            padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Course",
                  style: TextStyle(
                      fontSize: 16,
                      color: color.AppColor.homePageContainerTextSmall),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Learn ${course["name"]}",
                  style: TextStyle(
                      fontSize: 25,
                      color: color.AppColor.homePageContainerTextSmall),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  course["caption"],
                  style: TextStyle(
                      fontSize: 25,
                      color: color.AppColor.homePageContainerTextSmall),
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 20,
                          color: color.AppColor.homePageContainerTextSmall,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          course["duration"],
                          style: TextStyle(
                              fontSize: 14,
                              color: color.AppColor.homePageContainerTextSmall),
                        ),
                      ],
                    ),
                    Expanded(child: Container()),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: color.AppColor.gradientFirst,
                            blurRadius: 10,
                            offset: const Offset(4, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
