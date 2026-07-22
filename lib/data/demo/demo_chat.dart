import '../models/chat_message.dart';

abstract final class DemoChat {
  static ChatMessage get greeting => ChatMessage(
    id: 'chat_greeting',
    role: ChatRole.assistant,
    sentAt: DateTime.now(),
    text:
        'I can see your whole record, so you do not need to explain your '
        'history to me. Ask about a reading, a medication, or something you '
        'have noticed.',
    suggestions: <String>[
      'Why is my health score 68?',
      'What does my blood pressure trend mean?',
      'Is my Lisinopril working?',
      'What should I ask my doctor?',
    ],
  );

  static ChatMessage replyTo(String message) {
    final String text = message.toLowerCase();
    final DateTime now = DateTime.now();
    final String id = 'chat_${now.microsecondsSinceEpoch}';

    if (_matches(text, <String>['chest', 'breath', 'numb', 'faint'])) {
      return ChatMessage(
        id: id,
        role: ChatRole.assistant,
        sentAt: now,
        isEmergency: true,
        text:
            'Stop here. Chest discomfort or trouble breathing needs to be '
            'assessed in person, right now, not by me. Call emergency '
            'services and open your emergency card so responders can see '
            'your allergies and medications.',
        groundedOn: <String>['Alert rules', 'Emergency card'],
      );
    }

    if (_matches(text, <String>['score', '68', 'risk'])) {
      return ChatMessage(
        id: id,
        role: ChatRole.assistant,
        sentAt: now,
        text:
            'Your score is 68, down from 76 last month. Three things pull it '
            'down: systolic blood pressure up 20 mmHg over six months, four '
            'fasting glucose readings above range, and family history of '
            'diabetes. Cholesterol falling 21 mg/dL and a stable resting '
            'heart rate are pushing back the other way.\n\nThe blood pressure '
            'trend is the biggest single contributor, and it is also the one '
            'most likely to respond quickly.',
        groundedOn: <String>[
          'Risk score',
          'Blood pressure',
          'Fasting glucose',
          'Family history',
        ],
        suggestions: <String>[
          'How do I bring my blood pressure down?',
          'What happens if I do nothing?',
        ],
      );
    }

    if (_matches(text, <String>['pressure', 'bp', 'systolic', 'hypert'])) {
      return ChatMessage(
        id: id,
        role: ChatRole.assistant,
        sentAt: now,
        text:
            'Your systolic readings have gone 118, 121, 124, 129, 133, 138 '
            'across six months. Every one is higher than the last, which '
            'matters far more than any single value. 138 sits in stage 1 '
            'hypertension.\n\nYou started Lisinopril four weeks ago, so it '
            'is early to judge the effect. What would help is measuring at '
            'the same time each day so the next four weeks are comparable.',
        groundedOn: <String>[
          'Blood pressure trend',
          'Lisinopril, started 30 days ago',
        ],
        suggestions: <String>[
          'How should I take a reading properly?',
          'Should I be worried about 138?',
        ],
      );
    }

    if (_matches(text, <String>[
      'lisinopril',
      'metformin',
      'medication',
      'drug',
    ])) {
      return ChatMessage(
        id: id,
        role: ChatRole.assistant,
        sentAt: now,
        text:
            'You are on Lisinopril 5 mg once daily, started 30 days ago, and '
            'Metformin 500 mg twice daily with food. Four weeks is the usual '
            'point at which a doctor reviews whether a Lisinopril dose is '
            'working, and your last reading was still 138.\n\nOne thing worth '
            'knowing: ibuprofen and similar painkillers blunt how well '
            'Lisinopril works. Your record also has a penicillin allergy '
            'flagged, which is checked against anything new you log.',
        groundedOn: <String>['Medications', 'Allergies', 'Blood pressure'],
        suggestions: <String>['What should I ask my doctor?'],
      );
    }

    if (_matches(text, <String>['glucose', 'sugar', 'diabet', 'hba1c'])) {
      return ChatMessage(
        id: id,
        role: ChatRole.assistant,
        sentAt: now,
        text:
            'Fasting glucose has moved 92, 95, 98, 101, 104, 108 mg/dL, and '
            'HbA1c went from 5.3 to 5.9 percent over eight months. Both sit '
            'in the prediabetes range.\n\nThat is a warning rather than a '
            'diagnosis, and it is the stage where change works best. Roughly '
            'half of people who act at this point never go on to develop type '
            '2 diabetes.',
        groundedOn: <String>[
          'Fasting glucose',
          'HbA1c',
          'Prediabetes diagnosis',
        ],
        suggestions: <String>['What actually lowers my glucose?'],
      );
    }

    if (_matches(text, <String>['doctor', 'appointment', 'ask', 'gp'])) {
      return ChatMessage(
        id: id,
        role: ChatRole.assistant,
        sentAt: now,
        text:
            'Based on what is on your record, these are worth raising:\n\n'
            'Is my Lisinopril dose right, given systolic is still 138 after '
            'four weeks?\n\nShould I have an oral glucose tolerance test, '
            'given HbA1c reached 5.9?\n\nHow often should I retest HbA1c?\n\n'
            'You can generate a clinical summary and give your doctor '
            'time-limited access, so they see the trends rather than your '
            'summary of them.',
        groundedOn: <String>['Medications', 'HbA1c', 'Clinical summary'],
        suggestions: <String>['Generate my clinical summary'],
      );
    }

    if (_matches(text, <String>[
      'down',
      'lower',
      'reduce',
      'improve',
      'help',
    ])) {
      return ChatMessage(
        id: id,
        role: ChatRole.assistant,
        sentAt: now,
        text:
            'For your specific pattern, rising pressure alongside rising '
            'glucose, the same few things move both:\n\nCut added salt below '
            '5g a day. Most of it comes from bread, stock cubes and processed '
            'meat rather than the salt shaker.\n\nWalk 30 minutes on five '
            'days a week. This improves insulin sensitivity and lowers '
            'resting pressure.\n\nKeep taking readings. Your simulation gets '
            'more accurate with more data, and right now BMI has not been '
            'updated in five weeks.',
        groundedOn: <String>['Blood pressure', 'Fasting glucose', 'BMI'],
        suggestions: <String>['What happens if I do nothing?'],
      );
    }

    return ChatMessage(
      id: id,
      role: ChatRole.assistant,
      sentAt: now,
      text:
          'I do not have enough on your record to answer that one well. I can '
          'explain anything MedGuardian is already tracking: your health '
          'score, blood pressure, glucose, HbA1c, BMI, cholesterol or your '
          'medications.\n\nIf this is a new symptom, reporting it properly '
          'records it on your twin and checks it against your history.',
      suggestions: <String>[
        'Why is my health score 68?',
        'Report a symptom instead',
      ],
    );
  }

  static bool _matches(String text, List<String> keywords) {
    return keywords.any((String k) => text.contains(k));
  }

  const DemoChat._();
}
