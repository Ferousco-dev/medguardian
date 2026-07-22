import '../models/biomarker.dart';
import '../models/clinical_summary.dart';
import '../models/digital_twin.dart';
import '../models/health_event.dart';
import '../models/health_insight.dart';
import '../models/health_simulation.dart';
import '../models/hospital.dart';
import '../models/medication.dart';
import '../models/risk_score.dart';
import '../models/symptom_analysis.dart';
import '../models/user_account.dart';
import '../../core/constants/app_images.dart';

abstract final class DemoData {
  static DateTime get _now => DateTime.now();

  static DateTime _daysAgo(int days) => _now.subtract(Duration(days: days));

  static const UserAccount account = UserAccount(
    id: 'user_demo',
    fullName: 'Ada Okoro',
    email: 'ada.okoro@example.com',
    twinId: 'twin_demo',
  );

  static DigitalTwin get twin => DigitalTwin(
    id: 'twin_demo',
    did: 'did:onto:8f2a4c19',
    fullName: 'Ada Okoro',
    dateOfBirth: DateTime(1994, 3, 17),
    sex: BiologicalSex.female,
    heightCm: 168,
    weightKg: 72.4,
    bloodType: 'O+',
    conditions: const <String>['Prediabetes', 'Elevated blood pressure'],
    allergies: const <String>['Penicillin', 'Peanuts'],
    familyHistory: const <String>[
      'Type 2 diabetes (mother)',
      'Hypertension (father)',
    ],
    createdAt: _daysAgo(214),
    updatedAt: _daysAgo(1),
  );

  static List<HealthEvent> get events => <HealthEvent>[
    HealthEvent(
      id: 'evt_1',
      type: HealthEventType.measurement,
      title: 'Blood pressure 138/89',
      description: 'Home reading, taken after breakfast.',
      occurredAt: _daysAgo(1),
      severity: EventSeverity.mild,
      clinicalCode: 'LOINC 85354-9',
    ),
    HealthEvent(
      id: 'evt_2',
      type: HealthEventType.symptom,
      title: 'Headache',
      description: 'Dull, behind the eyes, third time this month.',
      occurredAt: _daysAgo(4),
      severity: EventSeverity.mild,
    ),
    HealthEvent(
      id: 'evt_3',
      type: HealthEventType.labResult,
      title: 'HbA1c 5.9 percent',
      description: 'Routine panel at Lagoon Diagnostics.',
      occurredAt: _daysAgo(12),
      severity: EventSeverity.moderate,
      clinicalCode: 'LOINC 4548-4',
    ),
    HealthEvent(
      id: 'evt_4',
      type: HealthEventType.medication,
      title: 'Started Lisinopril 5mg',
      description: 'Once daily, prescribed by Dr Bello.',
      occurredAt: _daysAgo(30),
    ),
    HealthEvent(
      id: 'evt_5',
      type: HealthEventType.visit,
      title: 'General practice review',
      description: 'Discussed blood pressure trend and diet.',
      occurredAt: _daysAgo(31),
    ),
    HealthEvent(
      id: 'evt_6',
      type: HealthEventType.diagnosis,
      title: 'Prediabetes',
      description: 'Based on fasting glucose and HbA1c.',
      occurredAt: _daysAgo(96),
      severity: EventSeverity.moderate,
      clinicalCode: 'ICD-10 R73.03',
    ),
    HealthEvent(
      id: 'evt_7',
      type: HealthEventType.vaccination,
      title: 'Tetanus booster',
      occurredAt: _daysAgo(140),
    ),
    HealthEvent(
      id: 'evt_8',
      type: HealthEventType.note,
      title: 'Counselling session',
      description: 'Private entry.',
      occurredAt: _daysAgo(160),
      isHidden: true,
    ),
  ];

