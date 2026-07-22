# MedGuardian backend specification

This document is the complete contract between the Flutter client and the backend. Build every endpoint below exactly as specified, deploy it, and hand back one base URL. The app then works with no further changes:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-backend.example.com
```

Nothing else in the client needs to be touched. Every path the client calls is declared in `lib/core/network/api_endpoints.dart` and mirrors this file exactly.

---

## 1. Ground rules

**Base URL.** All paths below are relative to the base URL. No `/api` or version prefix, so `POST /auth/login` is `https://your-backend.example.com/auth/login`. If you want a prefix, put it in the base URL itself.

**Content type.** JSON in, JSON out, UTF-8.

**Authentication.** Bearer token. After login or register, the client stores `access_token` in platform secure storage and sends it on every subsequent request:

```
Authorization: Bearer <access_token>
```

A `401` on any endpoint makes the client discard the token and send the user back to sign in.

**Dates.** Every date and timestamp is an ISO 8601 string in UTC, for example `2026-07-22T09:14:00Z`. Date-only fields may be `2026-07-22`. The client parses both.

**Field naming.** `snake_case` everywhere. This matters. The client parses these exact keys.

**Nulls.** Omit an optional field or send `null`. Both are handled. Never send an empty string where a number or date is expected.

**Errors.** Non-2xx responses should carry a human-readable message. The client shows it to the user verbatim, so write messages a patient can understand.

```json
{ "detail": "That email is already registered." }
```

The client checks `detail`, then `message`, then `error`, in that order.

**Ontomorph.** The backend is the only thing that talks to Ontomorph. Do not expose Ontomorph credentials to the client. Each of the endpoints below maps onto one or more Ontomorph modules, noted per section.

---

## 2. Authentication

### `POST /auth/register`

Creates an account. Does **not** create the Digital Twin, that is a separate call the client makes next.

Request:
```json
{
  "full_name": "Ada Okoro",
  "email": "ada.okoro@example.com",
  "password": "a-strong-password"
}
```

Response `201`:
```json
{
  "access_token": "eyJhbGciOi...",
  "user": {
    "id": "user_01H8X",
    "full_name": "Ada Okoro",
    "email": "ada.okoro@example.com",
    "twin_id": null
  }
}
```

`twin_id` is `null` until the twin is created. The client uses this to decide whether to show the twin setup screen.

### `POST /auth/login`

Request:
```json
{ "email": "ada.okoro@example.com", "password": "a-strong-password" }
```

Response `200`: identical shape to register, with `twin_id` populated if a twin exists.

### `GET /auth/me`

Returns the current user. Called on app launch to restore the session.

Response `200`:
```json
{
  "id": "user_01H8X",
  "full_name": "Ada Okoro",
  "email": "ada.okoro@example.com",
  "twin_id": "twin_01H8Y"
}
```

Return `401` if the token is invalid or expired.

### `POST /auth/logout`

Invalidate the token server-side. Response `204`. The client clears local storage regardless of the outcome.

---

## 3. Twin Core

> Ontomorph: **Twin Core**. Create a real Ontomorph twin here and store the mapping from your `user.id` to the Ontomorph twin id and DID.

### `POST /twin`

Creates the Digital Twin for the authenticated user.

Request:
```json
{
  "full_name": "Ada Okoro",
  "date_of_birth": "1994-03-17",
  "sex": "female",
  "height_cm": 168,
  "weight_kg": 72.4,
  "blood_type": "O+",
  "conditions": [],
  "allergies": [],
  "family_history": []
}
```

`sex` is one of `female`, `male`, `intersex`, `undisclosed`. Any unrecognised value is coerced to `undisclosed` by the client, but please send one of these four.

Response `201`: the twin object (see below).

### `GET /twin`

Returns the authenticated user's twin.

