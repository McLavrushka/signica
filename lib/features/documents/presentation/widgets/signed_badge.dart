import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';

const double _diameter = 40;
const double _markWidth = 24;
const double _markHeight = 22;

/// Mark shown over the preview of a signed document.
///
/// "Signed" is said with the signature glyph and not with a word, so the badge
/// carries its label for VoiceOver only.
class SignedBadge extends StatelessWidget {
  const SignedBadge({super.key});

  /// Distance the badge keeps from the bottom of the preview box.
  static const double bottomInset = 4;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: TranslationKeys.documentSignedBadge.tr(),
      child: Container(
        width: _diameter,
        height: _diameter,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.signedBadgeSurface,
        ),
        child: SvgPicture.asset(
          Assets.signature,
          width: _markWidth,
          height: _markHeight,
        ),
      ),
    );
  }
}
