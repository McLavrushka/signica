import 'package:flutter/widgets.dart';
import 'package:signica/app/theme/app_motion.dart';
import 'package:signica/features/documents/presentation/widgets/documents_header.dart';

/// The "…" menu with its dismiss barrier, scaling out of the button it
/// belongs to. Positioned from [DocumentsHeader]'s own metrics, hence the name.
class HeaderMenuLayer extends StatelessWidget {
  const HeaderMenuLayer({
    required this.isOpen,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  final bool isOpen;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isOpen,
      // The menu stays in the tree so it can animate out; while closed it is
      // invisible to VoiceOver as well as to touches.
      child: ExcludeSemantics(
        excluding: !isOpen,
        child: GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.opaque,
          child: AnimatedOpacity(
            opacity: isOpen ? 1 : 0,
            duration: AppMotion.fast,
            child: SafeArea(
              bottom: false,
              child: Padding(
                // Directly under the button it opens from.
                padding: const EdgeInsets.only(
                  top: DocumentsHeader.topGap + DocumentsHeader.tileSize,
                  right: DocumentsHeader.horizontalPadding,
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: AnimatedScale(
                    alignment: Alignment.topRight,
                    scale: isOpen ? 1 : AppMotion.appearScale,
                    duration: AppMotion.fast,
                    curve: AppMotion.emphasized,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
