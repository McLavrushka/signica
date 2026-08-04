import 'package:equatable/equatable.dart';

/// Raw result of a picker, before it becomes a stored document.
sealed class PickedSource extends Equatable {
  const PickedSource();

  @override
  List<Object?> get props => <Object?>[];
}

/// A PDF chosen from Files. [originalName] has no extension and is used as the
/// document name.
final class PickedPdf extends PickedSource {
  const PickedPdf({required this.path, required this.originalName});

  final String path;
  final String originalName;

  @override
  List<Object?> get props => <Object?>[path, originalName];
}

/// Images from the photo library or the scanner; they still have to be
/// assembled into a PDF.
final class PickedImages extends PickedSource {
  const PickedImages(this.paths);

  final List<String> paths;

  @override
  List<Object?> get props => <Object?>[paths];
}
