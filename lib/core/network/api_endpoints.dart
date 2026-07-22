abstract final class ApiEndpoints {
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  static const String twin = '/twin';
  static const String twinProfile = '/twin/profile';

  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String hideEvent(String id) => '/events/$id/hide';
  static const String emergencyCard = '/events/emergency-card';

  static const String analyseSymptoms = '/symptoms/analyse';
  static const String chat = '/chat';

  static const String biomarkers = '/biomarkers';
  static String biomarkerTrend(String code) => '/biomarkers/$code/trend';

  static const String insights = '/insights';
  static const String riskScore = '/risk-score';
  static const String simulation = '/simulations';

  static const String medications = '/medications';
  static const String medicationLookup = '/medications/lookup';

  static const String clinicalSummary = '/clinical-summary';
  static const String fhirExport = '/fhir/export';
  static const String temporaryAccess = '/access-grants';

  static const String hospitals = '/hospitals/nearby';

  const ApiEndpoints._();
}
