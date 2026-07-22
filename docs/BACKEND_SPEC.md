# MedGuardian backend specification

This document is the complete contract between the Flutter client and the backend. Build every endpoint below exactly as specified, deploy it, and hand back one base URL. The app then works with no further changes:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-backend.example.com
```

Nothing else in the client needs to be touched. Every path the client calls is declared in `lib/core/network/api_endpoints.dart` and mirrors this file exactly.

**Read [`ONTOMORPH_PLATFORM.md`](ONTOMORPH_PLATFORM.md) first.** It documents the real Ontomorph and HOLON API surface. Your job is mostly to be a thin, authenticated proxy in front of it, not to reinvent it. Each section below names the Ontomorph endpoint that should back it.

### Why the backend exists at all

The mobile client must never hold the Ontomorph API key or the HOLON key. Your service holds both, maps our user accounts onto twins, and issues grants on the patient's behalf. Two keys:

| Key | Targets | Header |
| --- | --- | --- |
| `DTP_KEY` | Twin Core | `Authorization: Bearer <key>` |
| `HOLON_KEY` | `https://holon-api.ontomorph.com` | `Authorization: Bearer <key>` |

Do not build a health database. Ontomorph is the database. You should be storing little more than: user credentials, the mapping from user to twin id, and issued grant ids.

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

> Ontomorph: `POST /twins/`, `GET /twins/{id}`, `PATCH /twins/{id}`.
>
> Create a real Ontomorph twin and store the mapping from your `user.id` to the twin UUID. There is also `POST /twins/seed-demo` which seeds a demo patient, which is the fastest way to get a populated twin for the demo account.
>
> The platform returns `personalisationProfile { age, sex, heightCm, weightKg, bmi, skinTone, ancestry }` and a DID of the form `did:dtp:{uuid}`. Note that **age is a number and BMI is computed for you**, so pass both straight through rather than recomputing. Our client stores date of birth locally and can send either.
>
> Platform `sex` accepts `male`, `female`, `intersex`. Our client has a fourth option, `undisclosed`, for users who skip the question. Hold that on your side and omit `sex` from the platform call when it is set.

### `POST /twin`

Creates the Digital Twin for the authenticated user. The client calls this immediately after registration with **only the name**, because health details are collected afterwards in a flow the user is allowed to skip.

Minimum request the client actually sends:
```json
{ "full_name": "Ada Okoro" }
```

Full request shape, all fields other than `full_name` optional:
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

**Do not require the health fields.** A twin with nothing but a name is a valid, expected state. `date_of_birth`, `height_cm`, `weight_kg` and `blood_type` must all accept `null`, and the array fields must accept `[]`.

`sex` is one of `female`, `male`, `intersex`, `undisclosed`. Any unrecognised or absent value is treated as `undisclosed` by the client, which is also the value it sends when the user skips that question.

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

BMI is **not** sent. The client derives it from `height_cm` and `weight_kg`, and treats it as unknown when either is missing.

**Nullable fields.** `date_of_birth`, `height_cm`, `weight_kg` and `blood_type` may all be `null` on a partially completed twin. Send `null`, never `0` or an empty string. The client counts how many of the nine profile fields are populated and shows the user a completion percentage, so a zero would be read as a real answer and inflate that number.

Return `404` if no twin exists yet, so the client can route to twin setup.

### `PATCH /twin/profile`

Partial update, used by the health details flow and by every later edit. Accepts any subset of the writable fields from `POST /twin`. Response `200`: the full updated twin.

Because the flow is skippable and resumable, this endpoint gets called repeatedly with partial payloads. Merge into the existing twin rather than replacing it, and never reject a payload for missing fields.

---

## 4. Health Events

> Ontomorph: `POST|GET /twins/{id}/events/`, `DELETE /twins/{id}/events/{eventId}`, `GET /twins/{id}/events/emergency-card`, and `POST|GET|DELETE /twins/{id}/hidden-events/`.
>
> An Ontomorph event carries **a code, a value, and the body system it affects**. Our `body_system` field maps to that directly: `cardiovascular`, `nervous`, `endocrine`, `skeletal`, `immune` and so on. Populate it, because it is what makes the event addressable on the 3D anatomy later.
>
> `GET /twins/{id}/events/conflicts` surfaces contradictory events and is worth exposing if you have time.

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

