import '../../core/constants/app_images.dart';
import '../models/health_guide.dart';

abstract final class DemoGuides {
  static const List<HealthGuide> all = <HealthGuide>[
    HealthGuide(
      id: 'guide_bp',
      title: 'Taking a blood pressure reading that actually means something',
      summary:
          'Most home readings are wrong for avoidable reasons. Five minutes '
          'of preparation changes the number.',
      imageUrl: AppImages.bloodPressureMonitor,
      readMinutes: 3,
      relatedBiomarker: 'blood_pressure_systolic',
      sections: <GuideSection>[
        GuideSection(
          heading: 'Why the number moves so much',
          body:
              'Blood pressure is not one value, it is a range that shifts '
              'through the day. A reading taken straight after coffee, a '
              'climb up stairs or a stressful call can sit 20 mmHg above '
              'your true resting pressure. That is why a single high reading '
              'is not a diagnosis, and why a steady climb across weeks is '
              'far more meaningful than any one number.',
        ),
        GuideSection(
          heading: 'Before you measure',
          body: 'Give yourself five quiet minutes first.',
          points: <String>[
            'Sit still for five minutes with your back supported',
            'Keep both feet flat on the floor, legs uncrossed',
            'Rest your arm on a table so the cuff is level with your heart',
            'No caffeine, food, exercise or cigarettes for 30 minutes',
            'Empty your bladder first, a full one can add several points',
          ],
        ),
        GuideSection(
          heading: 'While you measure',
          body:
              'Put the cuff on bare skin, not over a sleeve. Do not talk '
              'during the reading, conversation alone can raise the result. '
              'Take two readings a minute apart and record the second one, '
              'which is usually the more reliable of the two.',
        ),
        GuideSection(
          heading: 'Build a trend, not a snapshot',
          body:
              'Measure at the same time each day, ideally morning and '
              'evening. Log every reading, including the good ones. '
              'MedGuardian needs the full series to tell the difference '
              'between normal variation and a genuine climb.',
        ),
      ],
    ),
    HealthGuide(
      id: 'guide_glucose',
      title: 'Prediabetes is a warning, not a sentence',
      summary:
          'Roughly half of people who act on a prediabetes result never go '
          'on to develop type 2 diabetes.',
      imageUrl: AppImages.glucoseCheck,
      readMinutes: 4,
      relatedBiomarker: 'blood_glucose',
      sections: <GuideSection>[
        GuideSection(
          heading: 'What the numbers mean',
          body:
              'Fasting glucose under 100 mg/dL is normal, 100 to 125 is '
              'prediabetes, and 126 or above on two occasions is diabetes. '
              'HbA1c tells a longer story, averaging your glucose across '
              'roughly three months: under 5.7 percent is normal, 5.7 to 6.4 '
              'is prediabetes.',
        ),
        GuideSection(
          heading: 'Why it is worth acting on now',
          body:
              'Prediabetes usually has no symptoms at all, which is exactly '
              'what makes it dangerous. The damage to blood vessels begins '
              'before the diabetes diagnosis arrives. It is also the stage '
              'where change is most effective, and where reversal is '
              'genuinely realistic.',
        ),
        GuideSection(
          heading: 'What moves the number',
          body: 'The evidence is unusually consistent here.',
          points: <String>[
            'Losing 5 to 7 percent of body weight cuts risk substantially',
            'A 30 minute walk five days a week improves insulin sensitivity',
            'Cutting sugary drinks alone shifts fasting glucose for many people',
            'Sleeping under six hours a night worsens glucose control',
          ],
        ),
        GuideSection(
          heading: 'What to ask your doctor',
          body:
              'Ask whether an oral glucose tolerance test is appropriate, '
              'how often you should retest HbA1c, and whether anything you '
              'currently take affects blood sugar.',
        ),
      ],
    ),
    HealthGuide(
      id: 'guide_movement',
      title: 'The thirty minute walk is not a cliche',
      summary:
          'Of everything a healthy adult can do without a prescription, '
          'regular walking has the strongest evidence behind it.',
      imageUrl: AppImages.walking,
      readMinutes: 3,
      relatedBiomarker: 'bmi',
      sections: <GuideSection>[
        GuideSection(
          heading: 'What it changes',
          body:
              'Regular moderate walking lowers resting blood pressure, '
              'improves how your body handles glucose, raises HDL '
              'cholesterol and improves sleep quality. Those four effects '
              'account for most of what drives a health risk score.',
        ),
        GuideSection(
          heading: 'How much is enough',
          body:
              'The common target is 150 minutes of moderate activity a '
              'week, which is 30 minutes on five days. Moderate means you '
              'can talk but not comfortably sing. Three ten minute walks '
              'count the same as one thirty minute walk.',
        ),
        GuideSection(
          heading: 'Making it stick',
          body: 'Consistency beats intensity every time.',
          points: <String>[
            'Attach it to something you already do daily',
            'Walk the first ten minutes even on days you do not want to',
            'Log it, watching a streak build is a real motivator',
          ],
        ),
      ],
    ),
    HealthGuide(
      id: 'guide_sleep',
      title: 'Sleep is a cardiovascular measurement',
      summary:
          'Short sleep raises blood pressure and worsens glucose control, '
          'often before anything else shows up.',
      imageUrl: AppImages.sleep,
      readMinutes: 3,
      relatedBiomarker: 'resting_heart_rate',
      sections: <GuideSection>[
        GuideSection(
          heading: 'The link people miss',
          body:
              'Blood pressure normally dips by 10 to 20 percent overnight. '
              'When sleep is short or broken that dip does not happen, and '
              'the cardiovascular system spends more of the day under load. '
              'Persistently short sleep also raises appetite hormones and '
              'worsens insulin sensitivity.',
        ),
        GuideSection(
          heading: 'What helps',
          body: 'Timing matters more than total hours for most people.',
          points: <String>[
            'Wake at the same time daily, including weekends',
            'Get daylight within an hour of waking',
            'No caffeine after early afternoon, it lingers eight hours',
            'Keep the room cool and properly dark',
          ],
        ),
        GuideSection(
          heading: 'When to raise it with a doctor',
          body:
              'Loud snoring with pauses in breathing, waking unrefreshed '
              'after a full night, or heavy daytime sleepiness can point to '
              'sleep apnoea, which is both common and treatable, and which '
              'drives blood pressure hard if left alone.',
        ),
      ],
    ),
    HealthGuide(
      id: 'guide_salt',
      title: 'Where the salt actually comes from',
      summary:
          'Most dietary salt is already in the food before it reaches your '
          'table. The salt shaker is a small part of it.',
      imageUrl: AppImages.balancedMeal,
      readMinutes: 3,
      relatedBiomarker: 'blood_pressure_systolic',
      sections: <GuideSection>[
        GuideSection(
          heading: 'The target',
          body:
              'Under 5g of salt a day, roughly one level teaspoon, which is '
              'about 2g of sodium. Most adults eat considerably more than '
              'this without ever adding salt while cooking.',
        ),
        GuideSection(
          heading: 'The usual sources',
          body: 'These are where the majority of it hides.',
          points: <String>[
            'Bread and baked goods, small amounts eaten often',
            'Stock cubes, seasoning blends and instant noodles',
            'Processed and cured meat',
            'Tinned soups, sauces and anything labelled savoury',
          ],
        ),
        GuideSection(
          heading: 'Practical swaps',
          body:
              'Cook with acid and aromatics instead of salt: citrus, '
              'vinegar, garlic, ginger, pepper and herbs all make food taste '
              'more seasoned than it is. Taste palates adjust within a few '
              'weeks, food that seems bland at first stops seeming bland.',
        ),
      ],
    ),
  ];

  const DemoGuides._();
}
