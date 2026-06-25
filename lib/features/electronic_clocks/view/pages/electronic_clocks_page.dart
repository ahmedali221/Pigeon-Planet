import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../model/electronic_clock_model.dart';
import '../widgets/clock_card.dart';
import 'clock_detail_page.dart';

class ElectronicClocksPage extends StatelessWidget {
  const ElectronicClocksPage({super.key});

  static const _clocks = <ElectronicClockModel>[
    ElectronicClockModel(
      id: '1',
      name: 'Benzing G2 لتسجيل الحمام',
      brand: 'Benzing',
      description:
          'ساعة إلكترونية احترافية لتسجيل أوقات وصول الحمام في سباقات الهواة، دقة عالية بمستوى الميلي ثانية، تدعم تسجيل ما يصل إلى 500 طائر في جلسة واحدة.',
      price: 4500,
      imageUrl: null,
      rating: 4.8,
      reviewCount: 124,
      inStock: true,
      features: [
        'دقة ميلي ثانية',
        'تسجيل حتى 500 طائر',
        'متوافق مع PIPA و NFU',
        'بطارية مدمجة قابلة للشحن',
        'شاشة LCD واضحة',
        'واجهة عربية',
      ],
      agent: ClockAgentModel(
        id: 'ag1',
        name: 'أحمد محمود السيد',
        governorate: 'القاهرة',
        photoUrl: null,
        phoneNumber: '01012345678',
      ),
    ),
    ElectronicClockModel(
      id: '2',
      name: 'Benzing NFC Ultra',
      brand: 'Benzing',
      description:
          'أحدث إصدار من ساعات Benzing بتقنية NFC للقراءة السريعة للخواتم، مثالية للسباقات الكبرى والبطولات الدولية.',
      price: 6200,
      imageUrl: null,
      rating: 4.9,
      reviewCount: 89,
      inStock: true,
      features: [
        'قراءة NFC فائقة السرعة',
        'تخزين داخلي 8 جيجابايت',
        'اتصال Wi-Fi مباشر',
        'تحديثات تلقائية',
        'ضمان سنتين',
      ],
      agent: ClockAgentModel(
        id: 'ag2',
        name: 'محمد عبدالعزيز حسن',
        governorate: 'الجيزة',
        photoUrl: null,
        phoneNumber: '01123456789',
      ),
    ),
    ElectronicClockModel(
      id: '3',
      name: 'Gaba Tauben GT-1000',
      brand: 'Gaba',
      description:
          'ساعة ألمانية الصنع مصممة خصيصاً لهواة تربية الحمام، واجهة بسيطة وسهلة الاستخدام مع دقة استثنائية في التسجيل.',
      price: 3800,
      imageUrl: null,
      rating: 4.6,
      reviewCount: 67,
      inStock: true,
      features: [
        'واجهة مبسطة',
        'دقة عالية في التسجيل',
        'مقاومة للماء IP54',
        'بطارية تدوم 48 ساعة',
        'صيانة مجانية السنة الأولى',
      ],
      agent: ClockAgentModel(
        id: 'ag3',
        name: 'كريم سامي الفقي',
        governorate: 'الإسكندرية',
        photoUrl: null,
        phoneNumber: '01234567890',
      ),
    ),
    ElectronicClockModel(
      id: '4',
      name: 'UNIKON ETS System',
      brand: 'UNIKON',
      description:
          'نظام إلكتروني متكامل لتسجيل سباقات الحمام، يشمل الساعة وجهاز القراءة والبرنامج التحليلي لمتابعة النتائج.',
      price: 7500,
      imageUrl: null,
      rating: 4.7,
      reviewCount: 43,
      inStock: false,
      features: [
        'نظام متكامل شامل',
        'برنامج تحليلي مجاني',
        'تقارير مفصلة للنتائج',
        'دعم فني على مدار الساعة',
        'تحديثات مجانية مدى الحياة',
      ],
      agent: ClockAgentModel(
        id: 'ag4',
        name: 'طارق إبراهيم النجار',
        governorate: 'المنوفية',
        photoUrl: null,
        phoneNumber: '01098765432',
      ),
    ),
    ElectronicClockModel(
      id: '5',
      name: 'Belgian Timing BT-500',
      brand: 'Belgian',
      description:
          'ساعة بلجيكية الأصل تستخدمها أفضل النوادي الأوروبية، معتمدة رسمياً من الاتحادات الدولية لسباقات الحمام.',
      price: 5100,
      imageUrl: null,
      rating: 4.7,
      reviewCount: 56,
      inStock: true,
      features: [
        'معتمدة دولياً',
        'دقة نانو ثانية',
        'اتصال لاسلكي مشفر',
        'تخزين سحابي',
        'شاشة ملونة تاتش',
      ],
      agent: ClockAgentModel(
        id: 'ag5',
        name: 'عمرو جلال البنا',
        governorate: 'الشرقية',
        photoUrl: null,
        phoneNumber: '01187654321',
      ),
    ),
    ElectronicClockModel(
      id: '6',
      name: 'Super Sport SS-200 Pro',
      brand: 'Super Sport',
      description:
          'ساعة اقتصادية عالية الجودة مناسبة للمبتدئين والأندية الصغيرة، سهولة في الاستخدام مع كفاءة تسجيل ممتازة.',
      price: 2200,
      imageUrl: null,
      rating: 4.4,
      reviewCount: 198,
      inStock: true,
      features: [
        'سهولة الاستخدام',
        'سعر مناسب للجميع',
        'خدمة ما بعد البيع',
        'ضمان سنة كاملة',
        'تدريب مجاني للمستخدمين الجدد',
      ],
      agent: ClockAgentModel(
        id: 'ag6',
        name: 'سامي محمود الديب',
        governorate: 'البحيرة',
        photoUrl: null,
        phoneNumber: '01276543210',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _ClocksHeader(),
          _SearchBar(),
          _StatsRow(count: _clocks.length),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.73,
              ),
              itemCount: _clocks.length,
              itemBuilder: (context, index) {
                final clock = _clocks[index];
                return ClockCard(
                  clock: clock,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClockDetailPage(clock: clock),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _ClocksHeader extends StatelessWidget {
  const _ClocksHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14,
        right: 20,
        left: 20,
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Text(
            'الساعة الإلكترونية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.timer_rounded, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: AppColors.textHint, size: 20),
            const SizedBox(width: 8),
            const Text(
              'ابحث عن ساعة...',
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int count;
  const _StatsRow({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Text(
            '$count ساعة متاحة',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.inventory_2_outlined,
            size: 15,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