Response `200`:
```json
{
  "id": "twin_01H8Y",
  "did": "did:onto:8f2a4c19",
  "full_name": "Ada Okoro",
  "date_of_birth": "1994-03-17",
  "sex": "female",
  "height_cm": 168,
  "weight_kg": 72.4,
  "blood_type": "O+",
  "conditions": ["Prediabetes", "Elevated blood pressure"],
  "allergies": ["Penicillin", "Peanuts"],
  "family_history": ["Type 2 diabetes (mother)", "Hypertension (father)"],
  "created_at": "2025-12-20T10:00:00Z",
  "updated_at": "2026-07-21T08:30:00Z"
}
```

`did` must be the real Ontomorph decentralised identifier. The client displays it on the twin profile and the emergency card, and truncates it for compact display.

BMI is **not** sent. The client derives it from `height_cm` and `weight_kg`.

Return `404` if no twin exists yet, so the client can route to twin setup.

### `PATCH /twin/profile`

Partial update. Accepts any subset of the writable fields from `POST /twin`. Response `200`: the full updated twin.

---

## 4. Health Events

> Ontomorph: **Health Events** and **Hidden Events**.

### `GET /events`

Returns every event on the twin, **including hidden ones** (this is the patient's own view). Sort newest first, though the client re-sorts defensively.

Response `200`:
```json
[
  {
    "id": "evt_01H90",
    "type": "measurement",
    "title": "Blood pressure 138/89",
    "description": "Home reading, taken after breakfast.",
    "occurred_at": "2026-07-21T07:15:00Z",
    "severity": "mild",
    "is_hidden": false,
    "clinical_code": "LOINC 85354-9",
    "metadata": {}
  }
]
```

`type` is one of: `symptom`, `diagnosis`, `medication`, `vaccination`, `lab_result`, `measurement`, `visit`, `procedure`, `allergy`, `note`. Unknown values fall back to `note`.

`severity` is one of: `none`, `mild`, `moderate`, `severe`, `critical`. Unknown values fall back to `none`.

`clinical_code` is optional. Populate it from Ontomorph **Clinical Mappings** (ICD-10, SNOMED, LOINC) where you can. The client renders it as a small pill and it makes the app look considerably more credible in the demo.

`metadata` is a free-form object. Send `{}` if unused.

### `POST /events`

Creates an event. The client sends this when a symptom is analysed and when a reading is logged.

Request: same shape as the response object, minus `id` (the client sends a temporary id, ignore it and mint your own).

Response `201`: the created event, with the server-assigned `id`.

**Important:** creating an event must propagate. After this call the client re-fetches the timeline, risk score and insights, and expects them to reflect the new event.

### `DELETE /events/{id}`

Response `204`.

### `POST /events/{id}/hide`

Toggles whether an event is withheld from provider-facing views.

Request:
```json
{ "hidden": true }
```

Response `200` or `204`. Hidden events must never appear in `GET /clinical-summary` or any FHIR export.

### `GET /events/emergency-card`

Optional. The client currently composes the emergency card from `GET /twin` and `GET /medications`. Implement this if you want a single optimised call, otherwise skip it.

---

## 5. Symptom analysis

> Ontomorph: **Events**, **Twin**, **Insights**, plus your LLM of choice.

### `POST /symptoms/analyse`

The most important endpoint in the app. Takes free text, returns structured triage.

Request:
```json
{ "description": "I have had headaches for four days and it gets worse in the evening" }
```

Response `200`:
```json
{
  "id": "analysis_01H91",
  "urgency": "routine",
  "summary": "This is your third headache logged this month, and it lands alongside a six month rise in blood pressure.",
  "extracted_symptoms": ["Headache", "Recurring pattern"],
  "possible_conditions": [
    {
      "name": "Hypertension related headache",
      "likelihood": 0.41,
      "description": "Consistent with your rising systolic readings.",
      "clinical_code": "ICD-10 G44.1"
    }
  ],
  "next_steps": [
    "Book a blood pressure review this week",
    "Log a reading each morning until the appointment"
  ],
  "follow_up_questions": [
    "Does the pain get worse when you bend forward?"
  ],
  "analysed_at": "2026-07-22T09:14:00Z",
  "created_event_id": "evt_01H92"
}
```

`urgency` is one of `self_care`, `routine`, `urgent`, `emergency`. Unknown values fall back to `routine`.

`likelihood` is a decimal between 0 and 1, not a percentage. The client multiplies by 100 for display.

**This must use the twin, not just the text.** The quality of the demo rests on `summary` referencing the patient's actual history and biomarker trends. Pull the twin, recent events and biomarker trends into the prompt before generating. A generic answer that ignores the record defeats the point of the product.

**Safety.** Never phrase output as a diagnosis. `emergency` urgency must be returned for anything involving chest pain, breathing difficulty, sudden numbness, stroke signs, severe bleeding or loss of consciousness. Err toward higher urgency when uncertain.

`created_event_id` is optional. The client also creates its own event via `POST /events`, so if you create one here, return its id and the client will avoid duplicating.

---

## 6. Biomarkers

> Ontomorph: **Biomarker Trends** and **Metrics**.

### `GET /biomarkers`

Response `200`:
```json
[
  {
    "code": "blood_pressure_systolic",
    "name": "Systolic blood pressure",
    "unit": "mmHg",
    "reference_low": 90,
    "reference_high": 130,
    "trend": "worsening",
    "readings": [
      { "value": 118, "recorded_at": "2026-02-21T08:00:00Z", "source": "manual" },
      { "value": 138, "recorded_at": "2026-07-21T07:15:00Z", "source": "manual" }
    ]
  }
]
```

`readings` must be sorted **oldest first**. The client charts them left to right in the order received and treats the last element as the current value.

`trend` is one of `improving`, `stable`, `worsening`. Compute it from the series using Ontomorph Biomarker Trends rather than a naive last-two comparison.

Codes the client expects, and pins to the dashboard: `blood_pressure_systolic`, `blood_glucose`, `bmi`, `resting_heart_rate`. Also supported: `hba1c`, `total_cholesterol`. Additional codes render fine on the biomarkers screen, they just are not pinned to the dashboard.

`reference_low` and `reference_high` drive the dashed range lines on the chart and the out-of-range highlighting. Send them whenever clinically meaningful.

### `POST /biomarkers`

Records a new reading.

Request:
```json
{
  "code": "blood_pressure_systolic",
  "value": 141,
  "recorded_at": "2026-07-22T09:20:00Z"
}
```

Response `200`: the full updated biomarker object with the new reading appended and `trend` recalculated.

### `GET /biomarkers/{code}/trend`

Optional. Reserved for a per-biomarker detail view. Not called by the current client.

---

## 7. Risk, insights and simulation

> Ontomorph: **Insights**, **Alert Rules**, **Analytics**, **Simulations**.

### `GET /risk-score`

Response `200`:
```json
{
  "score": 68,
  "band": "moderate",
  "previous_score": 76,
  "calculated_at": "2026-07-21T22:00:00Z",
  "factors": [
    {
      "label": "Blood pressure rising",
      "impact": 12,
      "direction": "raises",
      "detail": "Up 20 mmHg systolic over six months."
    },
    {
      "label": "Cholesterol improving",
      "impact": 4,
      "direction": "lowers",
      "detail": "Down 21 mg/dL since January."
    }
  ]
}
```

`score` is 0 to 100 where **higher is better**. `band` is one of `low`, `moderate`, `high`, `critical`. Suggested mapping, which the client also implements as a fallback: 80+ low, 60 to 79 moderate, 40 to 59 high, below 40 critical.

`previous_score` drives the "up 8 points since last month" delta. Omit it if there is no prior score.

`direction` is `raises`, `lowers` or `neutral`. `impact` is a positive integer, the client applies the sign from `direction`.

### `GET /insights`

Response `200`:
```json
[
  {
    "id": "ins_01H93",
    "title": "Your blood pressure has climbed every month since February",
    "body": "Six consecutive readings have moved upward, from 118 to 138 mmHg systolic.",
    "severity": "watch",
    "recommendation": "Book a blood pressure review this week.",
    "related_biomarker": "blood_pressure_systolic",
    "generated_at": "2026-07-21T22:00:00Z"
  }
]
```

`severity` is one of `positive`, `informational`, `watch`, `urgent`. Include at least one `positive` insight when the data supports it, the dashboard reads as unnecessarily alarming otherwise.

`recommendation` is optional and rendered as a highlighted call to action.

### `POST /simulations`

Projects current trends forward.

Request:
```json
{ "question": "What happens if I continue ignoring my blood pressure?" }
```

Response `200`:
```json
{
  "id": "sim_01H94",
  "question": "What happens if I continue ignoring my blood pressure?",
  "scenario": "unchanged",
  "generated_at": "2026-07-22T09:30:00Z",
  "horizons": [
    {
      "label": "Today",
      "outcome": "Stage 1 hypertension with prediabetic glucose.",
      "risk_level": 0.32,
      "projected_value": "138/89 mmHg"
    },
    {
      "label": "1 year",
      "outcome": "Materially higher cardiovascular risk.",
      "risk_level": 0.71,
      "projected_value": "152/96 mmHg"
    }
  ],
  "preventive_actions": [
    "Reduce added salt to under 5g per day",
    "Walk 30 minutes, five days a week"
  ]
}
```

`scenario` is `unchanged` or `improved`. `risk_level` is 0 to 1 and drives the projection chart, so it should increase monotonically for an `unchanged` scenario and decrease for `improved`. Four horizons render best: today, 3 months, 1 year, 5 years.

---

## 8. Medications

> Ontomorph: **Events** of type `medication`, plus a drug reference source.

### `GET /medications`

Response `200`:
```json
[
  {
    "id": "med_01H95",
    "name": "Lisinopril",
    "generic_name": "Lisinopril",
    "dosage": "5 mg",
    "frequency": "Once daily",
    "started_on": "2026-06-22",
    "ended_on": null,
    "uses": ["Lowers high blood pressure"],
    "side_effects": ["Dry cough", "Dizziness when standing up quickly"],
    "interactions": ["Ibuprofen and other NSAIDs reduce its effect"],
    "warnings": ["Not safe in pregnancy"]
  }
]
```

`ended_on: null` means the medication is active. The client splits the list on this.

**Cross-check against allergies.** If a medication conflicts with something in the twin's `allergies`, surface it in `warnings`. The demo dataset deliberately includes a penicillin allergy alongside a past amoxicillin course to exercise this.

### `GET /medications/lookup?name=lisinopril`

Returns a single medication object for a name search. Response `200`.

---

## 9. Clinical summary, FHIR and sharing

> Ontomorph: **Provider APIs**, **Clinical Summary**, **FHIR Export**, **Temporary Access**.

### `POST /clinical-summary`

Generates a doctor-facing summary. This is a `POST` because generating is a side-effecting operation.

Response `200`:
```json
{
  "id": "sum_01H96",
  "generated_at": "2026-07-22T09:40:00Z",
  "patient_name": "Ada Okoro",
  "patient_age": 32,
  "overview": "Thirty-two year old female with prediabetes and newly elevated blood pressure...",
  "active_problems": ["Stage 1 hypertension", "Prediabetes"],
  "recent_events": [ /* HealthEvent objects, hidden ones excluded */ ],
  "medications": [ /* Medication objects, active only */ ],
  "biomarkers": [ /* Biomarker objects */ ],
  "recommendations": [
    "Confirm blood pressure with an ambulatory monitor",
    "Order oral glucose tolerance test"
  ]
}
```

**Hidden events must be excluded.** This is the whole point of the hidden events feature and a privacy failure if it leaks.

`overview` should read like a clinician wrote it: age, sex, active problems, what is trending and in which direction, current treatment.

### `GET /fhir/export`

Returns a FHIR R4 `Bundle` for the twin. The client copies it to the clipboard, so any valid bundle works.

Response `200`:
```json
{
  "resourceType": "Bundle",
  "type": "collection",
  "entry": [
    { "resource": { "resourceType": "Patient", "id": "twin_01H8Y", "name": [{ "text": "Ada Okoro" }], "gender": "female", "birthDate": "1994-03-17" } },
    { "resource": { "resourceType": "Observation", "...": "..." } }
  ]
}
```

Map to these resource types: `Patient` from the twin, `Observation` from biomarker readings, `Condition` from diagnosis events, `MedicationStatement` from medications, `AllergyIntolerance` from allergies, `Encounter` from visit events. Prefer Ontomorph's own FHIR Export over hand-rolling this.

### `POST /access-grants`

Issues a time-limited access grant so a clinician can open the record.

Request:
```json
{ "duration_minutes": 1440 }
```

Response `201`:
```json
{
  "id": "grant_01H97",
  "code": "MG-4K9T-2XPQ",
  "expires_at": "2026-07-23T09:45:00Z",
  "granted_to": null
}
```

`code` is shown to the user in a large font to read out or hand over, so keep it short, unambiguous and upper case. Avoid characters that look alike, no `0`/`O` or `1`/`I`/`l`. Enforce expiry server-side, the client only displays it.

---

## 10. Hospitals

### `GET /hospitals/nearby?lat=6.45&lng=3.42`

The client currently calls this without coordinates. Accept optional `lat` and `lng` query parameters and fall back to a sensible default region when they are absent.

Response `200`:
```json
[
  {
    "id": "hos_01H98",
    "name": "Lagoon General Hospital",
    "address": "14 Marina Road, Lagos Island",
    "distance_km": 1.8,
    "travel_minutes": 7,
    "specialties": ["Emergency", "Cardiology"],
    "phone": "+234 800 000 0001",
    "image_url": "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d",
    "has_emergency": true,
    "is_open_now": true
  }
]
```

Sort nearest first. `image_url` must be a plain HTTPS image URL, the client appends its own sizing query parameters.

---

## 11. Build order

If time is short, build in this order. The client degrades gracefully and shows an error state per section, so partial delivery still demos.

1. `POST /auth/register`, `POST /auth/login`, `GET /auth/me`
2. `POST /twin`, `GET /twin`
3. `GET /events`, `POST /events`
4. `GET /biomarkers`, `POST /biomarkers`
5. `GET /risk-score`, `GET /insights`
6. `POST /symptoms/analyse`
7. `POST /clinical-summary`, `GET /fhir/export`
8. `POST /simulations`
9. `GET /medications`, `GET /hospitals/nearby`, `POST /access-grants`

Steps 1 to 6 cover the core demo. Everything after that is upside.

---

## 12. Checklist before handing back the URL

- [ ] HTTPS, with a valid certificate. Android blocks plain HTTP by default.
- [ ] CORS is irrelevant for the mobile client, ignore it unless a web build is added.
- [ ] `GET /auth/me` returns `401`, not `500`, for a bad token.
- [ ] `GET /twin` returns `404`, not `500`, when no twin exists.
- [ ] Every timestamp is ISO 8601.
- [ ] Every key is `snake_case`.
- [ ] Biomarker `readings` are sorted oldest first.
- [ ] Hidden events are absent from `POST /clinical-summary` and `GET /fhir/export`.
- [ ] `POST /symptoms/analyse` returns `emergency` for chest pain and breathing difficulty.
- [ ] At least one seeded demo account exists with roughly six months of history, so the trends and projections have something to show.

Send back the base URL and the demo account credentials. That is all the client needs.
