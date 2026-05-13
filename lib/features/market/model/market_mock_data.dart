import 'category_model.dart';
import 'product_model.dart';

class MarketMockData {
  static const categories = [
    CategoryModel(id: 'supplies', name: 'مستلزمات الحمام', emoji: '🔧'),
    CategoryModel(id: 'accessories', name: 'إكسسوارات', emoji: '💊'),
    CategoryModel(id: 'supplements', name: 'المكملات الغذائية', emoji: '⚡'),
    CategoryModel(id: 'feeds', name: 'الأعلاف والحبوب', emoji: '🌾'),
    CategoryModel(id: 'birds', name: 'حمام للبيع', emoji: '🐦'),
  ];

  static const products = [
    ProductModel(
      id: 'p1',
      categoryId: 'supplies',
      name: 'قفص حمام زاجل احترافي',
      description:
          'قفص مصنوع من الفولاذ المقاوم للصدأ بتصميم مريح للطيور ويسمح بتهوية ممتازة.',
      price: 850,
      benefits: [
        'مقاوم للصدأ والعوامل الجوية',
        'تهوية ممتازة من جميع الجهات',
        'باب واسع سهل التنظيف',
      ],
      rating: 4.8,
      reviewCount: 145,
      isBestSeller: true,
      seed: 80,
    ),
    ProductModel(
      id: 'p2',
      categoryId: 'supplies',
      name: 'مسقاة أوتوماتيكية',
      description: 'مسقاة ذكية بنظام تعبئة تلقائي بالجاذبية.',
      price: 180,
      rating: 4.6,
      reviewCount: 89,
      seed: 81,
    ),
    ProductModel(
      id: 'p3',
      categoryId: 'supplements',
      name: 'فيتامينات متكاملة للزاجل',
      description:
          'مزيج متوازن من الفيتامينات والمعادن الضرورية لدعم صحة الحمام.',
      price: 160,
      benefits: [
        'يحتوي على 12 فيتاميناً أساسياً',
        'يعزز مقاومة الأمراض',
        'يحسن جودة الريش واللمعان',
      ],
      rating: 4.8,
      reviewCount: 318,
      isBestSeller: true,
      seed: 89,
    ),
    ProductModel(
      id: 'p4',
      categoryId: 'feeds',
      name: 'خليط حبوب متكامل للحمام الزاجل',
      description:
          'خليط متوازن من أفضل أنواع الحبوب المختارة بعناية للحمام الزاجل.',
      price: 280,
      benefits: [
        'طاقة عالية للطيران لمسافات طويلة',
        'تحسين الأداء الرياضي',
      ],
      rating: 4.8,
      reviewCount: 234,
      isBestSeller: true,
      seed: 91,
    ),
  ];
}
