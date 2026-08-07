import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_radius.dart';
import 'package:signica/app/theme/app_shadow.dart';

/// The sheet is inset in its box, and both keep their proportions at whatever
/// width the grid hands the card.
const double _boxAspectRatio = 150 / 182;
const double _sheetWidthFactor = 0.82;
const double _sheetHeightFactor = 0.92;

/// Rendered page previews of one document: a single sheet, or two stacked
/// sheets when the document has more than one page. Images are PNGs rendered
/// once at import time; nothing here rasterises a PDF.
class DocumentPreview extends StatelessWidget {
  const DocumentPreview({
    required this.firstPagePath,
    this.lastPagePath,
    super.key,
  });

  /// Radians. The back sheet is all but straight; the front one leans.
  static const double backSheetAngle = -0.005;
  static const double frontSheetAngle = 0.13;

  final String firstPagePath;

  /// Non-null only for multi-page documents; drawn behind the first page.
  final String? lastPagePath;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _boxAspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (lastPagePath case final String path)
            Transform.rotate(
              angle: backSheetAngle,
              child: _Sheet(path: path, hasShadow: false),
            ),
          Transform.rotate(
            angle: lastPagePath == null ? 0 : frontSheetAngle,
            child: _Sheet(path: firstPagePath, hasShadow: true),
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.path, required this.hasShadow});

  final String path;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _sheetWidthFactor,
      heightFactor: _sheetHeightFactor,
      // `BoxDecoration` clips its own image, avoiding a nested ClipRRect. A
      // missing file just leaves the white sheet and border, not a blank hole.
      // No `cacheWidth`: previews are already rasterised at import to card size.
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          border: Border.all(color: AppColors.sheetBorder),
          boxShadow: hasShadow ? AppShadow.sheet : null,
          image: DecorationImage(
            image: FileImage(File(path)),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.medium,
            onError: (_, _) {},
          ),
        ),
      ),
    );
  }
}