`clinical_code` is optional. Populate it via HOLON `mappings.translate(code, fromVocabulary, toVocabulary)`, which spans 19 vocabularies including SNOMED CT, LOINC, RxNorm and ICD-10. The client renders it as a small pill and it makes the app look considerably more credible in the demo.

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

## 6. Health assistant chat

> Ontomorph: **Twin**, **Events**, **Biomarker Trends**, **Insights**, plus your LLM.

### `POST /chat`

Conversational questions about the user's own record. This is the screen where the twin has to visibly pay off, so the reply must cite the record.

Request:
```json
{
  "message": "Why is my health score 68?",
  "history": [
    { "id": "chat_1", "role": "assistant", "text": "...", "sent_at": "2026-07-22T09:00:00Z" },
    { "id": "user_2", "role": "user", "text": "...", "sent_at": "2026-07-22T09:01:00Z" }
  ]
}
```

`history` is the full conversation so far, oldest first, so the endpoint can stay stateless.

Response `200`:
```json
{
  "id": "chat_01H99",
  "role": "assistant",
  "text": "Your score is 68, down from 76 last month. Three things pull it down...",
  "sent_at": "2026-07-22T09:01:30Z",
  "grounded_on": ["Risk score", "Blood pressure", "Fasting glucose"],
  "suggestions": ["How do I bring my blood pressure down?"],
  "is_emergency": false
}
```

`grounded_on` is the list of record sections the answer actually used. The client renders these as chips under the reply, labelled "Read from your twin". Send short human labels, not internal ids. Leave it empty rather than inventing entries, a wrong citation is worse than none.

`suggestions` are follow-up prompts offered as tappable chips. Two or three is plenty. Two strings are handled specially by the client and route instead of sending a message: anything containing `Report a symptom` opens symptom analysis, anything containing `clinical summary` opens the summary screen.

`is_emergency` set to `true` makes the client render the reply in the danger style and show an "Open emergency card" button. Set it for chest pain, breathing difficulty, stroke signs, severe bleeding or loss of consciousness, and keep the reply short and directive when you do.

**Grounding is the whole point.** Load the twin, recent events and biomarker trends into the prompt. A reply that could have been written without the record makes the entire product look like a wrapper.

**Never diagnose.** Explain, contextualise against the record, and route to a clinician.

---

## 7. Biomarkers

> Ontomorph: `GET /twins/{id}/biomarker-trends/` and `GET /twins/{id}/biomarker-trends/{loincCode}?window_days=90`.
>
> **Trends are keyed by LOINC code, not by a name.** The platform computes the trend direction, so do not write your own. HOLON supplies the reference ranges: `GET /reference-ranges/{loincCode}?age={age}&sex={sex}` returns ranges stratified by age and sex, which is what our client displays under each chart.

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

LOINC codes the client uses:

| Biomarker | LOINC | Pinned to dashboard |
| --- | --- | --- |
| Systolic blood pressure | `8480-6` | yes |
| Fasting glucose | `1558-6` | yes |
| Body mass index | `39156-5` | yes |
| Resting heart rate | `8867-4` | yes |
| HbA1c | `4548-4` | no |
| Total cholesterol | `2093-3` | no |
| Oxygen saturation | `2708-6` | no |

Additional LOINC codes render fine on the biomarkers screen, they are simply not pinned to the dashboard grid.

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

## 8. Risk, insights and simulation

> Ontomorph: `GET /insights/`, `GET /insights/stream` (server-sent events), `POST /twins/{id}/alert-rules/`, `POST /twins/{id}/alert-rules/evaluate`, `POST /simulations/`, `GET /simulations/{id}`, `GET /v1/analytics/readiness/{patientId}`, `POST /v1/cdss/calculate-news2`.
>
> **Use alert rules rather than hard-coded thresholds.** A rule takes `loincCode`, `loincDisplay`, `ruleType`, `operator` and `thresholdValue`. Create sensible defaults when a twin is created, then call `evaluate` after every new reading. That call is what should drive our emergency detection.
>
> **NEWS2 is available as a scored endpoint** at `POST /v1/cdss/calculate-news2`. It is a recognised clinical early warning score, and grounding our risk number in it is far more defensible than a bespoke calculation. If you use it, return the NEWS2 value in `metadata` alongside our 0 to 100 score.
>
> `GET /simulations/{id}/animation` returns a rendered animation of the projection. We do not consume it yet, but do not discard it, it is a strong demo asset.

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

