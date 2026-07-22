/// Every path the mobile client calls.
///
/// This file is the contract with the backend. `docs/BACKEND_SPEC.md` describes
/// the request and response shape for each entry here, so the two must be kept
/// in step.
abstract final class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Twin Core
  static const String twin = '/twin';
  static const String twinProfile = '/twin/profile';

  // Health Events
  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String hideEvent(String id) => '/events/$id/hide';
  static const String emergencyCard = '/events/emergency-card';

  // Symptom analysis
  static const String analyseSymptoms = '/symptoms/analyse';

  // Biomarkers
  static const String biomarkers = '/biomarkers';
  static String biomarkerTrend(String code) => '/biomarkers/$code/trend';

  // Insights, risk and simulation
  static const String insights = '/insights';
  static const String riskScore = '/risk-score';
  static const String simulation = '/simulations';

  // Medications
  static const String medications = '/medications';
  static const String medicationLookup = '/medications/lookup';

  // Providers and sharing
  static const String clinicalSummary = '/clinical-summary';
  static const String fhirExport = '/fhir/export';
  static const String temporaryAccess = '/access-grants';

  // Hospitals
  static const String hospitals = '/hospitals/nearby';

  const ApiEndpoints._();
}
