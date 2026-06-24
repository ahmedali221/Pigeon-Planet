import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In ar, this message translates to:
  /// **'كوكب الحمام'**
  String get appName;

  /// Login button / page title
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// Register button / page title
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @country.
  ///
  /// In ar, this message translates to:
  /// **'الدولة'**
  String get country;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get welcomeBack;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @auctions.
  ///
  /// In ar, this message translates to:
  /// **'المزادات'**
  String get auctions;

  /// No description provided for @market.
  ///
  /// In ar, this message translates to:
  /// **'المتجر'**
  String get market;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @digitalId.
  ///
  /// In ar, this message translates to:
  /// **'الهوية الرقمية'**
  String get digitalId;

  /// No description provided for @ringNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحلقة'**
  String get ringNumber;

  /// No description provided for @breed.
  ///
  /// In ar, this message translates to:
  /// **'السلالة'**
  String get breed;

  /// No description provided for @gender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get female;

  /// No description provided for @hatchDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الفقس'**
  String get hatchDate;

  /// No description provided for @raceResults.
  ///
  /// In ar, this message translates to:
  /// **'نتائج السباقات'**
  String get raceResults;

  /// No description provided for @addPhotos.
  ///
  /// In ar, this message translates to:
  /// **'إضافة الصور'**
  String get addPhotos;

  /// No description provided for @recordVideo.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الفيديو'**
  String get recordVideo;

  /// No description provided for @preview.
  ///
  /// In ar, this message translates to:
  /// **'المعاينة'**
  String get preview;

  /// No description provided for @publish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get publish;

  /// No description provided for @addToCart.
  ///
  /// In ar, this message translates to:
  /// **'أضف إلى السلة'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In ar, this message translates to:
  /// **'اشتري الآن'**
  String get buyNow;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @verifyOtp.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من الرمز'**
  String get verifyOtp;

  /// No description provided for @resendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get resendCode;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get categories;

  /// No description provided for @products.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get products;

  /// No description provided for @activeAuctions.
  ///
  /// In ar, this message translates to:
  /// **'المزادات النشطة'**
  String get activeAuctions;

  /// No description provided for @sellerDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة البائع'**
  String get sellerDashboard;

  /// No description provided for @buyerMode.
  ///
  /// In ar, this message translates to:
  /// **'مشترٍ'**
  String get buyerMode;

  /// No description provided for @sellerMode.
  ///
  /// In ar, this message translates to:
  /// **'مقدم خدمة'**
  String get sellerMode;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @accept.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// No description provided for @change.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get change;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorOccurred;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @follow.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get follow;

  /// No description provided for @followed.
  ///
  /// In ar, this message translates to:
  /// **'متابَق'**
  String get followed;

  /// No description provided for @newAuction.
  ///
  /// In ar, this message translates to:
  /// **'مزاد جديد'**
  String get newAuction;

  /// No description provided for @myAuctions.
  ///
  /// In ar, this message translates to:
  /// **'مزاداتي'**
  String get myAuctions;

  /// No description provided for @endingSoon.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي قريباً'**
  String get endingSoon;

  /// No description provided for @searchAuctionHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مزاد...'**
  String get searchAuctionHint;

  /// No description provided for @noAuctions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مزادات'**
  String get noAuctions;

  /// No description provided for @auctionCreatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المزاد بنجاح'**
  String get auctionCreatedSuccess;

  /// No description provided for @addBirdLabel.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طائر'**
  String get addBirdLabel;

  /// No description provided for @noBirdsAdded.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم إضافة طيور بعد'**
  String get noBirdsAdded;

  /// No description provided for @addBirdBtn.
  ///
  /// In ar, this message translates to:
  /// **'+ إضافة طائر'**
  String get addBirdBtn;

  /// No description provided for @birdNumber.
  ///
  /// In ar, this message translates to:
  /// **'طائر {number}'**
  String birdNumber(int number);

  /// No description provided for @pairedBird.
  ///
  /// In ar, this message translates to:
  /// **'الطائر المزاوج'**
  String get pairedBird;

  /// No description provided for @addPairedBird.
  ///
  /// In ar, this message translates to:
  /// **'+ أضف طائراً مزاوجاً'**
  String get addPairedBird;

  /// No description provided for @startingPriceField.
  ///
  /// In ar, this message translates to:
  /// **'سعر البدء *'**
  String get startingPriceField;

  /// No description provided for @startTimeField.
  ///
  /// In ar, this message translates to:
  /// **'وقت البدء *'**
  String get startTimeField;

  /// No description provided for @endTimeField.
  ///
  /// In ar, this message translates to:
  /// **'وقت الانتهاء *'**
  String get endTimeField;

  /// No description provided for @chooseCoverImage.
  ///
  /// In ar, this message translates to:
  /// **'اختر صورة غلاف للمزاد'**
  String get chooseCoverImage;

  /// No description provided for @cancelAuctionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المزاد'**
  String get cancelAuctionTitle;

  /// No description provided for @cancelAuctionConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إلغاء هذا المزاد؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get cancelAuctionConfirm;

  /// No description provided for @auctionCancelledSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء المزاد'**
  String get auctionCancelledSuccess;

  /// No description provided for @auctionUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المزاد بنجاح'**
  String get auctionUpdatedSuccess;

  /// No description provided for @auctionDescriptionLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف المزاد'**
  String get auctionDescriptionLabel;

  /// No description provided for @startingPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر البداية'**
  String get startingPriceLabel;

  /// No description provided for @currentPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الحالي'**
  String get currentPrice;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// No description provided for @auctionDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المزاد'**
  String get auctionDetails;

  /// No description provided for @buyNowDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'شراء فوري'**
  String get buyNowDialogTitle;

  /// No description provided for @buyNowConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد شراء هذا الطائر فوراً بسعر {price} ج.م؟'**
  String buyNowConfirm(String price);

  /// No description provided for @sendPaymentRequestBtn.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب دفع'**
  String get sendPaymentRequestBtn;

  /// No description provided for @sendPaymentRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب دفع'**
  String get sendPaymentRequestTitle;

  /// No description provided for @amountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ: {amount} ج.م'**
  String amountLabel(String amount);

  /// No description provided for @bidSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزايدة بنجاح'**
  String get bidSuccessful;

  /// No description provided for @bidNowBtn.
  ///
  /// In ar, this message translates to:
  /// **'زايد الآن'**
  String get bidNowBtn;

  /// No description provided for @placeBidTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقديم مزايدة'**
  String get placeBidTitle;

  /// No description provided for @bidCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد المزايدات'**
  String get bidCount;

  /// No description provided for @limitedOffer.
  ///
  /// In ar, this message translates to:
  /// **'عرض محدود'**
  String get limitedOffer;

  /// No description provided for @tapToWatchVideo.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لعرض الفيديو'**
  String get tapToWatchVideo;

  /// No description provided for @officialAnnouncement.
  ///
  /// In ar, this message translates to:
  /// **'إعلان رسمي'**
  String get officialAnnouncement;

  /// No description provided for @noCommentsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تعليقات بعد'**
  String get noCommentsYet;

  /// No description provided for @chatDisabled.
  ///
  /// In ar, this message translates to:
  /// **'الشات غير مفعل حالياً'**
  String get chatDisabled;

  /// No description provided for @breeder.
  ///
  /// In ar, this message translates to:
  /// **'المربي'**
  String get breeder;

  /// No description provided for @interestedInquiries.
  ///
  /// In ar, this message translates to:
  /// **'استفسارات المهتمين'**
  String get interestedInquiries;

  /// No description provided for @beFirstToInquire.
  ///
  /// In ar, this message translates to:
  /// **'كن أول من يستفسر!'**
  String get beFirstToInquire;

  /// No description provided for @buyNowBeforeItsTooLate.
  ///
  /// In ar, this message translates to:
  /// **'اشتري الآن قبل فوات الفرصة!'**
  String get buyNowBeforeItsTooLate;

  /// No description provided for @specialPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الخاص'**
  String get specialPrice;

  /// No description provided for @freeDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني لجميع المحافظات 🚚'**
  String get freeDelivery;

  /// No description provided for @cashOnDelivery.
  ///
  /// In ar, this message translates to:
  /// **'الدفع عند الاستلام متاح 💳'**
  String get cashOnDelivery;

  /// No description provided for @buyerReviews.
  ///
  /// In ar, this message translates to:
  /// **'تجارب المشترين'**
  String get buyerReviews;

  /// No description provided for @sponsored.
  ///
  /// In ar, this message translates to:
  /// **'برعاية'**
  String get sponsored;

  /// No description provided for @deleteBirdTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الطائر'**
  String get deleteBirdTitle;

  /// No description provided for @deleteBirdConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الطائر؟ لا يمكن التراجع.'**
  String get deleteBirdConfirm;

  /// No description provided for @birdDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الطائر بنجاح'**
  String get birdDeletedSuccess;

  /// No description provided for @addedToCart.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة إلى السلة'**
  String get addedToCart;

  /// No description provided for @noteForSellerLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة للبائع (اختياري)'**
  String get noteForSellerLabel;

  /// No description provided for @pleaseEnterAuctionTitle.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال عنوان المزاد'**
  String get pleaseEnterAuctionTitle;

  /// No description provided for @pleaseSelectStartTime.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديد وقت البدء'**
  String get pleaseSelectStartTime;

  /// No description provided for @startTimeMustBeFuture.
  ///
  /// In ar, this message translates to:
  /// **'وقت البدء يجب أن يكون في المستقبل'**
  String get startTimeMustBeFuture;

  /// No description provided for @pleaseSelectEndTime.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديد وقت الانتهاء'**
  String get pleaseSelectEndTime;

  /// No description provided for @endTimeAfterStartTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الانتهاء يجب أن يكون بعد وقت البدء'**
  String get endTimeAfterStartTime;

  /// No description provided for @pleaseEnterValidMinBid.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال حد أدنى صحيح للمزايدة'**
  String get pleaseEnterValidMinBid;

  /// No description provided for @pleaseAddAtLeastOneBird.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إضافة طائر واحد على الأقل'**
  String get pleaseAddAtLeastOneBird;

  /// No description provided for @disableChat.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل الشات'**
  String get disableChat;

  /// No description provided for @enableChat.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الشات'**
  String get enableChat;

  /// No description provided for @auctionChatTooltip.
  ///
  /// In ar, this message translates to:
  /// **'شات المزاد'**
  String get auctionChatTooltip;

  /// No description provided for @sellerBlockedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حظر هذا البائع'**
  String get sellerBlockedSuccess;

  /// No description provided for @sellerUnblockedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الحظر'**
  String get sellerUnblockedSuccess;

  /// No description provided for @mustFollowFirst.
  ///
  /// In ar, this message translates to:
  /// **'يجب متابعة البائع أولاً للتواصل معه'**
  String get mustFollowFirst;

  /// No description provided for @notifyWhenAvailable.
  ///
  /// In ar, this message translates to:
  /// **'أخبرني عند النزول'**
  String get notifyWhenAvailable;

  /// No description provided for @expectedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المتوقع'**
  String get expectedPrice;

  /// No description provided for @myConversations.
  ///
  /// In ar, this message translates to:
  /// **'محادثاتي'**
  String get myConversations;

  /// No description provided for @switchProfile.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الملف الشخصي'**
  String get switchProfile;

  /// No description provided for @myPackage.
  ///
  /// In ar, this message translates to:
  /// **'باقتي'**
  String get myPackage;

  /// No description provided for @myBadges.
  ///
  /// In ar, this message translates to:
  /// **'أوسمتي'**
  String get myBadges;

  /// No description provided for @customerOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات العملاء'**
  String get customerOrders;

  /// No description provided for @paymentRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الدفع'**
  String get paymentRequests;

  /// No description provided for @shoppingCart.
  ///
  /// In ar, this message translates to:
  /// **'سلة الشراء'**
  String get shoppingCart;

  /// No description provided for @myOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myOrders;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @myPrizes.
  ///
  /// In ar, this message translates to:
  /// **'جوائزي'**
  String get myPrizes;

  /// No description provided for @challenges.
  ///
  /// In ar, this message translates to:
  /// **'التحديات'**
  String get challenges;

  /// No description provided for @accountVerification.
  ///
  /// In ar, this message translates to:
  /// **'توثيق الحساب'**
  String get accountVerification;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @ownershipRecord.
  ///
  /// In ar, this message translates to:
  /// **'سجل الملكية'**
  String get ownershipRecord;

  /// No description provided for @ownershipRecordDesc.
  ///
  /// In ar, this message translates to:
  /// **'نظام محمي وغير قابل للتلاعب'**
  String get ownershipRecordDesc;

  /// No description provided for @rewardsProgram.
  ///
  /// In ar, this message translates to:
  /// **'برنامج المكافآت'**
  String get rewardsProgram;

  /// No description provided for @inviteFriendsEarn.
  ///
  /// In ar, this message translates to:
  /// **'ادعُ أصدقاءك واكسب'**
  String get inviteFriendsEarn;

  /// No description provided for @inviteCode.
  ///
  /// In ar, this message translates to:
  /// **'كود الدعوة'**
  String get inviteCode;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @notifyMe.
  ///
  /// In ar, this message translates to:
  /// **'أخبرني'**
  String get notifyMe;

  /// No description provided for @pointsRedemptionComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً — ميزة الاستبدال قيد التطوير'**
  String get pointsRedemptionComingSoon;

  /// No description provided for @browseMarket.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح السوق'**
  String get browseMarket;

  /// No description provided for @searchActiveAuctionsHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالحلقة أو السلالة أو الوصف...'**
  String get searchActiveAuctionsHint;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'عربة التسوق'**
  String get cartTitle;

  /// No description provided for @clearCartBtn.
  ///
  /// In ar, this message translates to:
  /// **'إفراغ'**
  String get clearCartBtn;

  /// No description provided for @productCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد المنتجات'**
  String get productCount;

  /// No description provided for @checkoutError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء إتمام الطلب'**
  String get checkoutError;

  /// No description provided for @noOrdersYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بعد'**
  String get noOrdersYet;

  /// No description provided for @noOrdersCurrently.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات حالياً'**
  String get noOrdersCurrently;

  /// No description provided for @sendingPaymentRequest.
  ///
  /// In ar, this message translates to:
  /// **'جاري إرسال طلب الدفع…'**
  String get sendingPaymentRequest;

  /// No description provided for @activityLogTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل النشاط'**
  String get activityLogTitle;

  /// No description provided for @noActivityYet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد نشاط حتى الآن'**
  String get noActivityYet;

  /// No description provided for @profileDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الملف الشخصي'**
  String get profileDeletedSuccess;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// No description provided for @conversationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات'**
  String get conversationsTitle;

  /// No description provided for @messageInputHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك...'**
  String get messageInputHint;

  /// No description provided for @notificationUpdateError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديث حالة الإشعار'**
  String get notificationUpdateError;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get noNotifications;

  /// No description provided for @marketSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن فئة أو منتج...'**
  String get marketSearchHint;

  /// No description provided for @productSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في المنتجات...'**
  String get productSearchHint;

  /// No description provided for @badgesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأوسمة'**
  String get badgesTitle;

  /// No description provided for @myAwards.
  ///
  /// In ar, this message translates to:
  /// **'جوائزي'**
  String get myAwards;

  /// No description provided for @luckyWheelTitle.
  ///
  /// In ar, this message translates to:
  /// **'عجلة الحظ'**
  String get luckyWheelTitle;

  /// No description provided for @availablePrizes.
  ///
  /// In ar, this message translates to:
  /// **'الجوائز المتاحة'**
  String get availablePrizes;

  /// No description provided for @myPerks.
  ///
  /// In ar, this message translates to:
  /// **'امتيازاتي'**
  String get myPerks;

  /// No description provided for @noPerksAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا امتيازات متاحة حالياً'**
  String get noPerksAvailable;

  /// No description provided for @spinWheelForPerks.
  ///
  /// In ar, this message translates to:
  /// **'أدر عجلة الحظ للحصول على امتيازات'**
  String get spinWheelForPerks;

  /// No description provided for @auctionIdHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل ID المزاد'**
  String get auctionIdHint;

  /// No description provided for @messageIdHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل ID الرسالة'**
  String get messageIdHint;

  /// No description provided for @auctionIdLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم المزاد'**
  String get auctionIdLabel;

  /// No description provided for @messageIdLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الرسالة'**
  String get messageIdLabel;

  /// No description provided for @activatePerks.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل {name}'**
  String activatePerks(String name);

  /// No description provided for @pinMessage.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت رسالة'**
  String get pinMessage;

  /// No description provided for @pinMessageDesc.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الرسالة التي تريد تثبيتها لمدة دقيقة'**
  String get pinMessageDesc;

  /// No description provided for @pin.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت'**
  String get pin;

  /// No description provided for @viewMyPerks.
  ///
  /// In ar, this message translates to:
  /// **'عرض امتيازاتي واستخدامها'**
  String get viewMyPerks;

  /// No description provided for @paymentRequestSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الدفع بنجاح'**
  String get paymentRequestSentSuccess;

  /// No description provided for @noPaymentRequests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات دفع حتى الآن'**
  String get noPaymentRequests;

  /// No description provided for @operationSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تمت العملية بنجاح'**
  String get operationSuccessful;

  /// No description provided for @saveNote.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الملاحظة'**
  String get saveNote;

  /// No description provided for @imageUploadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل رفع الصورة، حاول مجدداً'**
  String get imageUploadError;

  /// No description provided for @paymentProofSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال إثبات الدفع بنجاح'**
  String get paymentProofSentSuccess;

  /// No description provided for @addImageBtn.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get addImageBtn;

  /// No description provided for @sendProofBtn.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الإثبات'**
  String get sendProofBtn;

  /// No description provided for @rejectionNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة الرفض (اختياري)'**
  String get rejectionNoteLabel;

  /// No description provided for @rejectionNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض إن وجد…'**
  String get rejectionNoteHint;

  /// No description provided for @noteForBuyerLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظتك للبائع'**
  String get noteForBuyerLabel;

  /// No description provided for @noteForBuyerHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف أي تعليق أو توضيح…'**
  String get noteForBuyerHint;

  /// No description provided for @complaintValidation.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان الشكوى ووصفها'**
  String get complaintValidation;

  /// No description provided for @complaintSubmittedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تقديم الشكوى بنجاح'**
  String get complaintSubmittedSuccess;

  /// No description provided for @afterSaleComplaint.
  ///
  /// In ar, this message translates to:
  /// **'ما بعد البيع'**
  String get afterSaleComplaint;

  /// No description provided for @rejectedPaymentComplaint.
  ///
  /// In ar, this message translates to:
  /// **'دفع مرفوض'**
  String get rejectedPaymentComplaint;

  /// No description provided for @otherComplaint.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get otherComplaint;

  /// No description provided for @complaintCancelledSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الشكوى'**
  String get complaintCancelledSuccess;

  /// No description provided for @cancelComplaintTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الشكوى'**
  String get cancelComplaintTitle;

  /// No description provided for @cancelComplaintConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذه الشكوى؟'**
  String get cancelComplaintConfirm;

  /// No description provided for @complaintTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الشكوى'**
  String get complaintTitleLabel;

  /// No description provided for @complaintTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الشكوى'**
  String get complaintTypeLabel;

  /// No description provided for @complaintDescLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف المشكلة'**
  String get complaintDescLabel;

  /// No description provided for @complaintDescHint.
  ///
  /// In ar, this message translates to:
  /// **'اشرح ما حدث بوضوح...'**
  String get complaintDescHint;

  /// No description provided for @enterRingNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الحلقة'**
  String get enterRingNumber;

  /// No description provided for @reviewSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت المراجعة بنجاح'**
  String get reviewSuccess;

  /// No description provided for @pedigreeRingLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم حلقة الطائر'**
  String get pedigreeRingLabel;

  /// No description provided for @pedigreeRingHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: EG-2024-12345'**
  String get pedigreeRingHint;

  /// No description provided for @pedigreeDescHint.
  ///
  /// In ar, this message translates to:
  /// **'وصف إضافي من شهادة النسب'**
  String get pedigreeDescHint;

  /// No description provided for @pdfFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف PDF'**
  String get pdfFile;

  /// No description provided for @ratingSubmittedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال بنجاح'**
  String get ratingSubmittedSuccess;

  /// No description provided for @ratingLabel.
  ///
  /// In ar, this message translates to:
  /// **'تقييم'**
  String get ratingLabel;

  /// No description provided for @commentLabel.
  ///
  /// In ar, this message translates to:
  /// **'تعليق'**
  String get commentLabel;

  /// No description provided for @submitRatingBtn.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get submitRatingBtn;

  /// No description provided for @submitCommentBtn.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التعليق'**
  String get submitCommentBtn;

  /// No description provided for @addCommentHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف تعليقاً (اختياري)'**
  String get addCommentHint;

  /// No description provided for @writeYourComment.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقك هنا...'**
  String get writeYourComment;

  /// No description provided for @invalidQrCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز QR غير صالح — لا ينتمي لطائر في كوكب الحمام'**
  String get invalidQrCode;

  /// No description provided for @pigeonFormValidation.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم الحلقة والسلالة والإنجازات'**
  String get pigeonFormValidation;

  /// No description provided for @birdDataUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل بيانات الطائر بنجاح'**
  String get birdDataUpdated;

  /// No description provided for @capturePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get capturePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من المعرض'**
  String get chooseFromGallery;

  /// No description provided for @requiredField.
  ///
  /// In ar, this message translates to:
  /// **'إلزامي'**
  String get requiredField;

  /// No description provided for @noPhotos.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صور'**
  String get noPhotos;

  /// No description provided for @printFeatureComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إضافة الطباعة قريباً'**
  String get printFeatureComingSoon;

  /// No description provided for @printBtn.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get printBtn;

  /// No description provided for @shareFeatureComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إضافة المشاركة قريباً'**
  String get shareFeatureComingSoon;

  /// No description provided for @publishPigeon.
  ///
  /// In ar, this message translates to:
  /// **'نشر الحمامة'**
  String get publishPigeon;

  /// No description provided for @publishLinkComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم ربط النشر في الخطوة القادمة'**
  String get publishLinkComingSoon;

  /// No description provided for @viewPedigreeCertificate.
  ///
  /// In ar, this message translates to:
  /// **'عرض شهادة النسب'**
  String get viewPedigreeCertificate;

  /// No description provided for @processingLabel.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل...'**
  String get processingLabel;

  /// No description provided for @reprocessBtn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المعالجة'**
  String get reprocessBtn;

  /// No description provided for @otpNewCodeSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز جديد'**
  String get otpNewCodeSent;

  /// No description provided for @automatic.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get automatic;

  /// No description provided for @useBtn.
  ///
  /// In ar, this message translates to:
  /// **'استخدام'**
  String get useBtn;

  /// No description provided for @later.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get later;

  /// No description provided for @auctionTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المزاد'**
  String get auctionTitleLabel;

  /// No description provided for @auctionTitleRequired.
  ///
  /// In ar, this message translates to:
  /// **'العنوان مطلوب'**
  String get auctionTitleRequired;

  /// No description provided for @auctionTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان المزاد'**
  String get auctionTitleHint;

  /// No description provided for @auctionDescHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل وصف المزاد'**
  String get auctionDescHint;

  /// No description provided for @tagsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوسوم (Tags)'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: حمام, سباق, نادر'**
  String get tagsHint;

  /// No description provided for @auctionEditNote.
  ///
  /// In ar, this message translates to:
  /// **'يمكن تعديل العنوان والوصف والوسوم فقط، ولا يمكن تعديل الأسعار أو الطيور بعد إنشاء المزاد.'**
  String get auctionEditNote;

  /// No description provided for @myBids.
  ///
  /// In ar, this message translates to:
  /// **'مزايداتي'**
  String get myBids;

  /// No description provided for @noBidsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مزايدات بعد'**
  String get noBidsYet;

  /// No description provided for @winningBid.
  ///
  /// In ar, this message translates to:
  /// **'مزايدة فائزة'**
  String get winningBid;

  /// No description provided for @bidders.
  ///
  /// In ar, this message translates to:
  /// **'المزايدون'**
  String get bidders;

  /// No description provided for @unknown.
  ///
  /// In ar, this message translates to:
  /// **'مجهول'**
  String get unknown;

  /// No description provided for @highestBid.
  ///
  /// In ar, this message translates to:
  /// **'أعلى مزايدة'**
  String get highestBid;

  /// No description provided for @now.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {minutes} دقيقة'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {hours} ساعة'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {days} يوم'**
  String daysAgo(int days);

  /// No description provided for @managePedigreeCertificate.
  ///
  /// In ar, this message translates to:
  /// **'إدارة شهادة النسب'**
  String get managePedigreeCertificate;

  /// No description provided for @verifiedPedigree.
  ///
  /// In ar, this message translates to:
  /// **'نسب موثقة'**
  String get verifiedPedigree;

  /// No description provided for @healthGuarantee.
  ///
  /// In ar, this message translates to:
  /// **'ضمان صحي'**
  String get healthGuarantee;

  /// No description provided for @racesAndResults.
  ///
  /// In ar, this message translates to:
  /// **'النتائج والسباقات'**
  String get racesAndResults;

  /// No description provided for @races.
  ///
  /// In ar, this message translates to:
  /// **'السباقات'**
  String get races;

  /// No description provided for @searchResults.
  ///
  /// In ar, this message translates to:
  /// **'بحث النتائج'**
  String get searchResults;

  /// No description provided for @racesSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث في السباقات...'**
  String get racesSearchHint;

  /// No description provided for @noRacesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سباقات بعد'**
  String get noRacesYet;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @noMatchingResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get noMatchingResults;

  /// No description provided for @season.
  ///
  /// In ar, this message translates to:
  /// **'الموسم'**
  String get season;

  /// No description provided for @station.
  ///
  /// In ar, this message translates to:
  /// **'المحطة'**
  String get station;

  /// No description provided for @applyFilter.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الفلتر'**
  String get applyFilter;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @raceSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحلقة أو اسم المتسابق...'**
  String get raceSearchHint;

  /// No description provided for @raceSearchDesc.
  ///
  /// In ar, this message translates to:
  /// **'ابحث برقم حلقة الحمام أو اسم المتسابق'**
  String get raceSearchDesc;

  /// No description provided for @bird.
  ///
  /// In ar, this message translates to:
  /// **'طائر'**
  String get bird;

  /// No description provided for @racer.
  ///
  /// In ar, this message translates to:
  /// **'متسابق'**
  String get racer;

  /// No description provided for @ringLabel.
  ///
  /// In ar, this message translates to:
  /// **'حلقة: {ring}'**
  String ringLabel(String ring);

  /// No description provided for @loadMore.
  ///
  /// In ar, this message translates to:
  /// **'تحميل المزيد'**
  String get loadMore;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
