import '../../model/pigeon_model.dart';

/// Typed demo data for the Pigeon ID feature.
class PigeonDemoData {
  PigeonDemoData._();

  static final List<PigeonModel> pigeons = [
    PigeonModel(
      id: 101,
      ringNumber: 'BE22-5048321',
      breed: 'بلجيكي - خط Gaby Vandenabeele',
      gender: PigeonGender.male,
      hatchDate: DateTime(2022, 3, 15),
      photoPaths: [],
      raceResults: [
        'سباق 300 كم - المركز الثالث - 2023',
        'سباق 500 كم - المركز الأول  - 2023',
        'بطولة الزاجل الوطنية - ذهبية - 2024',
      ],
      qrData: 'PP:BE22-5048321:101',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 102,
      ringNumber: 'NL23-7712345',
      breed: 'هولندي - خط Van Loon',
      gender: PigeonGender.female,
      hatchDate: DateTime(2023, 1, 20),
      photoPaths: [],
      raceResults: [
        'سباق 250 كم - المركز الثاني - 2023',
        'كأس هولندا للزاجل - فضية - 2023',
        'سباق دولي 600 كم - المركز الخامس - 2024',
        'البطولة الأوروبية - برونزية - 2024',
      ],
      qrData: 'PP:NL23-7712345:102',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 103,
      ringNumber: 'EG-2024-005678',
      breed: 'مصري - خط الأبطال',
      gender: PigeonGender.male,
      hatchDate: DateTime(2024, 2, 10),
      photoPaths: [],
      raceResults: [
        'سباق 200 كم - المركز الأول - 2024',
        'كأس النيل للزاجل - ذهبية - 2024',
      ],
      qrData: 'PP:EG-2024-005678:103',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 104,
      ringNumber: 'EG-2024-001234',
      breed: 'مصري هجين - خط بلجيكي مصري',
      gender: PigeonGender.male,
      hatchDate: DateTime(2024, 4, 5),
      photoPaths: [],
      raceResults: [
        'سباق 150 كم - المركز الثاني - 2024',
      ],
      qrData: 'PP:EG-2024-001234:104',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 105,
      ringNumber: 'NL-2023-887744',
      breed: 'هولندي - خط Van Dyck',
      gender: PigeonGender.female,
      hatchDate: DateTime(2023, 8, 18),
      photoPaths: [],
      raceResults: [
        'سباق 400 كم - المركز الأول - 2023',
        'بطولة هولندا الكبرى - ذهبية - 2023',
        'سباق دولي 700 كم - المركز الثاني - 2024',
      ],
      qrData: 'PP:NL-2023-887744:105',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 106,
      ringNumber: 'BE-2024-112233',
      breed: 'بلجيكي - خط Vandenabeele الأصيل',
      gender: PigeonGender.male,
      hatchDate: DateTime(2024, 1, 30),
      photoPaths: [],
      raceResults: [
        'سباق 350 كم - المركز الأول - 2024',
        'كأس بلجيكا - فضية - 2024',
      ],
      qrData: 'PP:BE-2024-112233:106',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 107,
      ringNumber: 'SA-2024-009900',
      breed: 'سعودي - هجين بلجيكي',
      gender: PigeonGender.female,
      hatchDate: DateTime(2024, 3, 22),
      photoPaths: [],
      raceResults: [
        'سباق الخليج 250 كم - المركز الأول - 2024',
        'بطولة المملكة للزاجل - ذهبية - 2024',
      ],
      qrData: 'PP:SA-2024-009900:107',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 108,
      ringNumber: 'FR-2024-778899',
      breed: 'فرنسي - خط De Rauw-Sablon',
      gender: PigeonGender.male,
      hatchDate: DateTime(2024, 5, 1),
      photoPaths: [],
      raceResults: [
        'البطولة الفرنسية 300 كم - المركز الأول - 2024',
        'سباق أوروبي 500 كم - المركز الثاني - 2024',
        'كأس الاتحاد الأوروبي - برونزية - 2024',
      ],
      qrData: 'PP:FR-2024-778899:108',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 109,
      ringNumber: 'NL23-1925764',
      breed: 'هولندي - خط Koopman',
      gender: PigeonGender.female,
      hatchDate: DateTime(2023, 5, 10),
      photoPaths: [],
      raceResults: [
        'سباق وطني 600 كم - المركز الأول - 2023',
        'سرعة قياسية 110 كم/ساعة - 2023',
        'بطولة هولندا - ذهبية - 2024',
        'السباق الدولي الكبير 800 كم - المركز الثالث - 2024',
      ],
      qrData: 'PP:NL23-1925764:109',
      thumbnailUrl: null,
    ),

    PigeonModel(
      id: 110,
      ringNumber: 'Egy-20-9378',
      breed: 'مصري - سلالة قديمة',
      gender: PigeonGender.male,
      hatchDate: DateTime(2020, 6, 12),
      photoPaths: [],
      raceResults: [
        'سباق الإسكندرية 200 كم - المركز الأول - 2021',
        'كأس مصر للزاجل - فضية - 2022',
        'سباق المتوسط 400 كم - المركز الرابع - 2023',
      ],
      qrData: 'PP:Egy-20-9378:110',
      thumbnailUrl: null,
    ),
  ];

  /// Find a pigeon by ring number
  static PigeonModel? byRingNumber(String ring) =>
      pigeons.where((p) => p.ringNumber == ring).firstOrNull;

  /// Males only
  static List<PigeonModel> get males =>
      pigeons.where((p) => p.gender == PigeonGender.male).toList();

  /// Females only
  static List<PigeonModel> get females =>
      pigeons.where((p) => p.gender == PigeonGender.female).toList();
}
