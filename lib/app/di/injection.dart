import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:signica/app/di/injection.config.dart';
import 'package:signica/features/documents/data/db/app_database.dart';
import 'package:uuid/uuid.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

/// Third-party singletons that cannot be annotated in their own packages.
@module
abstract class AppModule {
  @lazySingleton
  AppDatabase get database => AppDatabase();

  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();

  @lazySingleton
  Uuid get uuid => const Uuid();
}