## 9. Medications

> Ontomorph: events of type `medication`. **Interactions and warnings must come from HOLON**, not from a list you write.
>
> `GET https://holon-api.ontomorph.com/interactions/check-list` against the patient's full medication list checks it against 1.7 million known interactions. `GET /concepts?q={name}&domain=Drug` resolves a drug name to a concept id first.
>
> This is the single cheapest way to score on the "use of the platform" criterion, and it is also the difference between a real safety check and a hard-coded string.

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

## 10. Clinical summary, FHIR and sharing

> Ontomorph: `GET /provider/twins/{id}/clinical-summary`, `POST /fhir/export/` then `GET /fhir/export/{jobId}` then `GET /fhir/export/{jobId}/file/{type}`, and the grants API for temporary access.
>
> **FHIR export is an asynchronous job on the platform.** Kick it off, poll the job, then fetch the file. Our client expects a single synchronous call that returns the bundle, so absorb the polling on your side and only respond once the file is ready.
>
> **Temporary access must be a real Ontomorph grant**, created with a scope list and an `expiresAt`, and revocable. Do not invent your own sharing mechanism, the platform's consent model is one of the things being judged. Map our `duration_minutes` onto `expiresAt`, and return the scopes you requested so the client can show the patient exactly what they granted.

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

## 11. Health library

### `GET /guides`

Optional. The client currently ships this content locally, so the library works offline and needs no backend. Implement it only if content should be editable without an app release.

```json
[
  {
    "id": "guide_bp",
    "title": "Taking a blood pressure reading that actually means something",
    "summary": "Most home readings are wrong for avoidable reasons.",
    "image_url": "https://images.unsplash.com/photo-1615486511484-92e172cc4fe0",
    "read_minutes": 3,
    "related_biomarker": "blood_pressure_systolic",
    "sections": [
      {
        "heading": "Why the number moves so much",
        "body": "Blood pressure is not one value...",
        "points": ["Sit still for five minutes with your back supported"]
      }
    ]
  }
]
```

`related_biomarker` matches a biomarker `code`, so a guide can be surfaced next to the trend it explains.

---

## 12. Data sources and where numbers come from

> Ontomorph: **Twin Core** (seed), **Events**, **Metrics**, **FHIR**.

This section exists because of one rule the whole product rests on:

**MedGuardian never produces a measurement. It only records one, then derives everything else from it.**

Trends, risk scores, insights and simulations are all computed. The raw numbers must enter from outside, through exactly four doors: the patient types them, a device sends them, a clinic sends them, or a lab report is parsed. The client shows the user which door each reading came through, so none of these may be faked server-side.

### `GET /sources`

Lists every source, connected or not.

```json
[
  {
    "id": "src_health_connect",
    "name": "Health Connect",
    "kind": "wearable",
    "provider": "health_connect",
    "is_connected": false,
    "last_synced_at": null,
    "supplied_markers": ["resting_heart_rate", "bmi", "oxygen_saturation"],
    "reading_count": 0
  }
]
```

`kind` is one of `manual`, `wearable`, `clinic`, `lab`, `demo`. Unknown values fall back to `manual`.

**`supplied_markers` must be honest.** A wrist wearable cannot measure fasting glucose or blood pressure. Health Connect realistically supplies heart rate, steps, weight and sometimes SpO2. If you list `blood_glucose` under a fitness band, the app shows the user a promise it cannot keep. Only list what that source genuinely writes.

### `POST /sources/{id}/connect` and `POST /sources/{id}/disconnect`

Response `200`: the updated source object.

Connect is where the OAuth or pairing handshake for that provider happens. Disconnect stops future syncs and **must not delete readings already on the twin**, the client tells the user exactly that.

### `POST /sources/{id}/sync`

Pulls whatever is new from that source and writes it onto the twin as readings and events.

Response `200`:
```json
{
  "source_id": "src_health_connect",
  "readings_added": 12,
  "events_added": 0,
  "synced_at": "2026-07-22T09:40:00Z"
}
```

