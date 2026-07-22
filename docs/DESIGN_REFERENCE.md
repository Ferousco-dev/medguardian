# Design reference

Patterns taken from real shipped health app UI, reviewed on Dribbble (searches: "health tracking app", "medical app light ui"). Structure is borrowed, styling is not: nearly every popular shot leans on dark backgrounds, gradients and glow. MedGuardian keeps the layout patterns and drops all of that.

## Patterns adopted

| Pattern | Where it came from | How MedGuardian uses it |
| --- | --- | --- |
| Oversized numeric hero | Daily score shots showing a single large figure (`95`, `41`, `12,231`) | Health risk score screen and the dashboard score card |
| Metric tile grid | Two-column grids of small labelled tiles with a delta chip | Dashboard vitals and the twin profile |
| Status pill on every reading | `Normal` / `Excellent` chips beside lab values | Biomarker rows, coloured from status tokens |
| Delta chip with direction | `+2%` / `-7%` beside each metric | Biomarker cards, showing change since the previous reading |
| Sparkline under the value | Compact trend line inside a metric tile | Biomarker tiles on the dashboard |
| Segmented range switcher | `Month` / `Week` toggle above a chart | Biomarker detail chart range control |
| Grouped card sections | Related rows inside one bordered panel | `SectionCard`, used across every screen |

## Deliberately rejected

- Gradient and mesh backgrounds. Every shot that used them looked dated at small sizes and unreadable behind data.
- Dark-first palettes. Clinical content needs to be legible in a waiting room in daylight.
- Glass blur panels, glow and neon accents.
- Decorative 3D illustration. Onboarding previews the real UI instead.

## Photography

Photos are only used where a real place or person is being represented (hospital cards, provider avatars). Everything else is drawn from theme tokens. Sources are Unsplash, catalogued in `lib/core/constants/app_images.dart`.