  static List<Biomarker> get biomarkers => <Biomarker>[
    Biomarker(
      code: 'blood_pressure_systolic',
      name: 'Systolic blood pressure',
      unit: 'mmHg',
      referenceHigh: 130,
      referenceLow: 90,
      trend: BiomarkerTrend.worsening,
      readings: _series(<double>[
        118,
        121,
        124,
        129,
        133,
        138,
      ], spacingDays: 30),
    ),
    Biomarker(
      code: 'blood_glucose',
      name: 'Fasting glucose',
      unit: 'mg/dL',
      referenceHigh: 99,
      referenceLow: 70,
      trend: BiomarkerTrend.worsening,
      readings: _series(<double>[92, 95, 98, 101, 104, 108], spacingDays: 30),
    ),
    Biomarker(
      code: 'hba1c',
      name: 'HbA1c',
      unit: '%',
      referenceHigh: 5.7,
      referenceLow: 4,
      trend: BiomarkerTrend.worsening,
      readings: _series(<double>[5.3, 5.5, 5.7, 5.9], spacingDays: 60),
    ),
    Biomarker(
      code: 'bmi',
      name: 'Body mass index',
      unit: 'kg/m2',
      referenceHigh: 24.9,
      referenceLow: 18.5,
      trend: BiomarkerTrend.worsening,
      readings: _series(<double>[
        23.6,
        24.1,
        24.6,
        25.0,
        25.4,
        25.6,
      ], spacingDays: 30),
    ),
    Biomarker(
      code: 'resting_heart_rate',
      name: 'Resting heart rate',
      unit: 'bpm',
      referenceHigh: 100,
      referenceLow: 55,
      trend: BiomarkerTrend.stable,
      readings: _series(<double>[72, 70, 71, 69, 70, 71], spacingDays: 30),
    ),
    Biomarker(
      code: 'total_cholesterol',
      name: 'Total cholesterol',
      unit: 'mg/dL',
      referenceHigh: 200,
      referenceLow: 120,
      trend: BiomarkerTrend.improving,
      readings: _series(<double>[212, 205, 198, 191], spacingDays: 60),
    ),
  ];

  static RiskScore get riskScore => RiskScore(
    score: 68,
    band: RiskBand.moderate,
    previousScore: 76,
    calculatedAt: _daysAgo(1),
    factors: const <RiskFactor>[
      RiskFactor(
        label: 'Blood pressure rising',
        impact: 12,
        direction: RiskDirection.raises,
        detail: 'Up 20 mmHg systolic over six months.',
      ),
      RiskFactor(
        label: 'Fasting glucose above range',
        impact: 9,
        direction: RiskDirection.raises,
        detail: 'Four consecutive readings above 99 mg/dL.',
      ),
      RiskFactor(
        label: 'Family history of diabetes',
        impact: 6,
        direction: RiskDirection.raises,
      ),
      RiskFactor(
        label: 'Cholesterol improving',
        impact: 4,
        direction: RiskDirection.lowers,
        detail: 'Down 21 mg/dL since January.',
      ),
      RiskFactor(
        label: 'Resting heart rate stable',
        impact: 3,
        direction: RiskDirection.lowers,
      ),
    ],
  );

  static List<HealthInsight> get insights => <HealthInsight>[
    HealthInsight(
      id: 'ins_1',
      title: 'Your blood pressure has climbed every month since February',
      body:
          'Six consecutive readings have moved upward, from 118 to 138 mmHg '
          'systolic. A single high reading is normal. A steady climb is not.',
      severity: InsightSeverity.watch,
      recommendation:
          'Book a blood pressure review this week and keep taking readings at '
          'the same time each day.',
      relatedBiomarker: 'blood_pressure_systolic',
      generatedAt: _daysAgo(1),
    ),
    HealthInsight(
      id: 'ins_2',
      title: 'Fasting glucose has crossed the prediabetes threshold',
      body:
          'Your last four fasting readings sat above 99 mg/dL, and HbA1c moved '
          'from 5.3 to 5.9 percent over eight months.',
      severity: InsightSeverity.urgent,
      recommendation:
          'Discuss a formal glucose tolerance test with your doctor.',
      relatedBiomarker: 'blood_glucose',
      generatedAt: _daysAgo(2),
    ),
    HealthInsight(
      id: 'ins_3',
      title: 'Cholesterol is responding well',
      body:
          'Total cholesterol has fallen 21 mg/dL across the last four panels '
          'and is now inside the reference range.',
      severity: InsightSeverity.positive,
      relatedBiomarker: 'total_cholesterol',
      generatedAt: _daysAgo(3),
    ),
    HealthInsight(
      id: 'ins_4',
      title: 'You have not logged a weight reading in five weeks',
      body:
          'BMI is one of the strongest contributors to your current risk score '
          'and the projection gets less reliable without recent readings.',
      severity: InsightSeverity.informational,
      recommendation: 'Log a weight reading to refresh the projection.',
      relatedBiomarker: 'bmi',
      generatedAt: _daysAgo(4),
    ),
  ];

