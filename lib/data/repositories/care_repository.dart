import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../demo/demo_data.dart';
import '../models/clinical_summary.dart';
import '../models/hospital.dart';
import '../models/medication.dart';

abstract interface class CareRepository {
  Future<List<Medication>> fetchMedications();

  Future<Medication> lookUpMedication(String name);

  Future<List<Hospital>> fetchNearbyHospitals();

  Future<ClinicalSummary> generateClinicalSummary();

  Future<AccessGrant> grantAccess(Duration duration);

  Future<Map<String, dynamic>> exportFhir();
}

class RemoteCareRepository implements CareRepository {
  const RemoteCareRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Medication>> fetchMedications() async {
    final List<dynamic> json = await _client.get<List<dynamic>>(
      ApiEndpoints.medications,
    );
    return json
        .map((dynamic e) => Medication.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Medication> lookUpMedication(String name) async {
    final Map<String, dynamic> json = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.medicationLookup,
      query: <String, dynamic>{'name': name},
    );
    return Medication.fromJson(json);
  }

  @override
  Future<List<Hospital>> fetchNearbyHospitals() async {
    final List<dynamic> json = await _client.get<List<dynamic>>(
      ApiEndpoints.hospitals,
    );
    return json
        .map((dynamic e) => Hospital.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ClinicalSummary> generateClinicalSummary() async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.clinicalSummary,
    );
    return ClinicalSummary.fromJson(json);
  }

  @override
  Future<AccessGrant> grantAccess(Duration duration) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.temporaryAccess,
      body: <String, dynamic>{'duration_minutes': duration.inMinutes},
    );
    return AccessGrant.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> exportFhir() {
    return _client.get<Map<String, dynamic>>(ApiEndpoints.fhirExport);
  }
}

class MockCareRepository implements CareRepository {
  const MockCareRepository();

  static const Duration _latency = Duration(milliseconds: 550);

  @override
  Future<List<Medication>> fetchMedications() async {
    await Future<void>.delayed(_latency);
    return DemoData.medications;
  }

  @override
  Future<Medication> lookUpMedication(String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final String query = name.trim().toLowerCase();
    return DemoData.medications.firstWhere(
      (Medication m) => m.name.toLowerCase().contains(query),
      orElse: () => DemoData.medications.first,
    );
  }

  @override
  Future<List<Hospital>> fetchNearbyHospitals() async {
    await Future<void>.delayed(_latency);
    return DemoData.hospitals;
  }

  @override
  Future<ClinicalSummary> generateClinicalSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return DemoData.clinicalSummary;
  }

  @override
  Future<AccessGrant> grantAccess(Duration duration) async {
    await Future<void>.delayed(_latency);
    return AccessGrant(
      id: 'grant_demo',
      code: 'MG-4K9T-2XPQ',
      expiresAt: DateTime.now().add(duration),
    );
  }

  @override
  Future<Map<String, dynamic>> exportFhir() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return <String, dynamic>{
      'resourceType': 'Bundle',
      'type': 'collection',
      'entry': <Map<String, dynamic>>[
        <String, dynamic>{
          'resource': <String, dynamic>{
            'resourceType': 'Patient',
            'id': DemoData.twin.id,
            'name': <Map<String, dynamic>>[
              <String, dynamic>{'text': DemoData.twin.fullName},
            ],
            'gender': DemoData.twin.sex.apiValue,
            'birthDate': DemoData.twin.dateOfBirth
                .toIso8601String()
                .split('T')
                .first,
          },
        },
      ],
    };
  }
}
