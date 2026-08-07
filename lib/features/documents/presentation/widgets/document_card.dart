import 'package:flutter/cupertino.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_motion.dart';
import 'package:signica/app/theme/app_shadow.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/app/theme/app_typography.dart';
import 'package:signica/app/widgets/app_icon.dart';
import 'package:signica/app/widgets/app_tappable.dart';
import 'package:signica/core/document_date_format.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/presentation/widgets/document_preview.dart';
import 'package:signica/features/documents/presentation/widgets/signed_badge.dart';

/// One grid cell: preview, name, date. Grows in height with its content, so
/// a two-line name or larger Dynamic Type doesn't clip the label.
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    required this.document,
    required this.onTap,
    this.onLongPress,
    this.isSelected,
    super.key,
  });

  final Document document;
  final VoidCallback onTap;

  /// Receives the card's rectangle on screen, so the actions menu can open
  /// under the card the gesture started on.
  final ValueChanged<Rect>? onLongPress;

  /// Null outside select mode; otherwise draws the selection circle.
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    return AppTappable(
      onTap: onTap,
      selected: isSelected,
      label: document.name,
      onLongPress: onLongPress == null ? null : () => _reportBounds(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              DocumentPreview(
                firstPagePath: document.firstPagePreviewPath,
                lastPagePath: document.hasBackPage
                    ? document.lastPagePreviewPath
                    : null,
              ),
              // Signing is the card's one action, so it is worth animating.
              AnimatedScale(
                scale: document.isSigned ? 1 : 0.6,
                duration: AppMotion.medium,
                curve: AppMotion.emphasized,
                child: AnimatedOpacity(
                  opacity: document.isSigned ? 1 : 0,
                  duration: AppMotion.fast,
                  child: const SignedBadge(),
                ),
              ),

              if (isSelected case final bool selected)
                Positioned.fill(
                  child: Center(child: SelectionMark(isSelected: selected)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            document.name,
            style: AppTypography.titleS.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            DocumentDateFormat.short(document.createdAt),
            style: AppTypography.bodyS.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  void _reportBounds(BuildContext context) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    onLongPress!(box.localToGlobal(Offset.zero) & box.size);
  }
}

/// Circle drawn in the middle of a preview while selecting. One painter for
/// both states — drawing them separately is how the white ring went missing
/// from the selected state before.
class SelectionMark extends StatelessWidget {
  const SelectionMark({required this.isSelected, super.key});

  static const double _size = 32;
  static const double _ringWidth = 2.5;

  /// 46% of the disc, measured off the design's `checkmark.circle.fill` glyph.
  static const double _checkSize = _size * 0.46;

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // `CustomPaint.size` is ignored once it has a child, so the box is sized
    // here instead.
    return SizedBox.square(
      dimension: _size,
      child: CustomPaint(
        painter: _MarkPainter(isSelected: isSelected),
        child: Center(
          child: AnimatedOpacity(
            opacity: isSelected ? 1 : 0,
            duration: AppMotion.fast,
            child: const AppIcon(
              AppIcons.checkmark,
              size: _checkSize,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shadow follows the ring rather than filling the circle, since a
/// [BoxShadow] would.
class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.isSelected});

  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = size.center(Offset.zero);
    final double radius = (size.width - SelectionMark._ringWidth) / 2;

    // `blurSigma` is the conversion `BoxShadow` applies to its own radius, so
    // the painted shadow matches the token without a hand-written factor.
    const BoxShadow shadowToken = AppShadow.markOnPage;
    final Paint shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = SelectionMark._ringWidth
      ..color = shadowToken.color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowToken.blurSigma);

    canvas.drawCircle(centre + shadowToken.offset, radius, shadow);

    if (isSelected) {
      canvas.drawCircle(centre, radius, Paint()..color = AppColors.selection);
    }

    // The ring is drawn in both states: the design keeps a white edge around
    // the green disc so it reads against a printed page.
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = SelectionMark._ringWidth
        ..color = AppColors.white,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      isSelected != oldDelegate.isSelected;
}
