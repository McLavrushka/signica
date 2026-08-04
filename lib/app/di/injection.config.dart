// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:signica/app/di/injection.dart' as _i790;
import 'package:signica/app/router/app_router.dart' as _i149;
import 'package:signica/features/documents/data/db/app_database.dart' as _i897;
import 'package:signica/features/documents/data/db/documents_dao.dart' as _i59;
import 'package:signica/features/documents/data/repositories/document_import_service_impl.dart'
    as _i465;
import 'package:signica/features/documents/data/repositories/documents_repository_impl.dart'
    as _i293;
import 'package:signica/features/documents/data/sources/document_picker.dart'
    as _i571;
import 'package:signica/features/documents/data/sources/file_storage.dart'
    as _i646;
import 'package:signica/features/documents/data/sources/pdf_processor.dart'
    as _i169;
import 'package:signica/features/documents/domain/repositories/document_import_service.dart'
    as _i713;
import 'package:signica/features/documents/domain/repositories/documents_repository.dart'
    as _i373;
import 'package:signica/features/documents/domain/use_cases/delete_documents.dart'
    as _i27;
import 'package:signica/features/documents/domain/use_cases/import_document.dart'
    as _i51;
import 'package:signica/features/documents/domain/use_cases/resolve_document_name.dart'
    as _i1072;
import 'package:signica/features/documents/domain/use_cases/toggle_signature.dart'
    as _i614;
import 'package:signica/features/documents/domain/use_cases/watch_documents.dart'
    as _i776;
import 'package:signica/features/documents/presentation/bloc/documents_bloc.dart'
    as _i339;
import 'package:uuid/uuid.dart' as _i706;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.factory<_i1072.ResolveDocumentName>(
      () => const _i1072.ResolveDocumentName(),
    );
    gh.lazySingleton<_i897.AppDatabase>(() => appModule.database);
    gh.lazySingleton<_i183.ImagePicker>(() => appModule.imagePicker);
    gh.lazySingleton<_i706.Uuid>(() => appModule.uuid);
    gh.lazySingleton<_i149.AppRouter>(() => _i149.AppRouter());
    gh.lazySingleton<_i646.FileStorage>(() => _i646.FileStorage());
    gh.lazySingleton<_i571.DocumentPicker>(
      () => _i571.DocumentPicker(gh<_i183.ImagePicker>()),
    );
    gh.lazySingleton<_i169.PdfProcessor>(
      () => _i169.PdfProcessor(gh<_i646.FileStorage>()),
    );
    gh.lazySingleton<_i59.DocumentsDao>(
      () => _i59.DocumentsDao(gh<_i897.AppDatabase>()),
    );
    gh.lazySingleton<_i713.DocumentImportService>(
      () => _i465.DocumentImportServiceImpl(
        gh<_i571.DocumentPicker>(),
        gh<_i169.PdfProcessor>(),
        gh<_i646.FileStorage>(),
      ),
    );
    gh.lazySingleton<_i373.DocumentsRepository>(
      () => _i293.DocumentsRepositoryImpl(
        gh<_i59.DocumentsDao>(),
        gh<_i646.FileStorage>(),
      ),
    );
    gh.factory<_i27.DeleteDocuments>(
      () => _i27.DeleteDocuments(gh<_i373.DocumentsRepository>()),
    );
    gh.factory<_i614.ToggleSignature>(
      () => _i614.ToggleSignature(gh<_i373.DocumentsRepository>()),
    );
    gh.factory<_i776.WatchDocuments>(
      () => _i776.WatchDocuments(gh<_i373.DocumentsRepository>()),
    );
    gh.factory<_i51.ImportDocument>(
      () => _i51.ImportDocument(
        gh<_i713.DocumentImportService>(),
        gh<_i373.DocumentsRepository>(),
        gh<_i1072.ResolveDocumentName>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.factory<_i339.DocumentsBloc>(
      () => _i339.DocumentsBloc(
        gh<_i776.WatchDocuments>(),
        gh<_i51.ImportDocument>(),
        gh<_i614.ToggleSignature>(),
        gh<_i27.DeleteDocuments>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i790.AppModule {}
