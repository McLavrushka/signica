import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:signica/app/di/injection.dart';
import 'package:signica/app/router/app_router.dart';
import 'package:signica/app/theme/app_theme.dart';

class SignicaApp extends StatefulWidget {
  const SignicaApp({super.key});

  @override
  State<SignicaApp> createState() => _SignicaAppState();
}

class _SignicaAppState extends State<SignicaApp> {
  final AppRouter _router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Signica',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    routerConfig: _router.config(),
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
  );
}
