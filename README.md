# MedGuardian

Preventive healthcare mobile app built on the Ontomorph Digital Twin Platform.

MedGuardian is not a symptom-checker chatbot. Every user owns a **Digital Twin**: a continuously updated, patient-owned representation of their health. Symptoms, biomarkers, medications and visits all flow into the same twin, so one action propagates through the whole system.

```
Report a symptom
  -> Health Event created
  -> Twin updated
  -> Biomarker trends recalculated
  -> Alert rules evaluated
  -> Risk score refreshed
  -> Simulation and insights regenerated
```

## Status

Built for the Ontomorph Hackathon 2026. The Flutter client is under active development.

## Features

| Area | What it does |
| --- | --- |
| Digital Twin profile | Demographics, history, allergies and biometrics in one record |
| Symptom analysis | Turns a described symptom into a structured Health Event |
| Health timeline | Chronological view of everything the twin knows |
| Biomarker tracking | Blood pressure, glucose, cholesterol, HbA1c, BMI, heart rate over time |
| Health risk score | A single score with the factors that drive it |
| Predictive simulation | Projects where a trend leads if nothing changes |
| Emergency detection | Alert-rule driven warnings with an emergency card |
| Medication assistant | Uses, side effects, interactions and warnings |
| Hospital finder | Nearby facilities with distance and specialties |
| Clinical summary | One-tap doctor summary with FHIR export and time-boxed access |

## Tech stack

- **Flutter** (Dart 3.10) targeting Android and iOS
- **Riverpod** for state management
- **go_router** for navigation
- **Dio** for HTTP
- **fl_chart** for biomarker trend charts

The client talks to a FastAPI backend which fronts the Ontomorph Digital Twin Platform. Every endpoint the app expects is specified in `docs/BACKEND_SPEC.md`.

## Project structure

```
lib/
  app/          Application root, theme wiring and route table
  core/         Theme tokens, networking, shared utilities
  features/     One folder per feature, each with domain and presentation
  shared/       Widgets reused across more than one feature
doc/            Product requirements and Ontomorph platform notes
docs/           Backend specification and engineering notes
```

Each feature folder is self-contained so features can be built and reviewed independently.

## Getting started

```bash
flutter pub get
flutter run
```

With no backend URL supplied the app runs on a built-in demo dataset, so it is fully explorable straight after clone. Point it at a real backend by passing the base URL at build time:

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.example.com
```

That single flag is the only change needed to move from demo data to live data. Repository selection happens in `lib/app/providers.dart`.

## Releases

Every push to `main` runs analysis and tests, builds a release APK, tags the build and publishes it to [Releases](https://github.com/Ferousco-dev/medguardian/releases). Universal and per-ABI APKs are attached to each release.

## Documentation

| Document | Purpose |
| --- | --- |
| [`docs/BACKEND_SPEC.md`](docs/BACKEND_SPEC.md) | Complete API contract. Build these endpoints, return a base URL, and the app works |
| [`docs/DESIGN_REFERENCE.md`](docs/DESIGN_REFERENCE.md) | Design patterns adopted and deliberately rejected |
| [`docs/APP_ICON_PROMPT.md`](docs/APP_ICON_PROMPT.md) | Prompt and wiring for the launcher icon |

## Design

Light theme only for now. Flat surfaces, hairline borders, no gradients. The full token set lives in `lib/core/theme/`.

## Licence

MIT