Return zeros rather than an error when there is nothing new, the client has wording for that case.

Every reading written by a sync must carry `source` set to that source's `kind`, so provenance survives into `GET /biomarkers`.

### `POST /imports/fhir`

Accepts a FHIR R4 `Bundle` and merges it into the twin. Same response shape as sync.

Map `Observation` to biomarker readings, `Condition` to diagnosis events, `MedicationStatement` to medications, `AllergyIntolerance` to twin allergies, `Encounter` to visit events. Ontomorph can seed a twin from a FHIR bundle directly, so prefer that over parsing by hand.

**Deduplicate on re-import.** Users will import the same bundle twice. Match on resource id plus effective date and skip what is already present, otherwise the trend charts grow duplicate points.

### `POST /twin/seed-demo`

Seeds the authenticated user's twin with a realistic history: roughly six months of biomarker readings, plus events, medications and allergies. Response `204`.

This is what the demo account uses, and it is the single highest-value endpoint here. Readings it creates must carry `source: "demo"` so nothing pretends to be a real measurement.

Ontomorph exposes demo seeding on Twin Core. **Use the platform's own seeding rather than inventing fixtures**, because "use of the platform" is one of four equally weighted judging criteria and hand-rolled fake data scores nothing on it.

---

## 13. Hospitals

### `GET /hospitals/nearby?lat=6.45&lng=3.42`

Accept optional `lat` and `lng` query parameters and fall back to a sensible default region when they are absent. The client asks for location permission and degrades gracefully when the user declines, so **absent coordinates are a normal case, not an error**. Never return a 4xx for a missing `lat` or `lng`.

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

## 14. Build order

If time is short, build in this order. The client degrades gracefully and shows an error state per section, so partial delivery still demos.

1. `POST /auth/register`, `POST /auth/login`, `GET /auth/me`
2. `POST /twin`, `GET /twin`
3. `GET /events`, `POST /events`
4. `GET /biomarkers`, `POST /biomarkers`
5. `GET /risk-score`, `GET /insights`
6. `POST /symptoms/analyse`, then `POST /chat`
7. `POST /clinical-summary`, `GET /fhir/export`
8. `POST /simulations`
9. `GET /medications`, `GET /hospitals/nearby`, `POST /access-grants`
10. `GET /sources`, `POST /sources/{id}/sync`, `POST /imports/fhir`

Steps 1 to 6 cover the core demo. Everything after that is upside.

**Do `POST /twin/seed-demo` early, out of order.** It is a couple of hours of work and it makes every other screen demonstrable immediately, because the app has real history to draw trends from. Without it the reviewer sees empty charts.

---

## 15. Checklist before handing back the URL

- [ ] HTTPS, with a valid certificate. Android blocks plain HTTP by default.
- [ ] CORS is irrelevant for the mobile client, ignore it unless a web build is added.
- [ ] `GET /auth/me` returns `401`, not `500`, for a bad token.
- [ ] `GET /twin` returns `404`, not `500`, when no twin exists.
- [ ] `POST /twin` succeeds with `{"full_name": "..."}` and nothing else.
- [ ] `PATCH /twin/profile` merges partial payloads instead of replacing the twin.
- [ ] Unset twin fields come back as `null`, never `0` or `""`.
- [ ] Every timestamp is ISO 8601.
- [ ] Every key is `snake_case`.
- [ ] Biomarker `readings` are sorted oldest first.
- [ ] Hidden events are absent from `POST /clinical-summary` and `GET /fhir/export`.
- [ ] `POST /symptoms/analyse` returns `emergency` for chest pain and breathing difficulty.
- [ ] `POST /chat` sets `is_emergency` for the same patterns.
- [ ] `POST /chat` replies quote real values from the record, not generic advice.
- [ ] At least one seeded demo account exists with roughly six months of history, so the trends and projections have something to show.
- [ ] `POST /twin/seed-demo` works and its readings carry `source: "demo"`.
- [ ] Every biomarker reading carries a `source`, never null.
- [ ] `supplied_markers` on each source lists only what that source can really measure.
- [ ] Disconnecting a source leaves existing readings on the twin.
- [ ] Re-importing the same FHIR bundle does not duplicate readings.

Send back the base URL and the demo account credentials. That is all the client needs.