  static HealthSimulation get simulation => HealthSimulation(
    id: 'sim_1',
    question: 'What happens if I continue ignoring my blood pressure?',
    scenario: SimulationScenario.unchanged,
    generatedAt: _daysAgo(1),
    preventiveActions: const <String>[
      'Reduce added salt to under 5g per day',
      'Walk 30 minutes, five days a week',
      'Take blood pressure readings twice weekly',
      'Review medication with your doctor in 4 weeks',
    ],
    horizons: const <SimulationHorizon>[
      SimulationHorizon(
        label: 'Today',
        outcome: 'Stage 1 hypertension with prediabetic glucose.',
        riskLevel: 0.32,
        projectedValue: '138/89 mmHg',
      ),
      SimulationHorizon(
        label: '3 months',
        outcome: 'Blood pressure likely enters stage 2 range.',
        riskLevel: 0.48,
        projectedValue: '145/93 mmHg',
      ),
      SimulationHorizon(
        label: '1 year',
        outcome:
            'Materially higher cardiovascular risk and a likely progression '
            'to type 2 diabetes.',
        riskLevel: 0.71,
        projectedValue: '152/96 mmHg',
      ),
      SimulationHorizon(
        label: '5 years',
        outcome:
            'Elevated chance of hypertensive complications affecting the '
            'kidneys, eyes and heart.',
        riskLevel: 0.86,
        projectedValue: '158/99 mmHg',
      ),
    ],
  );

  static List<Medication> get medications => <Medication>[
    Medication(
      id: 'med_1',
      name: 'Lisinopril',
      genericName: 'Lisinopril',
      dosage: '5 mg',
      frequency: 'Once daily',
      startedOn: _daysAgo(30),
      uses: const <String>[
        'Lowers high blood pressure',
        'Protects kidney function in diabetes',
      ],
      sideEffects: const <String>[
        'Dry cough',
        'Dizziness when standing up quickly',
        'Raised potassium',
      ],
      interactions: const <String>[
        'Ibuprofen and other NSAIDs reduce its effect',
        'Potassium supplements',
      ],
      warnings: const <String>[
        'Not safe in pregnancy',
        'Tell your doctor about any swelling of the face or throat',
      ],
    ),
    Medication(
      id: 'med_2',
      name: 'Metformin',
      genericName: 'Metformin hydrochloride',
      dosage: '500 mg',
      frequency: 'Twice daily with food',
      startedOn: _daysAgo(96),
      uses: const <String>[
        'Lowers blood glucose in type 2 diabetes and prediabetes',
      ],
      sideEffects: const <String>[
        'Nausea',
        'Diarrhoea, usually in the first weeks',
        'Metallic taste',
      ],
      interactions: const <String>['Alcohol', 'Contrast dye used in CT scans'],
      warnings: const <String>[
        'Stop before any scan using contrast dye',
        'Seek help for unusual muscle pain with fast breathing',
      ],
    ),
    Medication(
      id: 'med_3',
      name: 'Amoxicillin',
      genericName: 'Amoxicillin',
      dosage: '500 mg',
      frequency: 'Three times daily',
      startedOn: _daysAgo(150),
      endedOn: _daysAgo(143),
      uses: const <String>['Bacterial chest infection'],
      warnings: const <String>[
        'You have a recorded penicillin allergy. This course was reviewed by '
            'your doctor before it was prescribed.',
      ],
    ),
  ];

  static List<Hospital> get hospitals => <Hospital>[
    Hospital(
      id: 'hos_1',
      name: 'Lagoon General Hospital',
      address: '14 Marina Road, Lagos Island',
      distanceKm: 1.8,
      travelMinutes: 7,
      hasEmergency: true,
      phone: '+234 800 000 0001',
      imageUrl: AppImages.hospitals[0],
      specialties: const <String>[
        'Emergency',
        'Cardiology',
        'Internal medicine',
      ],
    ),
    Hospital(
      id: 'hos_2',
      name: 'St Clare Medical Centre',
      address: '3 Adeola Odeku Street, Victoria Island',
      distanceKm: 3.4,
      travelMinutes: 12,
      hasEmergency: true,
      phone: '+234 800 000 0002',
      imageUrl: AppImages.hospitals[1],
      specialties: const <String>['Emergency', 'Endocrinology', 'Radiology'],
    ),
    Hospital(
      id: 'hos_3',
      name: 'Harbour Family Clinic',
      address: '8 Ozumba Mbadiwe Avenue',
      distanceKm: 4.1,
      travelMinutes: 15,
      phone: '+234 800 000 0003',
      imageUrl: AppImages.hospitals[2],
      specialties: const <String>['General practice', 'Paediatrics'],
    ),
    Hospital(
      id: 'hos_4',
      name: 'Riverside Cardiology Institute',
      address: '22 Kingsway Road, Ikoyi',
      distanceKm: 6.7,
      travelMinutes: 21,
      isOpenNow: false,
      phone: '+234 800 000 0004',
      imageUrl: AppImages.hospitals[3],
      specialties: const <String>['Cardiology', 'Cardiac surgery'],
    ),
  ];

