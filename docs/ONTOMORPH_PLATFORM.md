# Ontomorph platform notes

Taken from `developer.ontomorph.com` on 22 July 2026. This is what the platform actually exposes, as opposed to what the PRD summarised. Read this before `BACKEND_SPEC.md`.

## The two services

| Service | Base URL | Auth |
| --- | --- | --- |
| Twin Core (DTP) | see your keys page | `Authorization: Bearer <JWT>`, plus a **grant token** to act on a specific twin |
| HOLON knowledge | `https://holon-api.ontomorph.com` | `Authorization: Bearer $HOLON_KEY` |

Two separate keys. A live key targets production, a test key targets the sandbox. An API key identifies the caller, it does **not** authorise access to any particular twin. That is what a grant is for.

## Grants: the consent primitive

Access to a twin is always scoped, time-bounded and revocable. The patient owns the grant, the caller holds a token.

```js
const grant = await dtp.grants.create({
  scope: ['cardiovascular:read', 'events:read'],
  expiresAt: '2026-12-31',
});
await dtp.grants.revoke(grant.id);
```

This is exactly what MedGuardian's "share with a doctor" screen should be issuing. Our access code is a wrapper over a real grant, not a bespoke mechanism.

## Twin Core endpoints

Everything is nested under the twin. Twin id is a UUID.

```
GET    /twins/                              list twins for the caller
POST   /twins/                              create
GET    /twins/{id}
PATCH  /twins/{id}
POST   /twins/seed-demo                     seed a demo patient
PUT    /api/internal/twins/{id}/vcf         attach genomic VCF

GET    /twins/{id}/snapshots/               point-in-time captures
POST   /twins/{id}/snapshots/
GET    /twins/{id}/snapshots/{snapshotId}
GET    /twins/{id}/snapshots/version/{version}

POST   /twins/{id}/events/                  create a health event
GET    /twins/{id}/events/
GET    /twins/{id}/events/conflicts
GET    /twins/{id}/events/emergency-card
DELETE /twins/{id}/events/{eventId}

POST   /twins/{id}/hidden-events/           patient hide-from-view
GET    /twins/{id}/hidden-events/
DELETE /twins/{id}/hidden-events/{eventId}

GET    /twins/{id}/biomarker-trends/
GET    /twins/{id}/biomarker-trends/{loincCode}?window_days=90

GET    /twins/{id}/alert-rules/
POST   /twins/{id}/alert-rules/
DELETE /twins/{id}/alert-rules/{ruleId}
POST   /twins/{id}/alert-rules/evaluate

POST   /simulations/
GET    /simulations/{id}
GET    /simulations/{id}/animation

GET    /insights/
GET    /insights/stream                     server-sent events
GET    /insights/preferences
PUT    /insights/preferences
GET    /insights/export

POST   /v1/cdss/calculate-news2             NEWS2 early warning score
GET    /v1/analytics/readiness/{patientId}

POST   /fhir/export/                        async job
GET    /fhir/export/{jobId}
GET    /fhir/export/{jobId}/file/{type}

GET    /provider/twins/by-did/{did}
GET    /provider/twins/{id}/clinical-summary
POST   /provider/twins/{id}/events
POST   /provider/twins/{id}/simulations
GET    /provider/twins/{id}/inspector/{fmaCode}/snapshot

GET    /twins/{id}/secondary-findings/      ACMG SF workflow
GET    /temp-access/events
```

### Things this changes for us

**Biomarkers are keyed by LOINC code, not by a name we invent.** `blood_pressure_systolic` is wrong. It is `8480-6`.

**BMI is computed by the platform**, it comes back on `personalisationProfile`. We should display theirs rather than deriving our own.

**Age is a number on the profile, not a date of birth.**

**Sex is `male | female | intersex`.** There is no `undisclosed` on the platform, so our fourth option has to map to something or be held only on our side.

**FHIR export is an async job**, not a single GET. Kick off, poll, then download the file.

**Alert rules are real objects** with `loincCode`, `loincDisplay`, `ruleType`, `operator`, `thresholdValue`, and a separate `evaluate` call. Our emergency detection should create and evaluate these rather than hard-coding thresholds.

**Insights stream over SSE.** A live dashboard is possible.

**NEWS2 is available as a scored CDSS endpoint.** That is a recognised clinical early warning score, far more credible than a bespoke number.

## Twin shape

```json
{
  "id": "uuid",
  "userId": "uuid",
  "did": "did:dtp:{uuid}",
  "displayName": "Ada Okoro",
  "personalisationProfile": {
    "age": 32,
    "sex": "female",
    "heightCm": 168,
    "weightKg": 72.4,
    "bmi": 25.6,
    "skinTone": "IV",
    "ancestry": "..."
  },
  "manifestRef": "...",
  "vcfBlobRef": "...",
  "createdAt": "...",
  "updatedAt": "..."
}
```

`skinTone` is Fitzpatrick `I` to `VI`. The DID format is `did:dtp:{uuid}`, not `did:onto:`.

## Events

An event is one timestamped entry carrying **a code, a value, and the body system it affects**. Body systems are things like `cardiovascular`, `nervous`, `skeletal`. Events can be streamed in real time, and you can write a finding back onto the twin as a flag.

## HOLON

One REST interface over 19 open vocabularies: SNOMED CT, LOINC, RxNorm, FMA, GO, HPO, HGNC, ClinVar, DrugBank and more. 5.3M concepts, 1.7M drug interactions.

| Capability | Call | What we use it for |
| --- | --- | --- |
| Concept search | `GET /concepts?q=aspirin` | Medication and condition lookup |
| Resolve a code | `concepts.getByCode('38341003', 'SNOMED')` | Turning event codes into names |
| Hierarchy | `concepts.getAncestors(id)` | Grouping conditions |
| Drug interactions | `interactions.checkList([1191, 11289, 42463])` | **Medication assistant interactions and warnings** |
| Cross-vocabulary mapping | `mappings.translate('38341003', 'SNOMED', 'ICD10')` | The clinical code pills on the timeline |
| Reference ranges | `referenceRanges.getByLoincCode('2093-3', 45, 'male')` | **Biomarker reference ranges, stratified by age and sex** |
| Phenotype similarity | HPO | Symptom analysis |

The two rows in bold are features MedGuardian currently fakes with hard-coded values. They should come from HOLON. That is both more correct and directly scores on the "use of the platform" judging criterion.

## Hackathon facts

- **Submission deadline: Friday 24 July 2026, 11:00pm WAT.** No extensions.
- Presentations Saturday 25 July, 2:00pm WAT, **15 minutes per team**.
- Submit: a working project, a demo video of three minutes or less, and a short description of what it does, who it is for, and which parts of the platform it uses.
- Judged on four equally weighted criteria: **Innovation, Clinical value, Execution, Use of the platform.**
- Teams of up to three. One API key and one submission per team.
- All code must be written during the hackathon week.
