import 'package:flutter/material.dart';

import '../wheel_prize_model.dart';
import 'lucky_wheel_datasource.dart';

// Placeholder until the backend implements /lucky-wheel/ endpoints.
// Swap this for RealLuckyWheelDataSource once the API is ready.
class MockLuckyWheelDataSource implements LuckyWheelDataSource {
  static final _buyerPrizes = <WheelPrizeModel>[
    const WheelPrizeModel(
      type: 'points_50',
      label: '50 نقطة',
      emoji: '🌑',
      color: Color(0xFF6366F1),
      weight: 20,
      isEnabled: true,
      description: 'احصل على 50 نقطة تُضاف لرصيدك فوراً',
    ),
    const WheelPrizeModel(
      type: 'points_100',
      label: '100 نقطة',
      emoji: '🌕',
      color: Color(0xFF8B5CF6),
      weight: 15,
      isEnabled: true,
      description: 'احصل على 100 نقطة تُضاف لرصيدك فوراً',
    ),
    const WheelPrizeModel(
      type: 'free_shipping',
      label: 'شحن مجاني',
      emoji: '🚛',
      color: Color(0xFF3B82F6),
      weight: 10,
      isEnabled: true,
      description: 'شحن أول طير شراء مجاني',
    ),
    const WheelPrizeModel(
      type: 'sub_discount_10',
      label: 'خصم 10%',
      emoji: '✂️',
      color: Color(0xFFEC4899),
      weight: 15,
      isEnabled: true,
      description: 'خصم 10% على اشتراك اللوفت القادم',
    ),
    const WheelPrizeModel(
      type: 'lucky_next',
      label: 'حظاً أوفر',
      emoji: '🍀',
      color: Color(0xFF22C55E),
      weight: 25,
      isEnabled: true,
      description: 'حظ أوفر في المرة القادمة!',
    ),
    const WheelPrizeModel(
      type: 'golden_auction',
      label: 'مزايدة ذهبية',
      emoji: '✨',
      color: Color(0xFFF59E0B),
      weight: 5,
      isEnabled: true,
      description: 'مزايدة بلون ذهبي لمدة أسبوع كامل',
    ),
    const WheelPrizeModel(
      type: 'anonymous_auction',
      label: 'مزايد مجهول',
      emoji: '🎭',
      color: Color(0xFF64748B),
      weight: 5,
      isEnabled: true,
      description: 'إخفاء هويتك في مزاد واحد (تظهر كـ "مزايد مجهول")',
    ),
    const WheelPrizeModel(
      type: 'pinned_message',
      label: 'تثبيت رسالة',
      emoji: '📌',
      color: Color(0xFFEF4444),
      weight: 5,
      isEnabled: true,
      description: 'تثبيت رسالتك في أي شات لمدة دقيقة',
    ),
  ];

  static final _sellerPrizes = <WheelPrizeModel>[
    const WheelPrizeModel(
      type: 'points_50',
      label: '50 نقطة',
      emoji: '🌑',
      color: Color(0xFF6366F1),
      weight: 20,
      isEnabled: true,
      description: 'احصل على 50 نقطة تُضاف لرصيدك فوراً',
    ),
    const WheelPrizeModel(
      type: 'points_100',
      label: '100 نقطة',
      emoji: '🌕',
      color: Color(0xFF8B5CF6),
      weight: 15,
      isEnabled: true,
      description: 'احصل على 100 نقطة تُضاف لرصيدك فوراً',
    ),
    const WheelPrizeModel(
      type: 'commission_discount',
      label: 'خصم العمولة',
      emoji: '💰',
      color: Color(0xFF14B8A6),
      weight: 10,
      isEnabled: true,
      description: 'خصم عمولة التطبيق من مزادك القادم',
    ),
    const WheelPrizeModel(
      type: 'sub_discount_10',
      label: 'خصم 10%',
      emoji: '✂️',
      color: Color(0xFFEC4899),
      weight: 15,
      isEnabled: true,
      description: 'خصم 10% على اشتراك اللوفت القادم',
    ),
    const WheelPrizeModel(
      type: 'lucky_next',
      label: 'حظاً أوفر',
      emoji: '🍀',
      color: Color(0xFF22C55E),
      weight: 25,
      isEnabled: true,
      description: 'حظ أوفر في المرة القادمة!',
    ),
    const WheelPrizeModel(
      type: 'featured_room_bg',
      label: 'خلفية مميزة',
      emoji: '🖼️',
      color: Color(0xFF4F46E5),
      weight: 5,
      isEnabled: true,
      description: 'خلفية غرفة مميزة لمدة 24 ساعة',
    ),
    const WheelPrizeModel(
      type: 'auto_welcome_bot',
      label: 'بوت ترحيب',
      emoji: '🤖',
      color: Color(0xFF06B6D4),
      weight: 5,
      isEnabled: true,
      description: 'رسالة ترحيب آلية (بوت مجاني - يوم كامل)',
    ),
    const WheelPrizeModel(
      type: 'return_notification',
      label: 'تنبيه العودة',
      emoji: '🔔',
      color: Color(0xFFF97316),
      weight: 5,
      isEnabled: true,
      description: 'إرسال تنبيه لمن غادر الغرفة: "المزاد وصل للحسم، عد الآن!"',
    ),
  ];

  @override
  Future<List<WheelPrizeModel>> fetchPrizes({required bool isSeller}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return isSeller ? _sellerPrizes : _buyerPrizes;
  }
}
