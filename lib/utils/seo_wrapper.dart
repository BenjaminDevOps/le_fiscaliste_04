import 'package:flutter/material.dart';
import 'package:le_fiscaliste_04/utils/platform_helper.dart';
import 'seo_text_web.dart' if (dart.library.io) 'seo_text_mobile.dart';

class SeoText extends StatelessWidget {
  final String text;
  final String tag;
  final TextStyle? style;
  final TextAlign? textAlign;

  const SeoText(
    this.text, {
    Key? key,
    required this.tag,
    this.style,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isRunningOnWeb) {
      return createSeoTextWeb(text, tag, style, textAlign);
    } else {
      return Text(text, style: style, textAlign: textAlign);
    }
  }
}
