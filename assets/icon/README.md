# App icon sources

Drop two PNGs here, then run `dart run flutter_launcher_icons` from the project root.

| File | Size | Content |
|---|---|---|
| `icon.png` | 1024×1024 | The **full** icon — the blue "B" card mark on a solid dark (`#0D1117`) background. No transparency, no rounded corners (iOS rounds it), no noise/blur. Used for iOS and legacy Android. |
| `icon_foreground.png` | 1024×1024 | **Just the blue "B" mark**, centred, transparent background, occupying ~65% of the canvas (Android's adaptive-icon mask crops the outer ~25%). |

If you only have one square image, save it as `icon.png` and also as
`icon_foreground.png` for now — the Android adaptive version will look a bit
tight until a proper transparent foreground is supplied.

The grungy/noisy background in the mockup should be flattened to a clean solid
colour before shipping — it reads as "dirty" at 48 px and can fail App Store
review.