  static ClinicalSummary get clinicalSummary => ClinicalSummary(
    id: 'sum_1',
    generatedAt: _now,
    patientName: 'Ada Okoro',
    patientAge: 31,
    overview:
        'Thirty-one year old female with prediabetes and newly elevated blood '
        'pressure. Systolic pressure has risen steadily over six months '
        'despite starting Lisinopril four weeks ago. Fasting glucose and '
        'HbA1c are both trending upward.',
    activeProblems: const <String>[
      'Stage 1 hypertension',
      'Prediabetes',
      'Rising BMI',
    ],
    recentEvents: events.take(5).toList(growable: false),
    medications: medications
        .where((Medication m) => m.isActive)
        .toList(growable: false),
    biomarkers: biomarkers,
    recommendations: const <String>[
      'Confirm blood pressure with an ambulatory monitor',
      'Order oral glucose tolerance test',
      'Review Lisinopril dose at four weeks',
      'Refer to dietetics for weight and glucose management',
    ],
  );

  static SymptomAnalysis analysisFor(String description) {
    final String text = description.toLowerCase();

    if (text.contains('chest') ||
        text.contains('breath') ||
        text.contains('numb')) {
      return SymptomAnalysis(
        id: 'analysis_emergency',
        urgency: UrgencyLevel.emergency,
        analysedAt: _now,
        summary:
            'Chest discomfort combined with breathing difficulty can indicate '
            'a cardiac event. This needs assessment now, not later.',
        extractedSymptoms: const <String>['Chest pain', 'Shortness of breath'],
        possibleConditions: const <PossibleCondition>[
          PossibleCondition(
            name: 'Acute coronary syndrome',
            likelihood: 0.34,
            description:
                'Reduced blood flow to the heart muscle. Requires immediate '
                'assessment.',
            clinicalCode: 'ICD-10 I24.9',
          ),
          PossibleCondition(
            name: 'Angina',
            likelihood: 0.28,
            clinicalCode: 'ICD-10 I20.9',
          ),
          PossibleCondition(name: 'Anxiety attack', likelihood: 0.18),
        ],
        nextSteps: const <String>[
          'Call emergency services now',
          'Do not drive yourself',
          'Sit down and stay still until help arrives',
          'Show responders your emergency card',
        ],
      );
    }

    if (text.contains('head')) {
      return SymptomAnalysis(
        id: 'analysis_headache',
        urgency: UrgencyLevel.routine,
        analysedAt: _now,
        summary:
            'This is your third headache logged this month, and it lands '
            'alongside a six month rise in blood pressure. The two are worth '
            'reviewing together.',
        extractedSymptoms: const <String>['Headache', 'Recurring pattern'],
        possibleConditions: const <PossibleCondition>[
          PossibleCondition(
            name: 'Hypertension related headache',
            likelihood: 0.41,
            description: 'Consistent with your rising systolic readings.',
            clinicalCode: 'ICD-10 G44.1',
          ),
          PossibleCondition(
            name: 'Tension headache',
            likelihood: 0.33,
            clinicalCode: 'ICD-10 G44.2',
          ),
          PossibleCondition(name: 'Migraine', likelihood: 0.14),
        ],
        followUpQuestions: const <String>[
          'Does the pain get worse when you bend forward?',
          'Have you noticed any change in vision?',
          'How many hours did you sleep last night?',
        ],
        nextSteps: const <String>[
          'Book a blood pressure review this week',
          'Log a reading each morning until the appointment',
          'Note what you were doing when each headache started',
        ],
      );
    }

    return SymptomAnalysis(
      id: 'analysis_general',
      urgency: UrgencyLevel.selfCare,
      analysedAt: _now,
      summary:
          'Nothing here matches an urgent pattern. It has been recorded on '
          'your timeline so a pattern can be spotted if it repeats.',
      extractedSymptoms: <String>[description.trim()],
      possibleConditions: const <PossibleCondition>[
        PossibleCondition(
          name: 'Self limiting condition',
          likelihood: 0.62,
          description: 'Most symptoms of this kind settle without treatment.',
        ),
      ],
      followUpQuestions: const <String>[
        'How many days has this lasted?',
        'Is it getting better, worse or staying the same?',
      ],
      nextSteps: const <String>[
        'Rest and stay hydrated',
        'Log it again if it lasts more than three days',
      ],
    );
  }

  static List<BiomarkerReading> _series(
    List<double> values, {
    required int spacingDays,
  }) {
    final int last = values.length - 1;
    return <BiomarkerReading>[
      for (int i = 0; i < values.length; i++)
        BiomarkerReading(
          value: values[i],
          recordedAt: _daysAgo((last - i) * spacingDays),
          source: 'demo',
        ),
    ];
  }

  const DemoData._();
}
