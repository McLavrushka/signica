import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Glass presets of the app.
///
/// The design stacks two or three translucent fills per surface; in code each
/// context becomes one tinted glass layer with the same result.
///
/// Every preset asks for its own layer. That is not a performance knob: without
/// it a surface renders grouped, takes its settings from an ancestor
/// `LiquidGlassLayer` and ignores its own — and this app has no such ancestor.
///
/// Every preset asks for its own layer and for [quality]. Both are required:
/// without `useOwnLayer` a surface renders grouped, taking its settings from an
/// ancestor `LiquidGlassLayer` that this app does not have; and `standard` is
/// the tier with no specular and no Fresnel, which is what makes glass read as
/// a plain outline. Measured on the search button, `standard` peaks at 245 with
/// a flat 241 body, premium at 252 with a soft falloff and a 244 body.
///
/// The rim is still drawn as a `Border` by the widget that owns it. Premium has
/// a first-frame defect inside the content sheet — the source pill comes out at
/// 239 against a 240 background until some later repaint — and a border makes
/// that cosmetic rather than an invisible control. It also lands on the design's
/// number exactly and can be asserted in a test.
abstract final class AppGlass {
  static const GlassQuality quality = GlassQuality.premium;
  static const double _rim = 1.0;

  /// Bottom bar buttons and the search field.
  static const LiquidGlassSettings control = LiquidGlassSettings(
    glassColor: Color(0x40FFFFFF),
    thickness: 24,
    blur: 8,
    lightIntensity: 1.0,
    refractiveIndex: 1.15,
    ambientRim: _rim,
    specularSharpness: GlassSpecularSharpness.sharp,
  );

  /// Source pills on the empty state: a light translucent surface.
  static const LiquidGlassSettings sourceOnSurface = LiquidGlassSettings(
    glassColor: Color(0x26FFFFFF),
    thickness: 20,
    blur: 6,
    lightIntensity: 1.0,
    ambientRim: _rim,
    specularSharpness: GlassSpecularSharpness.sharp,
  );

  /// Source pills over the blurred overlay: almost opaque white.
  static const LiquidGlassSettings sourceOnOverlay = LiquidGlassSettings(
    glassColor: Color(0xE6FFFFFF),
    thickness: 24,
    blur: 10,
    lightIntensity: 1.0,
    ambientRim: _rim,
    specularSharpness: GlassSpecularSharpness.sharp,
  );

  /// Context menus. The panel carries a shadow, and a shadow shows through
  /// translucent glass, so the fill is heavier here than the others.
  ///
  /// The design states 60% over an 80pt background blur, which composites to
  /// the same value this fill reaches over the content sheet — measured on the
  /// mock-up render, the panel interior lands within a point either way. The
  /// visible difference was never the fill; it was the missing rim.
  static const LiquidGlassSettings menu = LiquidGlassSettings(
    glassColor: Color(0xCCF7F7F7),
    thickness: 26,
    blur: 20,
    lightIntensity: 1.0,
    ambientRim: _rim,
    specularSharpness: GlassSpecularSharpness.sharp,
  );
}
