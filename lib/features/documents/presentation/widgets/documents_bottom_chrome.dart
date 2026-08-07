import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_motion.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/app/theme/app_typography.dart';
import 'package:signica/app/widgets/app_icon.dart';
import 'package:signica/app/widgets/app_tappable.dart';
import 'package:signica/app/widgets/glass_surfaces.dart';
import 'package:signica/features/documents/presentation/widgets/bottom_bar_shell.dart';
import 'package:signica/features/documents/presentation/widgets/glass_circle_button.dart';

const double _addButtonPaddingH = 14;

/// Glyph sizes read off the mock-up render; differ per control by weight.
const double _searchButtonGlyph = 19.33;
const double _searchFieldGlyph = 21.33;
const double _addGlyph = 20.66;
const double _closeGlyph = 16.67;

/// What the bottom bar is currently showing.
enum BottomChromeMode { idle, search, sources }

/// The bottom bar and the two states it turns into: a search field above the
/// keyboard, or the add-source title next to a close button. [BottomBarShell]
/// owns and animates the height; [AnimatedSize] carries the transition
/// between states.
class DocumentsBottomChrome extends StatelessWidget {
  const DocumentsBottomChrome({
    required this.mode,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchTap,
    required this.onAddTap,
    required this.onCloseTap,
    required this.onQueryChanged,
    super.key,
  });

  final BottomChromeMode mode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchTap;
  final VoidCallback onAddTap;
  final VoidCallback onCloseTap;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final bool isSearching = mode == BottomChromeMode.search;

    return BottomBarShell(
      height: isSearching
          ? BottomBarMetrics.compactBarHeight
          : BottomBarMetrics.barHeight,
      horizontalPadding: isSearching ? AppSpacing.s16 : AppSpacing.s12,
      child: AnimatedSize(
        duration: BottomBarMetrics.morphDuration,
        curve: BottomBarMetrics.morphCurve,
        alignment: Alignment.bottomCenter,
        child: Row(
          // Everything in the bar is as tall as the bar.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isSearching)
              Expanded(
                child: _SearchField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: onQueryChanged,
                ),
              )
            else ...<Widget>[
              if (mode == BottomChromeMode.idle)
                GlassCircleButton(
                  icon: AppIcons.searchSemibold,
                  iconSize: _searchButtonGlyph,
                  semanticsLabel: TranslationKeys.documentsSearchHint.tr(),
                  onTap: onSearchTap,
                ),
              Expanded(
                child: _AddSourceTitle(
                  isVisible: mode == BottomChromeMode.sources,
                ),
              ),
            ],
            if (isSearching) const SizedBox(width: AppSpacing.s12),
            _PrimaryAction(
              mode: mode,
              onTap: mode == BottomChromeMode.idle ? onAddTap : onCloseTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Add Document From" title of the source state. Stays mounted and fades
/// in/out rather than appearing on one frame.
class _AddSourceTitle extends StatelessWidget {
  const _AddSourceTitle({required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: !isVisible,
      child: AnimatedOpacity(
        duration: BottomBarMetrics.morphDuration,
        curve: BottomBarMetrics.morphCurve,
        opacity: isVisible ? 1 : 0,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s12),
            child: Text(
              TranslationKeys.sourceSheetTitle.tr(),
              style: AppTypography.labelL.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// Search input inside a glass pill. Takes the width the row gives it and the
/// height the bar gives it.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassPill(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
      child: Row(
        children: <Widget>[
          const AppIcon(
            AppIcons.searchMedium,
            size: _searchFieldGlyph,
            color: AppColors.textOnGlass,
          ),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              placeholder: TranslationKeys.documentsSearchHint.tr(),
              placeholderStyle: AppTypography.inputL.copyWith(
                color: AppColors.searchHint,
              ),
              style: AppTypography.inputL.copyWith(
                color: AppColors.textPrimary,
              ),
              padding: EdgeInsets.zero,
              cursorColor: AppColors.textPrimary,
              textInputAction: TextInputAction.search,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Add Document" ⇄ close button: content change drives a layout-based
/// collapse rather than an animated width.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.mode, required this.onTap});

  final BottomChromeMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isIdle = mode == BottomChromeMode.idle;

    return AppTappable(
      onTap: onTap,
      label: isIdle
          ? TranslationKeys.actionAddDocument.tr()
          : CupertinoLocalizations.of(context).modalBarrierDismissLabel,
      child: GlassPill(
        clipBehavior: Clip.antiAlias,
        child: AnimatedContainer(
          // Accent fill drains over the collapse; a plain DecoratedBox would
          // drop it on a single frame at full width.
          duration: BottomBarMetrics.morphDuration,
          curve: BottomBarMetrics.morphCurve,
          decoration: BoxDecoration(gradient: isIdle ? AppColors.accent : null),
          child: AnimatedSize(
            duration: BottomBarMetrics.morphDuration,
            curve: BottomBarMetrics.morphCurve,
            // The pill hangs off the right edge of the row, so it has to
            // collapse towards it.
            alignment: Alignment.centerRight,
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              // Default layout builder keeps the outgoing child sized until
              // its fade ends, making the collapse read as a stall.
              layoutBuilder:
                  (Widget? currentChild, List<Widget> previousChildren) =>
                      Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
                          for (final Widget child in previousChildren)
                            // Pin to the right edge while it fades out.
                            Positioned.fill(left: null, child: child),
                          ?currentChild,
                        ],
                      ),
              child: isIdle
                  ? const _AddLabel(key: ValueKey<String>('add'))
                  : const _CloseGlyph(key: ValueKey<String>('close')),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddLabel extends StatelessWidget {
  const _AddLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _addButtonPaddingH),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AppIcon(
            AppIcons.addSemibold,
            size: _addGlyph,
            color: AppColors.textOnGlass,
          ),
          const SizedBox(width: AppSpacing.s8),
          Text(
            TranslationKeys.actionAddDocument.tr(),
            style: AppTypography.labelL.copyWith(color: AppColors.textOnGlass),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// Square by aspect ratio, so the button stays round through the collapse
/// instead of following a fixed target size.
class _CloseGlyph extends StatelessWidget {
  const _CloseGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: AppIcon(
        AppIcons.closeMedium,
        size: _closeGlyph,
        color: AppColors.glyph,
      ),
    );
  }
}
