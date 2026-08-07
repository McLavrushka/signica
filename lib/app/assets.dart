/// Paths to bundled assets.
abstract final class Assets {
  static const String logo = 'assets/icons/logo_sign.svg';
  static const String signature = 'assets/icons/signature.svg';
  static const String emptyIllustration =
      'assets/images/empty_illustration.png';
  static const String sourceFiles = 'assets/images/source_files.png';
  static const String sourcePhotos = 'assets/images/source_photos.png';
  static const String sourceScanner = 'assets/images/source_scanner.png';
}

/// SF Symbols glyphs, one file per symbol *and weight*.
///
/// The design picks a weight per context — a Bold trash in the selection bar,
/// a Regular one in a menu row — and an icon font has a single outline per
/// glyph, so weight cannot be a parameter at the call site. That is why the
/// same symbol appears here more than once, and why these are assets rather
/// than `CupertinoIcons`.
///
/// Generated from Apple's variable SF Pro at the exact axis values the mock-up
/// names: Regular 400, Medium 510, Semibold 590, Bold 700. Each file's viewBox
/// is the tight outline of the glyph, so [AppIcon] can size by what is drawn
/// rather than by an em box with unknown padding in it.
abstract final class AppIcons {
  static const String _dir = 'assets/icons/glyphs';

  static const String ellipsis = '$_dir/ellipsis_regular.svg';

  static const String searchSemibold = '$_dir/magnifyingglass_semibold.svg';
  static const String searchMedium = '$_dir/magnifyingglass_medium.svg';

  static const String closeMedium = '$_dir/xmark_medium.svg';
  static const String closeSemibold = '$_dir/xmark_semibold.svg';

  static const String checkmark = '$_dir/checkmark_semibold.svg';
  static const String checkmarkCircle = '$_dir/checkmark_circle_regular.svg';

  static const String trashBold = '$_dir/trash_bold.svg';
  static const String trashRegular = '$_dir/trash_regular.svg';

  static const String shareBold = '$_dir/square_and_arrow_up_bold.svg';
  static const String shareSemibold = '$_dir/square_and_arrow_up_semibold.svg';

  static const String printerFill = '$_dir/printer_fill_regular.svg';

  static const String addSemibold = '$_dir/plus_circle_fill_semibold.svg';
  static const String addRegular = '$_dir/plus_circle_fill_regular.svg';
}
