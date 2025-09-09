import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../_core/constants/size.dart';

class CustomLogo extends StatelessWidget {
  final String title;

  const CustomLogo(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: xlargeGap),
        SvgPicture.asset(
          "assets/images/logo.svg",
          color: Colors.black,
          height: 150,
          width: 150,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 40, fontFamily: 'Modak'),
        ),
        const SizedBox(height: largeGap),
      ],
    );
  }
}
