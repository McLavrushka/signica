import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signica/app/di/injection.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/presentation/bloc/documents_bloc.dart';

/// Entry point of the single screen in the app.
///
/// NOTE: the layout below is a working scaffold used to exercise the data flow
/// end to end. The final pixel-perfect layout is built by hand against
/// `docs/figma-spec.md` and replaces the body of this page.
@RoutePage()
class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<DocumentsBloc>(
    create: (_) => getIt<DocumentsBloc>()..add(const DocumentsSubscribed()),
    child: const _DocumentsView(),
  );
}

class _DocumentsView extends StatelessWidget {
  const _DocumentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(TranslationKeys.appTitle.tr())),
      body: BlocBuilder<DocumentsBloc, DocumentsState>(
        builder: (BuildContext context, DocumentsState state) {
          if (state.status == DocumentsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isEmptyLibrary) {
            return Center(child: Text(TranslationKeys.documentsEmptyTitle.tr()));
          }

          return ListView.builder(
            itemCount: state.documents.length,
            itemBuilder: (BuildContext context, int index) {
              final Document document = state.documents[index];
              return ListTile(
                title: Text(document.name),
                subtitle: Text(
                  '${document.pageCount} p. · '
                  '${document.isSigned ? TranslationKeys.documentSignedBadge.tr() : '—'}',
                ),
                onTap: () => context.read<DocumentsBloc>().add(
                  DocumentSignatureToggled(document),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<DocumentsBloc>().add(
          DocumentImportRequested(
            source: DocumentSource.files,
            defaultName: TranslationKeys.documentDefaultName.tr(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
