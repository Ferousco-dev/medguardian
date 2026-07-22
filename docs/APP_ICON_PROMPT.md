# App icon generation prompt

Generate the launcher icon yourself with your image tool of choice, then drop the PNG in and run `flutter_launcher_icons`. Nothing in this repo generates images.

## Prompt

> A flat vector app icon for a healthcare app called MedGuardian. A solid deep teal shield, hex `#0B6E5F`, centred on a pure white background. Inside the shield, a single clean white heartbeat line (ECG trace) running horizontally across the middle, with one sharp peak and one trough, rounded stroke caps, thick and confident. Completely flat: no gradient, no glow, no drop shadow, no bevel, no 3D, no texture, no outline around the shield. Perfectly symmetrical, generous padding around the shield so it reads clearly at 48px. Modern, clinical, trustworthy. Minimal geometric vector style, not illustrative. Square 1024x1024.

## Variants worth generating

Ask for these in the same style so they stay consistent:

| Variant | Change to the prompt |
| --- | --- |
| Adaptive foreground (Android) | Transparent background instead of white, shield slightly smaller for the safe zone |
| Monochrome / themed icon | Solid black shield and trace on transparent, no colour |
| Notification icon | White shield silhouette on transparent, no interior detail |

## Wiring it up

```bash
flutter pub add --dev flutter_launcher_icons
```

Add to `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/icon/icon.png
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: assets/icon/icon_foreground.png
```

Then:

```bash
dart run flutter_launcher_icons
```

The in-app logo mark is drawn in code at `lib/shared/widgets/brand_mark.dart` and already matches this design, so the launcher icon and the splash mark will look like the same product.
