import 'package:flutter/widgets.dart';
import 'package:signica/app/theme/app_motion.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/presentation/widgets/content_sheet.dart';
import 'package:signica/features/documents/presentation/widgets/source_pill.dart';

/// Right margin of the pill stack; lines up with the sheet, not the bar.
const double _stackRightMargin = ContentSheet.horizontalInset;

/// Share of the timeline the staggered pill starts are spread over.
const double _staggerSpread = 0.4;

/// How far a pill rises into place, and how small it starts.
const double _riseDistance = 24;
const double _startScale = AppMotion.appearScale;

/// Source picker shown after "Add Document": pills rise above the bottom bar
/// over a dismiss barrier. The label is drawn by [DocumentsBottomChrome], the
/// blur by [ContentSheet]; [progress] drives everything, keeping this a pure
/// widget.
class AddSourceOverlay extends StatelessWidget {
  const AddSourceOverlay({
    required this.progress,
    required this.onSourceSelected,
    required this.onDismiss,
    required this.bottomInset,
    super.key,
  });

  final double progress;
  final ValueChanged<DocumentSource> onSourceSelected;
  final VoidCallback onDismiss;

  /// Height of the bottom bar plus its offset, so the stack sits above it.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    const List<DocumentSource> sources = DocumentSource.values;

    // Always a Positioned.fill so the parent Stack's sizing never changes;
    // at rest the pills just aren't built.
    if (progress <= 0) {
      return const Positioned.fill(child: SizedBox.expand());
    }

    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            // Transparent: only takes the dismissing tap, doesn't dim content.
            child: GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: _stackRightMargin,
                bottom: bottomInset + SourcePill.gap,
              ),
              // Every pill fills the stack width so they line up, rather than
              // each carrying its own minimum.
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: SourcePill.overlayMinWidth,
                ),
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int i = 0; i < sources.length; i++) ...<Widget>[
                        // Bottom pill first: the stack unfolds upwards.
                        _StaggeredPill(
                          progress: progress,
                          index: sources.length - 1 - i,
                          count: sources.length,
                          child: SourcePill(
                            source: sources[i],
                            style: SourcePillStyle.onOverlay,
                            onTap: () => onSourceSelected(sources[i]),
                          ),
                        ),
                        if (i != sources.length - 1)
                          const SizedBox(height: SourcePill.gap),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredPill extends StatelessWidget {
  const _StaggeredPill({
    required this.progress,
    required this.index,
    required this.count,
    required this.child,
  });

  final double progress;
  final int index;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Every pill runs to the end of the timeline; higher pills start later.
    // Divided by (count - 1) gaps, not count, so the last pill actually
    // reaches the far end of the spread window.
    final double start = count > 1 ? _staggerSpread * index / (count - 1) : 0;
    final double t = Interval(start, 1).transform(progress);
    final double eased = Interval(
      start,
      1,
      curve: AppMotion.emphasized,
    ).transform(progress);

    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - eased) * _riseDistance),
        child: Transform.scale(
          scale: _startScale + (1 - _startScale) * eased,
          child: child,
        ),
      ),
    );
  }
}
