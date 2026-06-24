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

  /// No description provided for @editAuction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المزاد'**
  String get editAuction;

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

  /// No description provided for @limitedOfferRareOpportunity.
  ///
  /// In ar, this message translates to:
  /// **'عرض محدود - فرصة نادرة'**
  String get limitedOfferRareOpportunity;

  /// No description provided for @ownTodaysChampionWinTomorrow.
  ///
  /// In ar, this message translates to:
  /// **'اقتني بطل اليوم - حقق انتصارات الغد'**
  String get ownTodaysChampionWinTomorrow;

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

  /// Upload box file size/type hint
  ///
  /// In ar, this message translates to:
  /// **'PNG, JPG حتى 10MB'**
  String get uploadSizeHint;

  /// Service provider registration subtitle
  ///
  /// In ar, this message translates to:
  /// **'للشركات والموردين'**
  String get serviceProviderSubtitle;

  /// No description provided for @mustAgreeToTerms.
  ///
  /// In ar, this message translates to:
  /// **'يجب الموافقة على الشروط والأحكام'**
  String get mustAgreeToTerms;

  /// No description provided for @registerSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب بنجاح'**
  String get registerSuccess;

  /// No description provided for @username.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المستخدم (بدون مسافات)'**
  String get usernameHint;

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور مرة أخرى'**
  String get confirmPasswordHint;

  /// Personal account type label
  ///
  /// In ar, this message translates to:
  /// **'حساب شخصي'**
  String get personalAccount;

  /// Personal account type subtitle
  ///
  /// In ar, this message translates to:
  /// **'للمربين والمشترين'**
  String get personalAccountSub;

  /// Phone number input hint
  ///
  /// In ar, this message translates to:
  /// **'+20 1xx xxx xxxx'**
  String get phoneHint;

  /// Age label
  ///
  /// In ar, this message translates to:
  /// **'العمر'**
  String get age;

  /// Location label
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// Flying speed label
  ///
  /// In ar, this message translates to:
  /// **'السرعة'**
  String get flyingSpeed;

  /// Kilometres per hour unit abbreviation
  ///
  /// In ar, this message translates to:
  /// **'كم/س'**
  String get kmPerHour;

  /// Stamina label
  ///
  /// In ar, this message translates to:
  /// **'التحمل'**
  String get stamina;

  /// Achievements label
  ///
  /// In ar, this message translates to:
  /// **'الإنجازات'**
  String get achievements;

  /// Stamina level: excellent
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get staminaExcellent;

  /// Stamina level: very good
  ///
  /// In ar, this message translates to:
  /// **'جيد جداً'**
  String get staminaVeryGood;

  /// Stamina level: good
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get staminaGood;

  /// Gender/age label: young (chick)
  ///
  /// In ar, this message translates to:
  /// **'صغير'**
  String get genderYoung;

  /// Label shown when an auction countdown has expired
  ///
  /// In ar, this message translates to:
  /// **'انتهى'**
  String get auctionEnded;

  /// No description provided for @priceEgpFormat.
  ///
  /// In ar, this message translates to:
  /// **'ج.م {amount}'**
  String priceEgpFormat(String amount);

  /// Value is unspecified / unknown
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get unspecified;

  /// Age label: less than one year old
  ///
  /// In ar, this message translates to:
  /// **'أقل من سنة'**
  String get lessThanAYear;

  /// Location or field not available
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get notAvailable;

  /// Fallback when no description is provided
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد وصف.'**
  String get noDescription;

  /// AppBar title for the bird detail page
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحمام'**
  String get pigeonDetails;

  /// No description provided for @savingsAmount.
  ///
  /// In ar, this message translates to:
  /// **'توفير {amount} ج.م'**
  String savingsAmount(String amount);

  /// No description provided for @discountPercent.
  ///
  /// In ar, this message translates to:
  /// **'خصم {percent}%'**
  String discountPercent(Object percent);

  /// No description provided for @liveViewersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} شخص يشاهدون الآن'**
  String liveViewersCount(Object count);

  /// No description provided for @todayRequestsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طلب اليوم'**
  String todayRequestsCount(Object count);

  /// Button label shown to the owner instead of buy now
  ///
  /// In ar, this message translates to:
  /// **'هذا الطائر ملكك'**
  String get thisBirdIsYours;

  /// Buy now button label with limited offer note
  ///
  /// In ar, this message translates to:
  /// **'🛒 اشتري الآن - عرض لفترة محدودة!'**
  String get buyNowLimitedOffer;

  /// DNA registered verification chip label
  ///
  /// In ar, this message translates to:
  /// **'DNA مسجل'**
  String get dnaRegistered;

  /// Label for the bird photo thumbnail
  ///
  /// In ar, this message translates to:
  /// **'صورة الطير'**
  String get birdPhoto;

  /// Label for the wing photo thumbnail
  ///
  /// In ar, this message translates to:
  /// **'الجناح'**
  String get birdWing;

  /// Label for the eye photo thumbnail
  ///
  /// In ar, this message translates to:
  /// **'العين'**
  String get birdEye;

  /// Label for the ring number photo thumbnail
  ///
  /// In ar, this message translates to:
  /// **'رقم الدبلة'**
  String get ringNumberThumbnail;

  /// No description provided for @photoNumber.
  ///
  /// In ar, this message translates to:
  /// **'صورة {number}'**
  String photoNumber(int number);

  /// Label for the bird video thumbnail
  ///
  /// In ar, this message translates to:
  /// **'فيديو الطير'**
  String get birdVideo;

  /// View count badge showing zero views on media
  ///
  /// In ar, this message translates to:
  /// **'0 مشاهدة'**
  String get zeroViews;

  /// Empty state when there are no reviews
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد'**
  String get noReviewsYet;

  /// Button to view all reviews with count
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع التقييمات ({count})'**
  String viewAllReviews(int count);

  /// No description provided for @emptyCartTitle.
  ///
  /// In ar, this message translates to:
  /// **'عربتك فارغة'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح السوق وأضف منتجات إلى عربتك'**
  String get emptyCartSubtitle;

  /// No description provided for @completeOrder.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get completeOrder;

  /// Section header listing the birds in a given auction
  ///
  /// In ar, this message translates to:
  /// **'الطيور في هذا المزاد'**
  String get birdsInThisAuction;

  /// Countdown: days remaining
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم متبقي'**
  String daysRemaining(int count);

  /// Countdown: hours remaining
  ///
  /// In ar, this message translates to:
  /// **'{count} ساعة متبقية'**
  String hoursRemaining(int count);

  /// Countdown: minutes remaining
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة متبقية'**
  String minutesRemaining(int count);

  /// Auction/item status: active
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get statusActive;

  /// Auction/item status: ended
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get statusEnded;

  /// Auction/item status: upcoming
  ///
  /// In ar, this message translates to:
  /// **'قادم'**
  String get statusUpcoming;

  /// Item status: sold
  ///
  /// In ar, this message translates to:
  /// **'مُباع'**
  String get statusSold;

  /// Item status: unsold
  ///
  /// In ar, this message translates to:
  /// **'غير مُباع'**
  String get statusUnsold;

  /// Item status: cancelled
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get statusCancelled;

  /// Minimum bid increment label with amount
  ///
  /// In ar, this message translates to:
  /// **'حد أدنى: {amount} ج.م'**
  String minBidLabel(String amount);

  /// Number of birds in the auction
  ///
  /// In ar, this message translates to:
  /// **'{count} طائر'**
  String birdCount(int count);

  /// Number of bids on an auction item
  ///
  /// In ar, this message translates to:
  /// **'{count} مزايدة'**
  String bidCountLabel(int count);

  /// No description provided for @byProceedingYouAgree.
  ///
  /// In ar, this message translates to:
  /// **'بالمتابعة، أنت توافق على '**
  String get byProceedingYouAgree;

  /// No description provided for @andConnector.
  ///
  /// In ar, this message translates to:
  /// **' و'**
  String get andConnector;

  /// No description provided for @auctionBidAmountEgp.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ج.م'**
  String auctionBidAmountEgp(String amount);

  /// No description provided for @viewAllReviewsText.
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع التقييمات'**
  String get viewAllReviewsText;

  /// No description provided for @blockSeller.
  ///
  /// In ar, this message translates to:
  /// **'حظر البائع'**
  String get blockSeller;

  /// No description provided for @unblockSeller.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحظر'**
  String get unblockSeller;

  /// No description provided for @followingNow.
  ///
  /// In ar, this message translates to:
  /// **'تتابع الآن'**
  String get followingNow;

  /// No description provided for @contactSeller.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع البائع'**
  String get contactSeller;

  /// No description provided for @followSellerToContact.
  ///
  /// In ar, this message translates to:
  /// **'تابع هذا البائع للتواصل معه'**
  String get followSellerToContact;

  /// No description provided for @aboutBreeder.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عن المربي'**
  String get aboutBreeder;

  /// No description provided for @noAdditionalInfo.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معلومات إضافية'**
  String get noAdditionalInfo;

  /// No description provided for @breederAuctions.
  ///
  /// In ar, this message translates to:
  /// **'مزادات المربي'**
  String get breederAuctions;

  /// No description provided for @reviews.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviews;

  /// No description provided for @averageRating.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التقييم'**
  String get averageRating;

  /// No description provided for @activeAuction.
  ///
  /// In ar, this message translates to:
  /// **'مزاد نشط'**
  String get activeAuction;

  /// No description provided for @outOfFive.
  ///
  /// In ar, this message translates to:
  /// **'من 5'**
  String get outOfFive;

  /// No description provided for @whatDoYouWantToAdd.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تريد أن تضيف؟'**
  String get whatDoYouWantToAdd;

  /// No description provided for @addAuctionBirds.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طيور للمزاد'**
  String get addAuctionBirds;

  /// No description provided for @startAuctionForBirds.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ مزاد على حمامك الزاجل'**
  String get startAuctionForBirds;

  /// No description provided for @addFixedPriceBirds.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طيور بسعر ثابت'**
  String get addFixedPriceBirds;

  /// No description provided for @directSaleFixedPrice.
  ///
  /// In ar, this message translates to:
  /// **'بيع مباشر بسعر محدد مسبقاً'**
  String get directSaleFixedPrice;

  /// No description provided for @addProducts.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتجات'**
  String get addProducts;

  /// No description provided for @productsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدوية، مكملات، مستلزمات وأكثر'**
  String get productsSubtitle;

  /// No description provided for @manageSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'إدارة اشتراكاتي'**
  String get manageSubscriptions;

  /// No description provided for @subscribeToCreateAuctions.
  ///
  /// In ar, this message translates to:
  /// **'اشترك في باقة لتتمكن من إنشاء المزادات'**
  String get subscribeToCreateAuctions;

  /// No description provided for @dataLoadError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل البيانات'**
  String get dataLoadError;

  /// No description provided for @discoverAuctionsAndBreeders.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف أحدث المزادات والمربين'**
  String get discoverAuctionsAndBreeders;

  /// No description provided for @bestSeller.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مبيعاً'**
  String get bestSeller;

  /// No description provided for @browseProducts.
  ///
  /// In ar, this message translates to:
  /// **'تصفح المنتجات'**
  String get browseProducts;

  /// No description provided for @free.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get free;

  /// No description provided for @homeDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل للمنزل'**
  String get homeDelivery;

  /// No description provided for @availableProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج متاح'**
  String get availableProduct;

  /// No description provided for @allProductsHighQuality.
  ///
  /// In ar, this message translates to:
  /// **'جميع المنتجات عالية الجودة'**
  String get allProductsHighQuality;

  /// No description provided for @certifiedOriginalProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات أصلية معتمدة لصحة حمامك'**
  String get certifiedOriginalProducts;

  /// No description provided for @activeOffers.
  ///
  /// In ar, this message translates to:
  /// **'عروض نشطة'**
  String get activeOffers;

  /// No description provided for @suggestedForYou.
  ///
  /// In ar, this message translates to:
  /// **'مقترح لك'**
  String get suggestedForYou;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @followedAlt.
  ///
  /// In ar, this message translates to:
  /// **'متابَع'**
  String get followedAlt;

  /// No description provided for @noProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get noProducts;

  /// No description provided for @newest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get newest;

  /// No description provided for @priceLowToHigh.
  ///
  /// In ar, this message translates to:
  /// **'السعر: الأقل أولاً'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In ar, this message translates to:
  /// **'السعر: الأعلى أولاً'**
  String get priceHighToLow;

  /// No description provided for @sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// No description provided for @benefits.
  ///
  /// In ar, this message translates to:
  /// **'الفوائد'**
  String get benefits;

  /// No description provided for @myInsights.
  ///
  /// In ar, this message translates to:
  /// **'إحصائياتي'**
  String get myInsights;

  /// No description provided for @insightsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل الإحصائيات'**
  String get insightsLoadError;

  /// No description provided for @closedAuctions.
  ///
  /// In ar, this message translates to:
  /// **'مزادات مغلقة'**
  String get closedAuctions;

  /// No description provided for @totalOffersReceived.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العروض المستلمة'**
  String get totalOffersReceived;

  /// No description provided for @uniqueBidders.
  ///
  /// In ar, this message translates to:
  /// **'مزايدون فريدون'**
  String get uniqueBidders;

  /// No description provided for @completedSales.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات مكتملة'**
  String get completedSales;

  /// No description provided for @pendingPaymentRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات دفع معلقة'**
  String get pendingPaymentRequests;

  /// No description provided for @listedProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات معروضة'**
  String get listedProducts;

  /// No description provided for @pendingOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات معلقة'**
  String get pendingOrders;

  /// No description provided for @lowStock.
  ///
  /// In ar, this message translates to:
  /// **'مخزون منخفض'**
  String get lowStock;

  /// No description provided for @engagement.
  ///
  /// In ar, this message translates to:
  /// **'التفاعل'**
  String get engagement;

  /// No description provided for @totalFollowers.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المتابعين'**
  String get totalFollowers;

  /// No description provided for @newFollowers7Days.
  ///
  /// In ar, this message translates to:
  /// **'متابعون جدد (7 أيام)'**
  String get newFollowers7Days;

  /// No description provided for @activeConversations.
  ///
  /// In ar, this message translates to:
  /// **'محادثات نشطة'**
  String get activeConversations;

  /// No description provided for @unreadMessages.
  ///
  /// In ar, this message translates to:
  /// **'رسائل غير مقروءة'**
  String get unreadMessages;

  /// No description provided for @profileViews7Days.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدات الملف (7 أيام)'**
  String get profileViews7Days;

  /// No description provided for @auctionViews7Days.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدات المزادات (7 أيام)'**
  String get auctionViews7Days;

  /// No description provided for @marketViews7Days.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدات المتجر (7 أيام)'**
  String get marketViews7Days;

  /// No description provided for @trust.
  ///
  /// In ar, this message translates to:
  /// **'الموثوقية'**
  String get trust;

  /// No description provided for @ratingsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد التقييمات'**
  String get ratingsCount;

  /// No description provided for @newReviews7Days.
  ///
  /// In ar, this message translates to:
  /// **'مراجعات جديدة (7 أيام)'**
  String get newReviews7Days;

  /// No description provided for @badges.
  ///
  /// In ar, this message translates to:
  /// **'الشارات'**
  String get badges;

  /// No description provided for @package.
  ///
  /// In ar, this message translates to:
  /// **'الباقة'**
  String get package;

  /// No description provided for @currentPackage.
  ///
  /// In ar, this message translates to:
  /// **'الباقة الحالية'**
  String get currentPackage;

  /// No description provided for @packageNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الباقة'**
  String get packageNumber;

  /// No description provided for @subscriptionStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الاشتراك'**
  String get subscriptionStatus;

  /// No description provided for @inactive.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get inactive;

  /// No description provided for @remainingAuctionQuota.
  ///
  /// In ar, this message translates to:
  /// **'حصة المزادات المتبقية'**
  String get remainingAuctionQuota;

  /// No description provided for @remainingMarketQuota.
  ///
  /// In ar, this message translates to:
  /// **'حصة المتجر المتبقية'**
  String get remainingMarketQuota;

  /// No description provided for @remainingPackagePoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط الباقة المتبقية'**
  String get remainingPackagePoints;

  /// No description provided for @promotedAuctions.
  ///
  /// In ar, this message translates to:
  /// **'مزادات مروجة'**
  String get promotedAuctions;

  /// No description provided for @promotedProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات مروجة'**
  String get promotedProducts;

  /// No description provided for @packageExpiryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ انتهاء الباقة'**
  String get packageExpiryDate;

  /// No description provided for @activeOnly.
  ///
  /// In ar, this message translates to:
  /// **'النشطة فقط'**
  String get activeOnly;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get previous;

  /// No description provided for @badgesLoadError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في تحميل الأوسمة'**
  String get badgesLoadError;

  /// No description provided for @noBadgesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أوسمة بعد'**
  String get noBadgesYet;

  /// No description provided for @completeDealsForBadges.
  ///
  /// In ar, this message translates to:
  /// **'أكمل صفقاتك وتفاعل مع المنصة لتحصل على أوسمة'**
  String get completeDealsForBadges;

  /// No description provided for @expired.
  ///
  /// In ar, this message translates to:
  /// **'منتهٍ'**
  String get expired;

  /// No description provided for @enterValidPrice.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال سعر صحيح'**
  String get enterValidPrice;

  /// No description provided for @viewPackages.
  ///
  /// In ar, this message translates to:
  /// **'عرض الباقات'**
  String get viewPackages;

  /// No description provided for @createNewAuction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مزاد جديد'**
  String get createNewAuction;

  /// No description provided for @auctionData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المزاد'**
  String get auctionData;

  /// No description provided for @auctionTitleFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المزاد *'**
  String get auctionTitleFieldLabel;

  /// No description provided for @auctionTitleExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: حمام زاجل مميز'**
  String get auctionTitleExample;

  /// No description provided for @auctionDescBriefHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب وصفاً مختصراً للمزاد'**
  String get auctionDescBriefHint;

  /// No description provided for @auctionImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة المزاد'**
  String get auctionImage;

  /// No description provided for @auctionTypeField.
  ///
  /// In ar, this message translates to:
  /// **'نوع المزاد'**
  String get auctionTypeField;

  /// No description provided for @chooseStartDateTime.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ ووقت البدء'**
  String get chooseStartDateTime;

  /// No description provided for @chooseEndDateTime.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ ووقت الانتهاء'**
  String get chooseEndDateTime;

  /// No description provided for @minBidField.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للمزايدة'**
  String get minBidField;

  /// No description provided for @tagsFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوسوم'**
  String get tagsFieldLabel;

  /// No description provided for @auctionSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المزاد'**
  String get auctionSettings;

  /// No description provided for @autoExtend.
  ///
  /// In ar, this message translates to:
  /// **'تمديد تلقائي'**
  String get autoExtend;

  /// No description provided for @autoExtendDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمديد المزاد تلقائياً عند وجود مزايدات في آخر الدقائق'**
  String get autoExtendDesc;

  /// No description provided for @extensionDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة التمديد'**
  String get extensionDuration;

  /// No description provided for @buyNowDesc.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالشراء الفوري'**
  String get buyNowDesc;

  /// No description provided for @buyNowPriceField.
  ///
  /// In ar, this message translates to:
  /// **'سعر الشراء الفوري'**
  String get buyNowPriceField;

  /// No description provided for @depositRequired.
  ///
  /// In ar, this message translates to:
  /// **'العربون مطلوب'**
  String get depositRequired;

  /// No description provided for @depositRequiredDesc.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب المزاد دفع عربون لتأكيد المزايدة'**
  String get depositRequiredDesc;

  /// No description provided for @paymentDeadlineDays.
  ///
  /// In ar, this message translates to:
  /// **'مهلة الدفع بالأيام'**
  String get paymentDeadlineDays;

  /// No description provided for @birdsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الطيور: {arg0}'**
  String birdsCount(Object arg0);

  /// No description provided for @createAuction.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء المزاد'**
  String get createAuction;

  /// No description provided for @nextArrow.
  ///
  /// In ar, this message translates to:
  /// **'التالي ←'**
  String get nextArrow;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @birds.
  ///
  /// In ar, this message translates to:
  /// **'الطيور'**
  String get birds;

  /// No description provided for @chick.
  ///
  /// In ar, this message translates to:
  /// **'فرخ'**
  String get chick;

  /// No description provided for @buyNowConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد الشراء الآن بسعر {arg0} ج.م؟'**
  String buyNowConfirmMessage(Object arg0);

  /// No description provided for @amountDisplay.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ: {arg0} ج.م'**
  String amountDisplay(Object arg0);

  /// No description provided for @viewPaymentDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الدفع'**
  String get viewPaymentDetails;

  /// No description provided for @minBidDisplay.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى: {arg0} ج.م'**
  String minBidDisplay(Object arg0);

  /// No description provided for @yourAuctionCannotBid.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك المزايدة على مزادك'**
  String get yourAuctionCannotBid;

  /// No description provided for @auctionNotStartedYet.
  ///
  /// In ar, this message translates to:
  /// **'المزاد لم يبدأ بعد'**
  String get auctionNotStartedYet;

  /// No description provided for @wonAuction.
  ///
  /// In ar, this message translates to:
  /// **'فزت بالمزاد #{arg0}'**
  String wonAuction(Object arg0);

  /// No description provided for @enterValidNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقماً صحيحاً'**
  String get enterValidNumber;

  /// No description provided for @minBidValidation.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا تقل المزايدة عن {arg0}'**
  String minBidValidation(Object arg0);

  /// No description provided for @minimumLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى'**
  String get minimumLabel;

  /// No description provided for @orderConfirmationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get orderConfirmationTitle;

  /// No description provided for @orderSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب بنجاح'**
  String get orderSentSuccess;

  /// No description provided for @awaitingSellerApproval.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار موافقة البائع'**
  String get awaitingSellerApproval;

  /// No description provided for @orderNumber.
  ///
  /// In ar, this message translates to:
  /// **'طلب #{arg0}'**
  String orderNumber(Object arg0);

  /// No description provided for @statusLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get statusLabel;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get backToHome;

  /// No description provided for @quantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية: {arg0}'**
  String quantityLabel(Object arg0);

  /// No description provided for @orderDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get orderDetails;

  /// No description provided for @sellerName.
  ///
  /// In ar, this message translates to:
  /// **'البائع: {arg0}'**
  String sellerName(Object arg0);

  /// No description provided for @cashbackEarned.
  ///
  /// In ar, this message translates to:
  /// **'كاش باك مكتسب: {arg0}'**
  String cashbackEarned(Object arg0);

  /// No description provided for @cashbackRedeemed.
  ///
  /// In ar, this message translates to:
  /// **'كاش باك مستخدم: {arg0}'**
  String cashbackRedeemed(Object arg0);

  /// No description provided for @statusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get statusPending;

  /// No description provided for @statusProcessing.
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get statusProcessing;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusCompleted;

  /// No description provided for @statusPartialRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض جزئياً'**
  String get statusPartialRejected;

  /// No description provided for @orderSummary.
  ///
  /// In ar, this message translates to:
  /// **'{arg0} منتجات - {arg1}'**
  String orderSummary(Object arg0, Object arg1);

  /// No description provided for @orderItemSummary.
  ///
  /// In ar, this message translates to:
  /// **'{arg0} × {arg1}'**
  String orderItemSummary(Object arg0, Object arg1);

  /// No description provided for @orderTotalSar.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي: {arg0} ر.س'**
  String orderTotalSar(Object arg0);

  /// No description provided for @pointsLoyaltyLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات الولاء من الخادم'**
  String get pointsLoyaltyLoadError;

  /// No description provided for @pointsSystemTitle.
  ///
  /// In ar, this message translates to:
  /// **'نظام PP Coins'**
  String get pointsSystemTitle;

  /// No description provided for @pointsSystemSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكسب نقاطاً واستبدلها بجوائز حصرية'**
  String get pointsSystemSubtitle;

  /// No description provided for @currentBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك الحالي'**
  String get currentBalance;

  /// No description provided for @pointsAmount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نقطة'**
  String pointsAmount(Object count);

  /// No description provided for @pointsTabLabel.
  ///
  /// In ar, this message translates to:
  /// **'🪙  النقاط'**
  String get pointsTabLabel;

  /// No description provided for @rewardsTabLabel.
  ///
  /// In ar, this message translates to:
  /// **'🎁  الجوائز'**
  String get rewardsTabLabel;

  /// No description provided for @totalPoints.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي النقاط'**
  String get totalPoints;

  /// No description provided for @loyaltyPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط الولاء'**
  String get loyaltyPoints;

  /// No description provided for @packagePoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط الباقة'**
  String get packagePoints;

  /// No description provided for @pointsLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل النقاط'**
  String get pointsLog;

  /// No description provided for @noPointTransactions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات نقاط بعد'**
  String get noPointTransactions;

  /// No description provided for @viewAllTransactions.
  ///
  /// In ar, this message translates to:
  /// **'عرض كل المعاملات'**
  String get viewAllTransactions;

  /// No description provided for @howEarnPoints.
  ///
  /// In ar, this message translates to:
  /// **'كيف تكسب نقاطاً؟'**
  String get howEarnPoints;

  /// No description provided for @pointsValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة النقاط'**
  String get pointsValue;

  /// No description provided for @pointsExpiryNote.
  ///
  /// In ar, this message translates to:
  /// **'النقاط صالحة لمدة سنة من تاريخ الكسب. تُضاف تلقائياً بعد إتمام كل عملية.'**
  String get pointsExpiryNote;

  /// No description provided for @earnCompleteSalePurchase.
  ///
  /// In ar, this message translates to:
  /// **'إتمام بيع أو شراء'**
  String get earnCompleteSalePurchase;

  /// No description provided for @earnCompleteSalePurchaseSub.
  ///
  /// In ar, this message translates to:
  /// **'لكل صفقة مكتملة'**
  String get earnCompleteSalePurchaseSub;

  /// No description provided for @earnPayOnTime.
  ///
  /// In ar, this message translates to:
  /// **'سداد في الوقت المحدد'**
  String get earnPayOnTime;

  /// No description provided for @earnPayOnTimeSub.
  ///
  /// In ar, this message translates to:
  /// **'خلال مهلة الدفع'**
  String get earnPayOnTimeSub;

  /// No description provided for @earnFiveStarRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييم 5 نجوم'**
  String get earnFiveStarRating;

  /// No description provided for @earnFiveStarRatingSub.
  ///
  /// In ar, this message translates to:
  /// **'من المشتري أو البائع'**
  String get earnFiveStarRatingSub;

  /// No description provided for @earnInviteFriend.
  ///
  /// In ar, this message translates to:
  /// **'دعوة صديق'**
  String get earnInviteFriend;

  /// No description provided for @earnInviteFriendSub.
  ///
  /// In ar, this message translates to:
  /// **'عند تسجيله وإتمام أول صفقة'**
  String get earnInviteFriendSub;

  /// No description provided for @earnAddDigitalId.
  ///
  /// In ar, this message translates to:
  /// **'إضافة هوية رقمية للطائر'**
  String get earnAddDigitalId;

  /// No description provided for @earnAddDigitalIdSub.
  ///
  /// In ar, this message translates to:
  /// **'أول مرة لكل طائر'**
  String get earnAddDigitalIdSub;

  /// No description provided for @earnShareAuction.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة مزاد'**
  String get earnShareAuction;

  /// No description provided for @earnShareAuctionSub.
  ///
  /// In ar, this message translates to:
  /// **'عبر واتساب أو تويتر'**
  String get earnShareAuctionSub;

  /// No description provided for @earnDailyLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول اليومي'**
  String get earnDailyLogin;

  /// No description provided for @earnDailyLoginSub.
  ///
  /// In ar, this message translates to:
  /// **'مرة واحدة يومياً'**
  String get earnDailyLoginSub;

  /// No description provided for @pointsValueDiscountPublish5.
  ///
  /// In ar, this message translates to:
  /// **'خصم 5 ريال على رسوم النشر'**
  String get pointsValueDiscountPublish5;

  /// No description provided for @pointsValueDiscountDeal10.
  ///
  /// In ar, this message translates to:
  /// **'خصم 10 ريال على أي صفقة'**
  String get pointsValueDiscountDeal10;

  /// No description provided for @pointsValueFreeWeek.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك مجاني لمدة أسبوع'**
  String get pointsValueFreeWeek;

  /// No description provided for @pointsValueAdUpgrade2.
  ///
  /// In ar, this message translates to:
  /// **'ترقية إعلان مجانية × 2'**
  String get pointsValueAdUpgrade2;

  /// No description provided for @pointsValueTrustedSellerBadge.
  ///
  /// In ar, this message translates to:
  /// **'شارة \"بائع موثوق\" لمدة شهر'**
  String get pointsValueTrustedSellerBadge;

  /// No description provided for @pointsValueFreeMonth.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك مجاني لمدة شهر كامل'**
  String get pointsValueFreeMonth;

  /// No description provided for @pointsValueHomepageFeaturedAd.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مميز على الصفحة الرئيسية'**
  String get pointsValueHomepageFeaturedAd;

  /// No description provided for @pointsValueVipThreeMonths.
  ///
  /// In ar, this message translates to:
  /// **'عضوية VIP لمدة 3 أشهر'**
  String get pointsValueVipThreeMonths;

  /// No description provided for @myBadgesSection.
  ///
  /// In ar, this message translates to:
  /// **'شاراتي'**
  String get myBadgesSection;

  /// No description provided for @noEarnedBadges.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد شارات مكتسبة بعد'**
  String get noEarnedBadges;

  /// No description provided for @availableBadges.
  ///
  /// In ar, this message translates to:
  /// **'الشارات المتاحة'**
  String get availableBadges;

  /// No description provided for @howGetReward.
  ///
  /// In ar, this message translates to:
  /// **'كيف تحصل على جائزة؟'**
  String get howGetReward;

  /// No description provided for @membershipLevels.
  ///
  /// In ar, this message translates to:
  /// **'مستويات العضوية'**
  String get membershipLevels;

  /// No description provided for @rewardAuctionFeeDiscount.
  ///
  /// In ar, this message translates to:
  /// **'تخفيض على رسوم المزاد'**
  String get rewardAuctionFeeDiscount;

  /// No description provided for @rewardAuctionFeeDiscountSub.
  ///
  /// In ar, this message translates to:
  /// **'خصم 10% على رسوم نشر أي مزاد'**
  String get rewardAuctionFeeDiscountSub;

  /// No description provided for @rewardDiscountsCategory.
  ///
  /// In ar, this message translates to:
  /// **'خصومات'**
  String get rewardDiscountsCategory;

  /// No description provided for @rewardFreeWeeklySubscription.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك أسبوعي مجاني'**
  String get rewardFreeWeeklySubscription;

  /// No description provided for @rewardFreeWeeklySubscriptionSub.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك في باقة البائع الأساسية لمدة 7 أيام'**
  String get rewardFreeWeeklySubscriptionSub;

  /// No description provided for @rewardSubscriptionsCategory.
  ///
  /// In ar, this message translates to:
  /// **'اشتراكات'**
  String get rewardSubscriptionsCategory;

  /// No description provided for @rewardAdUpgrade.
  ///
  /// In ar, this message translates to:
  /// **'ترقية إعلان'**
  String get rewardAdUpgrade;

  /// No description provided for @rewardAdUpgradeSub.
  ///
  /// In ar, this message translates to:
  /// **'ظهور إعلانك في أعلى نتائج البحث لمدة 3 أيام'**
  String get rewardAdUpgradeSub;

  /// No description provided for @rewardPromotionCategory.
  ///
  /// In ar, this message translates to:
  /// **'ترويج'**
  String get rewardPromotionCategory;

  /// No description provided for @rewardTrustedSellerBadge.
  ///
  /// In ar, this message translates to:
  /// **'شارة البائع الموثوق'**
  String get rewardTrustedSellerBadge;

  /// No description provided for @rewardTrustedSellerBadgeSub.
  ///
  /// In ar, this message translates to:
  /// **'شارة زرقاء تظهر بجانب اسمك لمدة شهر'**
  String get rewardTrustedSellerBadgeSub;

  /// No description provided for @rewardFeaturesCategory.
  ///
  /// In ar, this message translates to:
  /// **'مميزات'**
  String get rewardFeaturesCategory;

  /// No description provided for @rewardFreeMonthlySubscription.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك شهري مجاني'**
  String get rewardFreeMonthlySubscription;

  /// No description provided for @rewardFreeMonthlySubscriptionSub.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك في باقة البائع الاحترافية لمدة شهر'**
  String get rewardFreeMonthlySubscriptionSub;

  /// No description provided for @rewardFeaturedHomepageAd.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مميز - الصفحة الرئيسية'**
  String get rewardFeaturedHomepageAd;

  /// No description provided for @rewardFeaturedHomepageAdSub.
  ///
  /// In ar, this message translates to:
  /// **'ظهور مزادك في بانر الصفحة الرئيسية لمدة يوم'**
  String get rewardFeaturedHomepageAdSub;

  /// No description provided for @rewardVipMembership.
  ///
  /// In ar, this message translates to:
  /// **'عضوية VIP'**
  String get rewardVipMembership;

  /// No description provided for @rewardVipMembershipSub.
  ///
  /// In ar, this message translates to:
  /// **'جميع المزايا + دعم أولوية + خصم دائم 15%'**
  String get rewardVipMembershipSub;

  /// No description provided for @redeem.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get redeem;

  /// No description provided for @howRedeemEarnPoints.
  ///
  /// In ar, this message translates to:
  /// **'اكسب نقاطاً من خلال إتمام الصفقات والأنشطة اليومية'**
  String get howRedeemEarnPoints;

  /// No description provided for @howRedeemChooseReward.
  ///
  /// In ar, this message translates to:
  /// **'اختر الجائزة التي تريدها من الكتالوج أدناه'**
  String get howRedeemChooseReward;

  /// No description provided for @howRedeemTapRedeem.
  ///
  /// In ar, this message translates to:
  /// **'اضغط \"استبدال\" وسيتم خصم النقاط وتفعيل الجائزة فوراً'**
  String get howRedeemTapRedeem;

  /// No description provided for @howRedeemRewardAppears.
  ///
  /// In ar, this message translates to:
  /// **'تظهر الجائزة تلقائياً في حسابك خلال دقائق'**
  String get howRedeemRewardAppears;

  /// No description provided for @tierBronze.
  ///
  /// In ar, this message translates to:
  /// **'برونزي'**
  String get tierBronze;

  /// No description provided for @tierBronzeRange.
  ///
  /// In ar, this message translates to:
  /// **'0 – 499 نقطة'**
  String get tierBronzeRange;

  /// No description provided for @tierSilver.
  ///
  /// In ar, this message translates to:
  /// **'فضي'**
  String get tierSilver;

  /// No description provided for @tierSilverRange.
  ///
  /// In ar, this message translates to:
  /// **'500 – 1,999 نقطة'**
  String get tierSilverRange;

  /// No description provided for @tierGold.
  ///
  /// In ar, this message translates to:
  /// **'ذهبي'**
  String get tierGold;

  /// No description provided for @tierGoldRange.
  ///
  /// In ar, this message translates to:
  /// **'2,000 – 4,999 نقطة'**
  String get tierGoldRange;

  /// No description provided for @tierVipRange.
  ///
  /// In ar, this message translates to:
  /// **'5,000+ نقطة'**
  String get tierVipRange;

  /// No description provided for @convertCashbackToPoints.
  ///
  /// In ar, this message translates to:
  /// **'حوّل كاش باك إلى نقاط PP'**
  String get convertCashbackToPoints;

  /// No description provided for @cashbackConversionRate.
  ///
  /// In ar, this message translates to:
  /// **'كل 1 كاش باك = 20 نقطة PP'**
  String get cashbackConversionRate;

  /// No description provided for @cashbackConversionSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم! حصلت على {count} نقطة PP'**
  String cashbackConversionSuccess(Object count);

  /// No description provided for @tryAgainError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، حاول مرة أخرى'**
  String get tryAgainError;

  /// No description provided for @cashbackBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'رصيد الكاش باك:'**
  String get cashbackBalanceLabel;

  /// No description provided for @cashbackAmountHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المبلغ (كاش باك)'**
  String get cashbackAmountHint;

  /// No description provided for @convertNow.
  ///
  /// In ar, this message translates to:
  /// **'تحويل الآن'**
  String get convertNow;

  /// No description provided for @pointsTransactionFallback.
  ///
  /// In ar, this message translates to:
  /// **'معاملة نقاط'**
  String get pointsTransactionFallback;

  /// No description provided for @balanceAfterTransaction.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد بعد العملية: {balance}'**
  String balanceAfterTransaction(Object balance);

  /// No description provided for @revoked.
  ///
  /// In ar, this message translates to:
  /// **'مُلغى'**
  String get revoked;

  /// No description provided for @thresholdLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحد: {value}'**
  String thresholdLabel(Object value);

  /// No description provided for @earnedBadge.
  ///
  /// In ar, this message translates to:
  /// **'مكتسبة ✓'**
  String get earnedBadge;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاحة'**
  String get available;
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
