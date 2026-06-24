// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pigeon Planet';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get country => 'Country';

  @override
  String get city => 'City';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get home => 'Home';

  @override
  String get auctions => 'Auctions';

  @override
  String get market => 'Market';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get digitalId => 'Digital ID';

  @override
  String get ringNumber => 'Ring Number';

  @override
  String get breed => 'Breed';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get hatchDate => 'Hatch Date';

  @override
  String get raceResults => 'Race Results';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get recordVideo => 'Record Video';

  @override
  String get preview => 'Preview';

  @override
  String get publish => 'Publish';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get verifyOtp => 'Verify Code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get next => 'Next';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get search => 'Search';

  @override
  String get categories => 'Categories';

  @override
  String get products => 'Products';

  @override
  String get activeAuctions => 'Active Auctions';

  @override
  String get sellerDashboard => 'Seller Dashboard';

  @override
  String get buyerMode => 'Buyer';

  @override
  String get sellerMode => 'Service Provider';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get retry => 'Retry';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get send => 'Send';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get all => 'All';

  @override
  String get total => 'Total';

  @override
  String get viewDetails => 'View Details';

  @override
  String get change => 'Change';

  @override
  String get description => 'Description';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get share => 'Share';

  @override
  String get follow => 'Follow';

  @override
  String get followed => 'Following';

  @override
  String get newAuction => 'New Auction';

  @override
  String get myAuctions => 'My Auctions';

  @override
  String get endingSoon => 'Ending Soon';

  @override
  String get searchAuctionHint => 'Search for an auction...';

  @override
  String get noAuctions => 'No auctions found';

  @override
  String get auctionCreatedSuccess => 'Auction created successfully';

  @override
  String get addBirdLabel => 'Add Bird';

  @override
  String get noBirdsAdded => 'No birds added yet';

  @override
  String get addBirdBtn => '+ Add Bird';

  @override
  String birdNumber(int number) {
    return 'Bird $number';
  }

  @override
  String get pairedBird => 'Paired Bird';

  @override
  String get addPairedBird => '+ Add Paired Bird';

  @override
  String get startingPriceField => 'Starting Price *';

  @override
  String get startTimeField => 'Start Time *';

  @override
  String get endTimeField => 'End Time *';

  @override
  String get chooseCoverImage => 'Choose a cover image for the auction';

  @override
  String get cancelAuctionTitle => 'Cancel Auction';

  @override
  String get cancelAuctionConfirm =>
      'Are you sure you want to cancel this auction? This action cannot be undone.';

  @override
  String get auctionCancelledSuccess => 'Auction cancelled';

  @override
  String get auctionUpdatedSuccess => 'Auction updated successfully';

  @override
  String get editAuction => 'Edit Auction';

  @override
  String get auctionDescriptionLabel => 'Auction Description';

  @override
  String get startingPriceLabel => 'Starting Price';

  @override
  String get currentPrice => 'Current Price';

  @override
  String get details => 'Details';

  @override
  String get auctionDetails => 'Auction Details';

  @override
  String get buyNowDialogTitle => 'Buy Now';

  @override
  String buyNowConfirm(String price) {
    return 'Do you want to buy this bird now for $price EGP?';
  }

  @override
  String get sendPaymentRequestBtn => 'Send Payment Request';

  @override
  String get sendPaymentRequestTitle => 'Send Payment Request';

  @override
  String amountLabel(String amount) {
    return 'Amount: $amount EGP';
  }

  @override
  String get bidSuccessful => 'Bid placed successfully';

  @override
  String get bidNowBtn => 'Bid Now';

  @override
  String get placeBidTitle => 'Place a Bid';

  @override
  String get bidCount => 'Bid Count';

  @override
  String get limitedOffer => 'Limited Offer';

  @override
  String get limitedOfferRareOpportunity => 'Limited Offer - Rare Opportunity';

  @override
  String get ownTodaysChampionWinTomorrow =>
      'Own today\'s champion - achieve tomorrow\'s victories';

  @override
  String get tapToWatchVideo => 'Tap to watch video';

  @override
  String get officialAnnouncement => 'Official Announcement';

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get chatDisabled => 'Chat is currently disabled';

  @override
  String get breeder => 'Breeder';

  @override
  String get interestedInquiries => 'Interested Inquiries';

  @override
  String get beFirstToInquire => 'Be the first to inquire!';

  @override
  String get buyNowBeforeItsTooLate => 'Buy now before it\'s too late!';

  @override
  String get specialPrice => 'Special Price';

  @override
  String get freeDelivery => 'Free delivery to all governorates 🚚';

  @override
  String get cashOnDelivery => 'Cash on delivery available 💳';

  @override
  String get buyerReviews => 'Buyer Reviews';

  @override
  String get sponsored => 'Sponsored';

  @override
  String get deleteBirdTitle => 'Delete Bird';

  @override
  String get deleteBirdConfirm =>
      'Are you sure you want to delete this bird? This cannot be undone.';

  @override
  String get birdDeletedSuccess => 'Bird deleted successfully';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get noteForSellerLabel => 'Note for seller (optional)';

  @override
  String get pleaseEnterAuctionTitle => 'Please enter the auction title';

  @override
  String get pleaseSelectStartTime => 'Please select the start time';

  @override
  String get startTimeMustBeFuture => 'Start time must be in the future';

  @override
  String get pleaseSelectEndTime => 'Please select the end time';

  @override
  String get endTimeAfterStartTime => 'End time must be after start time';

  @override
  String get pleaseEnterValidMinBid => 'Please enter a valid minimum bid';

  @override
  String get pleaseAddAtLeastOneBird => 'Please add at least one bird';

  @override
  String get disableChat => 'Disable Chat';

  @override
  String get enableChat => 'Enable Chat';

  @override
  String get auctionChatTooltip => 'Auction Chat';

  @override
  String get sellerBlockedSuccess => 'Seller blocked';

  @override
  String get sellerUnblockedSuccess => 'Seller unblocked';

  @override
  String get mustFollowFirst =>
      'You must follow the seller first to contact them';

  @override
  String get notifyWhenAvailable => 'Notify me when available';

  @override
  String get expectedPrice => 'Expected Price';

  @override
  String get myConversations => 'My Conversations';

  @override
  String get switchProfile => 'Switch Profile';

  @override
  String get myPackage => 'My Package';

  @override
  String get myBadges => 'My Badges';

  @override
  String get customerOrders => 'Customer Orders';

  @override
  String get paymentRequests => 'Payment Requests';

  @override
  String get shoppingCart => 'Shopping Cart';

  @override
  String get myOrders => 'My Orders';

  @override
  String get language => 'Language';

  @override
  String get myPrizes => 'My Prizes';

  @override
  String get challenges => 'Challenges';

  @override
  String get accountVerification => 'Account Verification';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get ownershipRecord => 'Ownership Record';

  @override
  String get ownershipRecordDesc => 'Protected and tamper-proof system';

  @override
  String get rewardsProgram => 'Rewards Program';

  @override
  String get inviteFriendsEarn => 'Invite friends and earn';

  @override
  String get inviteCode => 'Invite Code';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get notifyMe => 'Notify Me';

  @override
  String get pointsRedemptionComingSoon =>
      'Coming soon — redemption feature is under development';

  @override
  String get browseMarket => 'Browse Market';

  @override
  String get searchActiveAuctionsHint =>
      'Search by ring, breed, or description...';

  @override
  String get cartTitle => 'Shopping Cart';

  @override
  String get clearCartBtn => 'Clear';

  @override
  String get productCount => 'Product Count';

  @override
  String get checkoutError => 'An error occurred while processing your order';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get noOrdersCurrently => 'No orders currently';

  @override
  String get sendingPaymentRequest => 'Sending payment request...';

  @override
  String get activityLogTitle => 'Activity Log';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get profileDeletedSuccess => 'Profile deleted';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get conversationsTitle => 'Conversations';

  @override
  String get messageInputHint => 'Type your message...';

  @override
  String get notificationUpdateError => 'Could not update notification status';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get marketSearchHint => 'Search for category or product...';

  @override
  String get productSearchHint => 'Search products...';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get myAwards => 'My Awards';

  @override
  String get luckyWheelTitle => 'Lucky Wheel';

  @override
  String get availablePrizes => 'Available Prizes';

  @override
  String get myPerks => 'My Perks';

  @override
  String get noPerksAvailable => 'No perks available right now';

  @override
  String get spinWheelForPerks => 'Spin the lucky wheel to get perks';

  @override
  String get auctionIdHint => 'Enter Auction ID';

  @override
  String get messageIdHint => 'Enter Message ID';

  @override
  String get auctionIdLabel => 'Auction ID';

  @override
  String get messageIdLabel => 'Message ID';

  @override
  String activatePerks(String name) {
    return 'Activate $name';
  }

  @override
  String get pinMessage => 'Pin Message';

  @override
  String get pinMessageDesc =>
      'Enter the message ID you want to pin for one minute';

  @override
  String get pin => 'Pin';

  @override
  String get viewMyPerks => 'View and use my perks';

  @override
  String get paymentRequestSentSuccess => 'Payment request sent successfully';

  @override
  String get noPaymentRequests => 'No payment requests yet';

  @override
  String get operationSuccessful => 'Operation completed successfully';

  @override
  String get saveNote => 'Save Note';

  @override
  String get imageUploadError => 'Image upload failed, please try again';

  @override
  String get paymentProofSentSuccess => 'Payment proof sent successfully';

  @override
  String get addImageBtn => 'Add Image';

  @override
  String get sendProofBtn => 'Send Proof';

  @override
  String get rejectionNoteLabel => 'Rejection note (optional)';

  @override
  String get rejectionNoteHint => 'Reason for rejection if any...';

  @override
  String get noteForBuyerLabel => 'Your note to the seller';

  @override
  String get noteForBuyerHint => 'Add any comment or clarification...';

  @override
  String get complaintValidation =>
      'Please enter the complaint title and description';

  @override
  String get complaintSubmittedSuccess => 'Complaint submitted successfully';

  @override
  String get afterSaleComplaint => 'After Sale';

  @override
  String get rejectedPaymentComplaint => 'Rejected Payment';

  @override
  String get otherComplaint => 'Other';

  @override
  String get complaintCancelledSuccess => 'Complaint cancelled';

  @override
  String get cancelComplaintTitle => 'Cancel Complaint';

  @override
  String get cancelComplaintConfirm => 'Do you want to cancel this complaint?';

  @override
  String get complaintTitleLabel => 'Complaint Title';

  @override
  String get complaintTypeLabel => 'Complaint Type';

  @override
  String get complaintDescLabel => 'Problem Description';

  @override
  String get complaintDescHint => 'Describe what happened clearly...';

  @override
  String get enterRingNumber => 'Enter ring number';

  @override
  String get reviewSuccess => 'Reviewed successfully';

  @override
  String get pedigreeRingLabel => 'Bird Ring Number';

  @override
  String get pedigreeRingHint => 'e.g. EG-2024-12345';

  @override
  String get pedigreeDescHint =>
      'Additional description from the pedigree certificate';

  @override
  String get pdfFile => 'PDF File';

  @override
  String get ratingSubmittedSuccess => 'Submitted successfully';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get commentLabel => 'Comment';

  @override
  String get submitRatingBtn => 'Submit Rating';

  @override
  String get submitCommentBtn => 'Submit Comment';

  @override
  String get addCommentHint => 'Add a comment (optional)';

  @override
  String get writeYourComment => 'Write your comment here...';

  @override
  String get invalidQrCode =>
      'Invalid QR code — does not belong to a bird in Pigeon Planet';

  @override
  String get pigeonFormValidation =>
      'Please enter the ring number, breed, and achievements';

  @override
  String get birdDataUpdated => 'Bird data updated successfully';

  @override
  String get capturePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get requiredField => 'Required';

  @override
  String get noPhotos => 'No photos';

  @override
  String get printFeatureComingSoon => 'Print feature coming soon';

  @override
  String get printBtn => 'Print';

  @override
  String get shareFeatureComingSoon => 'Share feature coming soon';

  @override
  String get publishPigeon => 'Publish Pigeon';

  @override
  String get publishLinkComingSoon => 'Publish link coming in next step';

  @override
  String get viewPedigreeCertificate => 'View Pedigree Certificate';

  @override
  String get processingLabel => 'Processing...';

  @override
  String get reprocessBtn => 'Reprocess';

  @override
  String get otpNewCodeSent => 'New code sent';

  @override
  String get automatic => 'Automatic';

  @override
  String get useBtn => 'Use';

  @override
  String get later => 'Later';

  @override
  String get auctionTitleLabel => 'Auction Title';

  @override
  String get auctionTitleRequired => 'Title is required';

  @override
  String get auctionTitleHint => 'Enter auction title';

  @override
  String get auctionDescHint => 'Enter auction description';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint => 'e.g. pigeon, racing, rare';

  @override
  String get auctionEditNote =>
      'Only title, description, and tags can be edited. Prices and birds cannot be changed after the auction is created.';

  @override
  String get myBids => 'My Bids';

  @override
  String get noBidsYet => 'No bids yet';

  @override
  String get winningBid => 'Winning Bid';

  @override
  String get bidders => 'Bidders';

  @override
  String get unknown => 'Unknown';

  @override
  String get highestBid => 'Highest Bid';

  @override
  String get now => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get managePedigreeCertificate => 'Manage Pedigree Certificate';

  @override
  String get verifiedPedigree => 'Verified Pedigree';

  @override
  String get healthGuarantee => 'Health Guarantee';

  @override
  String get racesAndResults => 'Races & Results';

  @override
  String get races => 'Races';

  @override
  String get searchResults => 'Search Results';

  @override
  String get racesSearchHint => 'Search races...';

  @override
  String get noRacesYet => 'No races yet';

  @override
  String get noResults => 'No results';

  @override
  String get noMatchingResults => 'No matching results';

  @override
  String get season => 'Season';

  @override
  String get station => 'Station';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get clear => 'Clear';

  @override
  String get raceSearchHint => 'Ring number or racer name...';

  @override
  String get raceSearchDesc => 'Search by pigeon ring number or racer name';

  @override
  String get bird => 'Bird';

  @override
  String get racer => 'Racer';

  @override
  String ringLabel(String ring) {
    return 'Ring: $ring';
  }

  @override
  String get loadMore => 'Load More';

  @override
  String get uploadSizeHint => 'PNG, JPG up to 10MB';

  @override
  String get serviceProviderSubtitle => 'For companies and suppliers';

  @override
  String get mustAgreeToTerms => 'You must agree to the terms and conditions';

  @override
  String get registerSuccess => 'Account created successfully';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'Enter username (no spaces)';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPasswordHint => 'Enter your password again';

  @override
  String get personalAccount => 'Personal Account';

  @override
  String get personalAccountSub => 'For breeders and buyers';

  @override
  String get phoneHint => '+20 1xx xxx xxxx';

  @override
  String get age => 'Age';

  @override
  String get location => 'Location';

  @override
  String get flyingSpeed => 'Speed';

  @override
  String get kmPerHour => 'km/h';

  @override
  String get stamina => 'Stamina';

  @override
  String get achievements => 'Achievements';

  @override
  String get staminaExcellent => 'Excellent';

  @override
  String get staminaVeryGood => 'Very Good';

  @override
  String get staminaGood => 'Good';

  @override
  String get genderYoung => 'Young';

  @override
  String get auctionEnded => 'Ended';

  @override
  String priceEgpFormat(String amount) {
    return 'EGP $amount';
  }

  @override
  String get unspecified => 'Unspecified';

  @override
  String get lessThanAYear => 'Less than a year';

  @override
  String get notAvailable => 'Not available';

  @override
  String get noDescription => 'No description.';

  @override
  String get pigeonDetails => 'Pigeon Details';

  @override
  String savingsAmount(String amount) {
    return 'Save $amount EGP';
  }

  @override
  String discountPercent(Object percent) {
    return 'Discount $percent%';
  }

  @override
  String liveViewersCount(Object count) {
    return '$count people watching now';
  }

  @override
  String todayRequestsCount(Object count) {
    return '$count requests today';
  }

  @override
  String get thisBirdIsYours => 'This bird is yours';

  @override
  String get buyNowLimitedOffer => '🛒 Buy Now - Limited Time Offer!';

  @override
  String get dnaRegistered => 'DNA Registered';

  @override
  String get birdPhoto => 'Bird Photo';

  @override
  String get birdWing => 'Wing';

  @override
  String get birdEye => 'Eye';

  @override
  String get ringNumberThumbnail => 'Ring No.';

  @override
  String photoNumber(int number) {
    return 'Photo $number';
  }

  @override
  String get birdVideo => 'Bird Video';

  @override
  String get zeroViews => '0 Views';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String viewAllReviews(int count) {
    return 'View all reviews ($count)';
  }

  @override
  String get emptyCartTitle => 'Your cart is empty';

  @override
  String get emptyCartSubtitle =>
      'Browse the market and add products to your cart';

  @override
  String get completeOrder => 'Complete Order';

  @override
  String get birdsInThisAuction => 'Birds in this auction';

  @override
  String daysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String hoursRemaining(int count) {
    return '$count hours remaining';
  }

  @override
  String minutesRemaining(int count) {
    return '$count minutes remaining';
  }

  @override
  String get statusActive => 'Active';

  @override
  String get statusEnded => 'Ended';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusSold => 'Sold';

  @override
  String get statusUnsold => 'Unsold';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String minBidLabel(String amount) {
    return 'Minimum: $amount EGP';
  }

  @override
  String birdCount(int count) {
    return '$count birds';
  }

  @override
  String bidCountLabel(int count) {
    return '$count bids';
  }

  @override
  String get byProceedingYouAgree => 'By proceeding, you agree to ';

  @override
  String get andConnector => ' and ';

  @override
  String auctionBidAmountEgp(String amount) {
    return '$amount EGP';
  }

  @override
  String get viewAllReviewsText => 'View all reviews';

  @override
  String get blockSeller => 'Block seller';

  @override
  String get unblockSeller => 'Unblock';

  @override
  String get followingNow => 'Following now';

  @override
  String get contactSeller => 'Contact seller';

  @override
  String get followSellerToContact => 'Follow this seller to contact them';

  @override
  String get aboutBreeder => 'About the breeder';

  @override
  String get noAdditionalInfo => 'No additional information';

  @override
  String get breederAuctions => 'Breeder auctions';

  @override
  String get reviews => 'Reviews';

  @override
  String get averageRating => 'Average rating';

  @override
  String get activeAuction => 'Active auction';

  @override
  String get outOfFive => 'out of 5';

  @override
  String get whatDoYouWantToAdd => 'What do you want to add?';

  @override
  String get addAuctionBirds => 'Add birds to auction';

  @override
  String get startAuctionForBirds => 'Start an auction for your racing pigeons';

  @override
  String get addFixedPriceBirds => 'Add fixed-price birds';

  @override
  String get directSaleFixedPrice => 'Direct sale with a preset price';

  @override
  String get addProducts => 'Add products';

  @override
  String get productsSubtitle => 'Medicine, supplements, supplies and more';

  @override
  String get manageSubscriptions => 'Manage my subscriptions';

  @override
  String get subscribeToCreateAuctions =>
      'Subscribe to a package to create auctions';

  @override
  String get dataLoadError => 'Failed to load data';

  @override
  String get discoverAuctionsAndBreeders =>
      'Discover the latest auctions and breeders';

  @override
  String get bestSeller => 'Best seller';

  @override
  String get browseProducts => 'Browse products';

  @override
  String get free => 'Free';

  @override
  String get homeDelivery => 'Home delivery';

  @override
  String get availableProduct => 'Available product';

  @override
  String get allProductsHighQuality => 'All products are high quality';

  @override
  String get certifiedOriginalProducts =>
      'Certified original products for your pigeons\' health';

  @override
  String get activeOffers => 'Active offers';

  @override
  String get suggestedForYou => 'Suggested for you';

  @override
  String get more => 'More';

  @override
  String get followedAlt => 'Followed';

  @override
  String get noProducts => 'No products';

  @override
  String get newest => 'Newest';

  @override
  String get priceLowToHigh => 'Price: low to high';

  @override
  String get priceHighToLow => 'Price: high to low';

  @override
  String get sort => 'Sort';

  @override
  String get benefits => 'Benefits';

  @override
  String get myInsights => 'My Insights';

  @override
  String get insightsLoadError => 'Failed to load insights';

  @override
  String get closedAuctions => 'Closed auctions';

  @override
  String get totalOffersReceived => 'Total offers received';

  @override
  String get uniqueBidders => 'Unique bidders';

  @override
  String get completedSales => 'Completed sales';

  @override
  String get pendingPaymentRequests => 'Pending payment requests';

  @override
  String get listedProducts => 'Listed products';

  @override
  String get pendingOrders => 'Pending orders';

  @override
  String get lowStock => 'Low stock';

  @override
  String get engagement => 'Engagement';

  @override
  String get totalFollowers => 'Total followers';

  @override
  String get newFollowers7Days => 'New followers (7 days)';

  @override
  String get activeConversations => 'Active conversations';

  @override
  String get unreadMessages => 'Unread messages';

  @override
  String get profileViews7Days => 'Profile views (7 days)';

  @override
  String get auctionViews7Days => 'Auction views (7 days)';

  @override
  String get marketViews7Days => 'Market views (7 days)';

  @override
  String get trust => 'Trust';

  @override
  String get ratingsCount => 'Ratings count';

  @override
  String get newReviews7Days => 'New reviews (7 days)';

  @override
  String get badges => 'Badges';

  @override
  String get package => 'Package';

  @override
  String get currentPackage => 'Current package';

  @override
  String get packageNumber => 'Package number';

  @override
  String get subscriptionStatus => 'Subscription status';

  @override
  String get inactive => 'Inactive';

  @override
  String get remainingAuctionQuota => 'Remaining auction quota';

  @override
  String get remainingMarketQuota => 'Remaining market quota';

  @override
  String get remainingPackagePoints => 'Remaining package points';

  @override
  String get promotedAuctions => 'Promoted auctions';

  @override
  String get promotedProducts => 'Promoted products';

  @override
  String get packageExpiryDate => 'Package expiry date';

  @override
  String get activeOnly => 'Active only';

  @override
  String get previous => 'Previous';

  @override
  String get badgesLoadError => 'Failed to load badges';

  @override
  String get noBadgesYet => 'No badges yet';

  @override
  String get completeDealsForBadges =>
      'Complete deals and interact with the platform to earn badges';

  @override
  String get expired => 'Expired';

  @override
  String get enterValidPrice => 'Please enter a valid price';

  @override
  String get viewPackages => 'View Packages';

  @override
  String get createNewAuction => 'Create New Auction';

  @override
  String get auctionData => 'Auction Data';

  @override
  String get auctionTitleFieldLabel => 'Auction Title *';

  @override
  String get auctionTitleExample => 'Example: premium racing pigeon';

  @override
  String get auctionDescBriefHint => 'Write a brief auction description';

  @override
  String get auctionImage => 'Auction Image';

  @override
  String get auctionTypeField => 'Auction Type';

  @override
  String get chooseStartDateTime => 'Choose start date and time';

  @override
  String get chooseEndDateTime => 'Choose end date and time';

  @override
  String get minBidField => 'Minimum Bid';

  @override
  String get tagsFieldLabel => 'Tags';

  @override
  String get auctionSettings => 'Auction Settings';

  @override
  String get autoExtend => 'Auto Extend';

  @override
  String get autoExtendDesc =>
      'Automatically extend when bids arrive near the end';

  @override
  String get extensionDuration => 'Extension Duration';

  @override
  String get buyNowDesc => 'Allow buy now';

  @override
  String get buyNowPriceField => 'Buy Now Price';

  @override
  String get depositRequired => 'Deposit Required';

  @override
  String get depositRequiredDesc => 'Require a deposit to confirm bids';

  @override
  String get paymentDeadlineDays => 'Payment Deadline Days';

  @override
  String birdsCount(Object arg0) {
    return 'Birds: $arg0';
  }

  @override
  String get createAuction => 'Create Auction';

  @override
  String get nextArrow => 'Next →';

  @override
  String get settings => 'Settings';

  @override
  String get birds => 'Birds';

  @override
  String get chick => 'Chick';

  @override
  String buyNowConfirmMessage(Object arg0) {
    return 'Do you want to buy now for $arg0 EGP?';
  }

  @override
  String amountDisplay(Object arg0) {
    return 'Amount: $arg0 EGP';
  }

  @override
  String get viewPaymentDetails => 'View Payment Details';

  @override
  String minBidDisplay(Object arg0) {
    return 'Minimum bid: $arg0 EGP';
  }

  @override
  String get yourAuctionCannotBid => 'You cannot bid on your own auction';

  @override
  String get auctionNotStartedYet => 'Auction has not started yet';

  @override
  String wonAuction(Object arg0) {
    return 'You won auction #$arg0';
  }

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String minBidValidation(Object arg0) {
    return 'Bid must be at least $arg0';
  }

  @override
  String get minimumLabel => 'Minimum';

  @override
  String get orderConfirmationTitle => 'Order Confirmation';

  @override
  String get orderSentSuccess => 'Order sent successfully';

  @override
  String get awaitingSellerApproval => 'Awaiting seller approval';

  @override
  String orderNumber(Object arg0) {
    return 'Order #$arg0';
  }

  @override
  String get statusLabel => 'Status';

  @override
  String get backToHome => 'Back to Home';

  @override
  String quantityLabel(Object arg0) {
    return 'Quantity: $arg0';
  }

  @override
  String get orderDetails => 'Order Details';

  @override
  String sellerName(Object arg0) {
    return 'Seller: $arg0';
  }

  @override
  String cashbackEarned(Object arg0) {
    return 'Cashback earned: $arg0';
  }

  @override
  String cashbackRedeemed(Object arg0) {
    return 'Cashback redeemed: $arg0';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPartialRejected => 'Partially rejected';

  @override
  String orderSummary(Object arg0, Object arg1) {
    return '$arg0 items - $arg1';
  }

  @override
  String orderItemSummary(Object arg0, Object arg1) {
    return '$arg0 × $arg1';
  }

  @override
  String orderTotalSar(Object arg0) {
    return 'Total: $arg0 SAR';
  }

  @override
  String get pointsLoyaltyLoadError =>
      'Could not load loyalty data from the server';

  @override
  String get pointsSystemTitle => 'PP Coins System';

  @override
  String get pointsSystemSubtitle =>
      'Earn points and redeem them for exclusive rewards';

  @override
  String get currentBalance => 'Current balance';

  @override
  String pointsAmount(Object count) {
    return '$count points';
  }

  @override
  String get pointsTabLabel => '🪙  Points';

  @override
  String get rewardsTabLabel => '🎁  Rewards';

  @override
  String get totalPoints => 'Total points';

  @override
  String get loyaltyPoints => 'Loyalty points';

  @override
  String get packagePoints => 'Package points';

  @override
  String get pointsLog => 'Points log';

  @override
  String get noPointTransactions => 'No point transactions yet';

  @override
  String get viewAllTransactions => 'View all transactions';

  @override
  String get howEarnPoints => 'How do you earn points?';

  @override
  String get pointsValue => 'Points value';

  @override
  String get pointsExpiryNote =>
      'Points are valid for one year from the earning date. They are added automatically after each completed action.';

  @override
  String get earnCompleteSalePurchase => 'Complete a sale or purchase';

  @override
  String get earnCompleteSalePurchaseSub => 'For each completed deal';

  @override
  String get earnPayOnTime => 'Pay on time';

  @override
  String get earnPayOnTimeSub => 'Within the payment deadline';

  @override
  String get earnFiveStarRating => '5-star rating';

  @override
  String get earnFiveStarRatingSub => 'From the buyer or seller';

  @override
  String get earnInviteFriend => 'Invite a friend';

  @override
  String get earnInviteFriendSub =>
      'When they register and complete their first deal';

  @override
  String get earnAddDigitalId => 'Add a bird digital ID';

  @override
  String get earnAddDigitalIdSub => 'First time for each bird';

  @override
  String get earnShareAuction => 'Share an auction';

  @override
  String get earnShareAuctionSub => 'Via WhatsApp or Twitter';

  @override
  String get earnDailyLogin => 'Daily login';

  @override
  String get earnDailyLoginSub => 'Once per day';

  @override
  String get pointsValueDiscountPublish5 => '5 SAR discount on publishing fees';

  @override
  String get pointsValueDiscountDeal10 => '10 SAR discount on any deal';

  @override
  String get pointsValueFreeWeek => 'Free subscription for one week';

  @override
  String get pointsValueAdUpgrade2 => 'Free ad upgrade × 2';

  @override
  String get pointsValueTrustedSellerBadge =>
      '\"Trusted Seller\" badge for one month';

  @override
  String get pointsValueFreeMonth => 'Free subscription for a full month';

  @override
  String get pointsValueHomepageFeaturedAd => 'Featured ad on the home page';

  @override
  String get pointsValueVipThreeMonths => 'VIP membership for 3 months';

  @override
  String get myBadgesSection => 'My badges';

  @override
  String get noEarnedBadges => 'No earned badges yet';

  @override
  String get availableBadges => 'Available badges';

  @override
  String get howGetReward => 'How do you get a reward?';

  @override
  String get membershipLevels => 'Membership levels';

  @override
  String get rewardAuctionFeeDiscount => 'Auction fee discount';

  @override
  String get rewardAuctionFeeDiscountSub =>
      '10% discount on publishing any auction';

  @override
  String get rewardDiscountsCategory => 'Discounts';

  @override
  String get rewardFreeWeeklySubscription => 'Free weekly subscription';

  @override
  String get rewardFreeWeeklySubscriptionSub =>
      'Basic seller package subscription for 7 days';

  @override
  String get rewardSubscriptionsCategory => 'Subscriptions';

  @override
  String get rewardAdUpgrade => 'Ad upgrade';

  @override
  String get rewardAdUpgradeSub =>
      'Your ad appears at the top of search results for 3 days';

  @override
  String get rewardPromotionCategory => 'Promotion';

  @override
  String get rewardTrustedSellerBadge => 'Trusted seller badge';

  @override
  String get rewardTrustedSellerBadgeSub =>
      'A blue badge appears beside your name for one month';

  @override
  String get rewardFeaturesCategory => 'Features';

  @override
  String get rewardFreeMonthlySubscription => 'Free monthly subscription';

  @override
  String get rewardFreeMonthlySubscriptionSub =>
      'Professional seller package subscription for one month';

  @override
  String get rewardFeaturedHomepageAd => 'Featured ad - home page';

  @override
  String get rewardFeaturedHomepageAdSub =>
      'Your auction appears in the home page banner for one day';

  @override
  String get rewardVipMembership => 'VIP membership';

  @override
  String get rewardVipMembershipSub =>
      'All benefits + priority support + permanent 15% discount';

  @override
  String get redeem => 'Redeem';

  @override
  String get howRedeemEarnPoints =>
      'Earn points by completing deals and daily activities';

  @override
  String get howRedeemChooseReward =>
      'Choose the reward you want from the catalog below';

  @override
  String get howRedeemTapRedeem =>
      'Tap \"Redeem\" and points will be deducted and the reward activated immediately';

  @override
  String get howRedeemRewardAppears =>
      'The reward appears automatically in your account within minutes';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierBronzeRange => '0-499 points';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierSilverRange => '500-1,999 points';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierGoldRange => '2,000-4,999 points';

  @override
  String get tierVipRange => '5,000+ points';

  @override
  String get convertCashbackToPoints => 'Convert cashback to PP points';

  @override
  String get cashbackConversionRate => 'Each 1 cashback = 20 PP points';

  @override
  String cashbackConversionSuccess(Object count) {
    return 'Done! You earned $count PP points';
  }

  @override
  String get tryAgainError => 'An error occurred, please try again';

  @override
  String get cashbackBalanceLabel => 'Cashback balance:';

  @override
  String get cashbackAmountHint => 'Enter amount (cashback)';

  @override
  String get convertNow => 'Convert now';

  @override
  String get pointsTransactionFallback => 'Points transaction';

  @override
  String balanceAfterTransaction(Object balance) {
    return 'Balance after transaction: $balance';
  }

  @override
  String get revoked => 'Revoked';

  @override
  String thresholdLabel(Object value) {
    return 'Threshold: $value';
  }

  @override
  String get earnedBadge => 'Earned ✓';

  @override
  String get available => 'Available';
}
