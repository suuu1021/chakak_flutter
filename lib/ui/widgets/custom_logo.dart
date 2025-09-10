import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../_core/constants/app_images.dart';
import '../../_core/constants/app_strings.dart';
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
          AppImages.logo,
          colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
          height: 150,
          width: 150,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 40,
            fontFamily: AppStrings.fontFamily1,
          ),
        ),
        const SizedBox(height: largeGap),
      ],
    );
  }
}
