import 'package:flutter/material.dart';

Widget createSeoTextWeb(
    String text, String tag, TextStyle? style, TextAlign? textAlign) {
  // Implémentation SEO pour le web
  return Semantics(
    container: true,
    label: tag + ": " + text,
    child: Text(
      text,
      style: style,
      textAlign: textAlign,
    ),
  );
}
