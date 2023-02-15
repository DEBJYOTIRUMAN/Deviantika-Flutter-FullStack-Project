import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart' as color;
import 'audioplay_page.dart';

class AudioListView extends StatelessWidget {
  final List books;
  final List recommendBooks;
  const AudioListView(
      {Key? key, required this.books, required this.recommendBooks})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // ignore: unnecessary_null_comparison
      itemCount: books == null ? 0 : books.length,
      itemBuilder: (_, i) {
        return GestureDetector(
          onTap: () => {
            Get.to(
              const AudioPlayPage(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(seconds: 1),
              arguments: [books, i, recommendBooks],
            )
          },
          child: Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color.AppColor.tabVarViewColor,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2,
                        offset: const Offset(0, 0),
                        color: Colors.grey.withOpacity(0.2),
                      )
                    ]),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          width: 90,
                          height: 120,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: color.AppColor.audioGreyBackground,
                                style: BorderStyle.solid,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(books[i]["thumbnail"]),
                              )),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star,
                                    size: 24, color: color.AppColor.starColor),
                                const SizedBox(width: 5),
                                Text(
                                  books[i]["rating"].toString(),
                                  style: TextStyle(
                                      color: color.AppColor.menu2Color),
                                )
                              ],
                            ),
                            Text(books[i]["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(books[i]["authors"],
                                style: TextStyle(
                                    fontSize: 16,
                                    color: color.AppColor.subTitleText)),
                            Container(
                              width: 70,
                              height: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: color.AppColor.loveColor),
                              alignment: Alignment.center,
                              child: Text(
                                books[i]["genre"],
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            )
                          ],
                        )
                      ],
                    )),
              )),
        );
      },
    );
  }
}
