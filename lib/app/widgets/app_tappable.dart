import 'package:flutter/widgets.dart';
import 'package:signica/app/theme/app_opacity.dart';

/// A tap target and everything that has to be true of one in this app.
///
/// The whole surface is the button, not the glyph centred in it — without
/// [HitTestBehavior.opaque] the hit test falls through the padding and only the
/// content taps. A disabled target stops responding *and* dims, because those
/// are one decision, not two.
///
/// This exists because the same `Semantics` + `GestureDetector` pair was
/// written out nine times, and nine copies is nine chances for one of them to
/// forget the label or the hit behaviour.
class AppTappable extends StatelessWidget {
  const AppTappable({
    required this.onTap,
    required this.child,
    this.label,
    this.selected,
    this.onLongPress,
    this.isEnabled = true,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;

  /// Spoken name of the button; an icon alone tells VoiceOver nothing.
  final String? label;

  /// Null when the target has no selected state.
  final bool? selected;

  final VoidCallback? onLongPress;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final Widget target = GestureDetector(
      onTap: isEnabled ? onTap : null,
      onLongPress: isEnabled ? onLongPress : null,
      behavior: HitTestBehavior.opaque,
      child: child,
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      selected: selected,
      child: isEnabled
          ? target
          : Opacity(opacity: AppOpacity.disabled, child: target),
    );
  }
}
