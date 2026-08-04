/// Layout constants measured in the Figma file (`docs/figma-spec.md`).
/// The design is drawn on a 375pt-wide frame.
abstract final class AppDimens {
  static const double designWidth = 375;

  // Header
  static const double headerHeight = 185;
  static const double headerHorizontalPadding = 18;
  static const double logoSize = 38;
  static const double logoRadius = 15.2;
  static const double logoToTitleGap = 10;
  static const double headerButtonSize = 38;

  // Content sheet
  static const double sheetTop = 113;
  static const double sheetRadius = 36;

  // Segmented control
  static const double segmentedTop = 129;
  static const double segmentedHeight = 36;
  static const double segmentedHorizontalMargin = 12;
  static const double segmentedTrackPaddingH = 8;
  static const double segmentedTrackPaddingV = 4;
  static const double segmentedThumbHeight = 28;
  static const double segmentedThumbRadius = 20;

  // Documents grid
  static const double gridHorizontalPadding = 28;
  static const double gridItemWidth = 150;
  static const double gridColumnGap = 19;
  static const double gridRowGap = 24;
  static const double previewHeight = 182;
  static const double previewToTitleGap = 8;
  static const double titleToDateGap = 4;

  /// Front sheet of a preview; the back sheet is slightly smaller and rotated.
  static const double sheetFrontWidth = 144.18;
  static const double sheetFrontHeight = 182.29;
  static const double sheetBackWidth = 124.48;
  static const double sheetBackHeight = 168.41;
  static const double sheetRadiusSmall = 12;

  // Signed badge
  static const double badgeHeight = 22;
  static const double badgeRadius = 20;
  static const double badgePaddingH = 8;
  static const double badgePaddingV = 4;

  // Bottom bar
  static const double bottomBarBottomInset = 46.1;
  static const double bottomBarHorizontalPadding = 12;
  static const double circleButtonSize = 62.9;
  static const double addButtonWidth = 178;
  static const double addButtonHeight = 61;
  static const double addButtonRadius = 60.87;
  static const double addButtonIconGap = 8;

  // Add-document source pills
  static const double sourcePillHeight = 56;
  static const double sourcePillWidth = 128;
  static const double sourcePillGap = 12;
  static const double sourcePillPaddingH = 20;
  static const double sourceIconSize = 24;
  static const double sourceIconRadius = 7;
  static const double sourceIconGap = 8;

  // Search
  static const double searchFieldWidth = 283;
  static const double searchFieldHeight = 48;
  static const double searchCloseSize = 48;
  static const double searchBarHorizontalPadding = 16;
  static const double searchBarGap = 12;

  // Context menu
  static const double menuWidth = 262;
  static const double menuRadius = 34;
  static const double menuItemHeight = 40;
}
