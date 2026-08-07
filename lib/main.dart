import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:signica/app/app.dart';
import 'package:signica/app/di/injection.dart';
import 'package:signica/features/documents/data/sources/file_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await pdfrxFlutterInitialize();
  // Pre-warms the glass shaders so the first frame with a glass surface does
  // not flash.
  await LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);
  configureDependencies();
  // Resolves the documents directory once so stored paths can be rebuilt
  // synchronously for the current app container.
  await getIt<FileStorage>().init();

  runApp(
    // The glass surfaces need this wrapper, not just `initialize()`: it is what
    // installs the accessibility and brightness scopes the shader reads. The
    // app is light-only, so the brightness resolver comes from Material rather
    // than from the device.
    LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      child: EasyLocalization(
        supportedLocales: const <Locale>[Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const SignicaApp(),
      ),
    ),
  );
}
