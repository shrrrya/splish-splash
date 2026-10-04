import 'package:flutter/material.dart';

const _seed = Color(0xFF3B5BDB);

ThemeData _build(Brightness brightness) => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _seed,
      brightness: brightness,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      }),
    );

final ThemeData lightTheme = _build(Brightness.light);
final ThemeData darkTheme = _build(Brightness.dark);