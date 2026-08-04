import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:signica/app/app.dart';
import 'package:signica/app/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await pdfrxFlutterInitialize();
  configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const SignicaApp(),
    ),
  );
}
