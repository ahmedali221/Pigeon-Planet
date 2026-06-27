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
  String get customerPhone => 'Customer Phone';

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
  String get approvePaymentBtn => 'Approve Payment';

  @override
  String get orderAndProofSentSuccess =>
      'Payment proof submitted • Awaiting seller approval';

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
  String requiredField(Object label) {
    return '$label *';
  }

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
  String get clubRaces => 'Club Races';

  @override
  String get olrRaces => 'O.L.R Races';

  @override
  String get rankLabel => 'Rank';

  @override
  String get clubNameLabel => 'Club Name';

  @override
  String get competitorNameLabel => 'Competitor Name';

  @override
  String get birdRingLabel => 'Bird Ring';

  @override
  String get pointNameLabel => 'Point Name';

  @override
  String get hobbyistNameLabel => 'Hobbyist Name';

  @override
  String get filterSearchPrompt =>
      'Select filters and press Search to view results';

  @override
  String get requiredFieldsError =>
      'Please fill in the required fields: Country, Club, and Season';

  @override
  String get clearData => 'Clear Data';

  @override
  String get chooseSeason => 'Choose Season';

  @override
  String get speedUnit => 'm/s';

  @override
  String get distanceKmUnit => 'km';

  @override
  String get racePointsLabel => 'Points';

  @override
  String get totalBirdsLabel => 'Total Birds';

  @override
  String get resultLine1Label => 'Result 1';

  @override
  String get resultLine2Label => 'Result 2';

  @override
  String get baskLabel => 'Bask';

  @override
  String get seasonLabel => 'Season';

  @override
  String get arrivalDateTimeLabel => 'Arrival Date & Time';

  @override
  String get timeDifferenceLabel => 'Time Diff';

  @override
  String get arrivalsCountLabel => 'Arrivals';

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
  String get paymentProofSheetTitle => 'Payment Proof';

  @override
  String get paymentProofSheetSubtitle =>
      'Please attach your payment proof before completing the order';

  @override
  String get attachProofBtn => 'Attach Payment Proof';

  @override
  String get changeProofBtn => 'Change File';

  @override
  String get proofRequired => 'Payment proof is required to proceed';

  @override
  String get proofAttached => 'Payment proof attached';

  @override
  String get confirmAndCheckout => 'Confirm & Complete Order';

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
  String get statusClosed => 'Closed';

  @override
  String get auctionTypeSingle => 'Single Bird';

  @override
  String get auctionTypeMulti => 'Multi-Bird';

  @override
  String get auctionTypePair => 'Pair (Male + Female)';

  @override
  String get auctionTypeBreeding => 'Breeding Pair';

  @override
  String get auctionTypeRacing => 'Racing Group';

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
  String productsCount(int count) {
    return '$count products';
  }

  @override
  String get newest => 'Newest';

  @override
  String get priceLowToHigh => 'Price: low to high';

  @override
  String get priceHighToLow => 'Price: high to low';

  @override
  String get sort => 'Sort';

  @override
  String reviewsCount(int count) {
    return '($count reviews)';
  }

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
  String get statusApproved => 'Approved';

  @override
  String get orderItemRejected => 'Rejected by seller';

  @override
  String get paymentUnderReview => 'Payment under review';

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

  @override
  String get welcomeBackGeneric => 'Welcome back! 👋';

  @override
  String welcomeWithName(String name) {
    return 'Hello $name 👋';
  }

  @override
  String get noPackage => 'No package';

  @override
  String get viewAll => 'View All';

  @override
  String get activitySummary => 'Activity Summary';

  @override
  String get viewAllStats => 'View All Stats';

  @override
  String get myListedBirds => 'My Listed Birds';

  @override
  String get noAuctionsAddedYet => 'No auctions added yet';

  @override
  String get noBirdsAddedYet => 'No birds added yet';

  @override
  String endsInDays(int count) {
    return 'Ends in $count day(s)';
  }

  @override
  String endsInHours(int count) {
    return 'Ends in $count hour(s)';
  }

  @override
  String endsInMinutes(int count) {
    return 'Ends in $count minute(s)';
  }

  @override
  String get fixedPriceBirds => 'Fixed-Price Birds';

  @override
  String get kmUnit => 'km';

  @override
  String get platformFeatures => 'Platform Features';

  @override
  String get auctionSystem => 'Auction System';

  @override
  String get auctionSystemSub => 'Live and advanced bidding';

  @override
  String get ownershipRecordProtected => 'Protected & tamper-proof';

  @override
  String get marketSubtitle => 'Feed, medicine, supplies';

  @override
  String get pointsAndLoyalty => 'Points & Loyalty';

  @override
  String get pointsAndLoyaltySub => 'Earn with every transaction';

  @override
  String get referralCodeHint => 'Code: PIGEON123';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get sellerRole => 'Seller';

  @override
  String get buyerRole => 'Buyer';

  @override
  String get breedersYouMayKnow => 'Breeders You May Know';

  @override
  String get auctionCountUnit => 'auction';

  @override
  String get upcomingAuctions => 'Upcoming Auctions';

  @override
  String get auctionsComingSoonBanner => 'Auctions coming soon – stay ready!';

  @override
  String get countdownSecond => 'sec';

  @override
  String get countdownMinute => 'min';

  @override
  String get countdownHour => 'hr';

  @override
  String get countdownDay => 'day';

  @override
  String get providerFeatures => 'Provider Features';

  @override
  String get sellerActivationRequired =>
      'Note: Seller account activation is required before full publishing.';

  @override
  String get digitalIdVideoRequired =>
      'Note: Digital ID and video are mandatory before publishing any auction';

  @override
  String get addAuctionWithDigitalId => 'Add Auction with Digital ID';

  @override
  String get addAuctionWithDigitalIdSub =>
      'Link the bird to a verified digital ID';

  @override
  String get viewDigitalId => 'View Digital ID';

  @override
  String get viewDigitalIdSub => 'QR Code + Ring Number';

  @override
  String get mandatoryVideo => 'Mandatory Video';

  @override
  String get mandatoryVideoSub => '4 required stages';

  @override
  String get importantNotifications => 'Important Notifications';

  @override
  String newCountBadge(int count) {
    return '$count new';
  }

  @override
  String get noRecentNotifications => 'No recent notifications';

  @override
  String get newBadge => 'New';

  @override
  String get myBirds => 'My Birds';

  @override
  String get addProductToStore => 'Add Product to Store';

  @override
  String get followers => 'Followers';

  @override
  String get bidsLabel => 'Bids';

  @override
  String get myToolsAndFeatures => 'My Tools & Features';

  @override
  String get toolsPageSubtitle =>
      'Notifications · publishing requirements · advanced tools';

  @override
  String get sellerProviderTools => 'Provider Tools';

  @override
  String get multiRoomManagement => 'Multi-Room Management';

  @override
  String get newBadgeLabel => 'NEW';

  @override
  String get multiRoomDesc => 'Create and manage multiple auction rooms';

  @override
  String get threePackages => '3 packages';

  @override
  String get fullCustomization => 'Full customization';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get viewOwnershipRecord => 'View Ownership Record';

  @override
  String get ownershipRecordFull => 'Full record of all transfers';

  @override
  String get ownershipTransfer => 'Ownership Transfer';

  @override
  String get ownershipTransferStages =>
      '3 stages: payment ← delivery ← confirmation';

  @override
  String get recordProtectionLabel => 'Record protection:';

  @override
  String get tamperProof => 'Tamper-proof';

  @override
  String get visibleToSellerBuyerOnly => 'Visible only to seller and buyer';

  @override
  String get autoDeleteAfter7Days => 'Auto-deleted after 7 days';

  @override
  String get manualDeleteAfterMonth => 'Manual delete after 1 month (seller)';

  @override
  String get perInviteLabel => 'per invite';

  @override
  String get earningsLabel => 'Earnings';

  @override
  String get invitesLabel => 'Invites';

  @override
  String get scanBirdCardTooltip => 'Scan bird card';

  @override
  String get serviceProvider => 'Service Provider';

  @override
  String get statsPageTitle => 'Statistics';

  @override
  String get fullPerformanceDashboard => 'Full Performance Dashboard';

  @override
  String get miniKpiAuctions => 'auctions';

  @override
  String get miniKpiSales => 'sales';

  @override
  String get miniKpiOrders => 'orders';

  @override
  String get miniKpiListings => 'listings';

  @override
  String get todayStats => 'Today\'s Stats';

  @override
  String get activeAuctionsLabel => 'Active Auctions';

  @override
  String get trendFromYesterday => '+2 from yesterday';

  @override
  String get totalSalesLabel => 'Total Sales';

  @override
  String get auctionPlusStore => 'Auction + Store';

  @override
  String get needsReview => 'Needs review';

  @override
  String get activeListingsLabel => 'Active Listings';

  @override
  String get totalPublished => 'Total published';

  @override
  String get balanceAndPoints => 'Balance & Points';

  @override
  String get currentBalanceLabel => 'Current Balance';

  @override
  String get loyaltyPointsLabel => 'Loyalty Points';

  @override
  String get weeklyPerformance => 'Weekly Performance';

  @override
  String get last7DaysSales => 'Sales over the last 7 days';

  @override
  String get accountHealth => 'Account Health';

  @override
  String get accountActivation => 'Account Activation';

  @override
  String get basicPublishingRequirement => 'Required before publishing';

  @override
  String get digitalIdSubtitle => 'QR Code + Ring Number';

  @override
  String get mandatoryVideoLabel => 'Mandatory Video';

  @override
  String get fourStagesRequired => '4 required stages';

  @override
  String get addAuctionLabel => 'Add Auction';

  @override
  String get firstAuctionOnPlatform => 'Your first auction on the platform';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get controlCenter => 'Control Center';

  @override
  String get toolsPageTagline =>
      'Your notifications • features • tools in one place';

  @override
  String get featuresChip => 'Features';

  @override
  String get toolsChip => 'Tools';

  @override
  String get myProducts => 'My Products';

  @override
  String get manageProductsInStore =>
      'Add and manage your products in the store';

  @override
  String myAuctionsWithCount(int count) {
    return 'My Auctions ($count)';
  }

  @override
  String activeTabWithCount(int count) {
    return 'Active ($count)';
  }

  @override
  String endedTabWithCount(int count) {
    return 'Ended ($count)';
  }

  @override
  String get noEndedAuctions => 'No ended auctions';

  @override
  String get noActiveAuctions => 'No active auctions';

  @override
  String get endedAuctionsWillAppearHere => 'Ended auctions will appear here';

  @override
  String get createFirstAuction =>
      'Create your first auction to showcase your birds';

  @override
  String timeLabelDaysHours(int days, int hours) {
    return '${days}d ${hours}h';
  }

  @override
  String timeLabelHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String timeLabelMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get auctionTypeDefault => 'Auction';

  @override
  String get availableForAuction => 'Available for auction';

  @override
  String get inAuction => 'In auction';

  @override
  String get noBirdsYet => 'No birds yet';

  @override
  String get addBirdsToAuctionsAndMarket =>
      'Add your birds to showcase them in auctions and the market';

  @override
  String get noBirdsWithFilter => 'No birds match this filter';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get availableBadge => 'Available';

  @override
  String get daySun => 'Sun';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String bidsCountLabel(int count) {
    return '$count bid(s)';
  }

  @override
  String get usedPackageLabel => 'الباقة المستخدمة';

  @override
  String get addNewBirdTitle => 'إضافة طائر جديد';

  @override
  String get addNewBirdSubtitle => 'أنشئ بيانات طائر جديد وأضفه إلى المزاد';

  @override
  String get chooseFromMyBirds => 'TODO: اختيار من طيوري';

  @override
  String get chooseFromMyBirdsSub =>
      'اختر طائراً موجوداً لم يُدرج في مزاد أو متجر';

  @override
  String get selectBirdTitle => 'اختر طائراً';

  @override
  String get myBirdsAvailableForAuction => 'طيوري المتاحة للإضافة في المزاد';

  @override
  String get noBirdsAvailable => 'لا توجد طيور متاحة';

  @override
  String get allBirdsListed => 'جميع طيورك مدرجة في مزادات أو المتجر';

  @override
  String get noActivePackageWarning =>
      'لا توجد باقة نشطة — ستُرفض عملية الإنشاء';

  @override
  String get subscribeBtn => 'اشترك';

  @override
  String packagePointsInfo(int remaining, int cost) {
    return '$remaining نقطة متبقية · تكلفة المزاد: $cost نقطة';
  }

  @override
  String get endingSoonFilter => 'ينتهي قريباً 🕐';

  @override
  String get myAuctionsFilter => 'مزاداتي ✈️';

  @override
  String activeAuctionsCount(int count) {
    return '$count مزاد نشط';
  }

  @override
  String get loadingMore => 'جارٍ التحميل...';

  @override
  String auctionCountBadge(int count) {
    return '$count مزاد';
  }

  @override
  String get myBidsTooltip => 'مزايداتي';

  @override
  String get refreshTooltip => 'تحديث';

  @override
  String noResultsFor(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get pointsHistoryTitle => 'Points History';

  @override
  String get pointsLoadError =>
      'Failed to load history. Check your connection and try again.';

  @override
  String pointsPaginationLabel(int from, int to, int count) {
    return '$from–$to of $count';
  }

  @override
  String pointsBalanceAfter(int balance) {
    return 'Balance: $balance';
  }

  @override
  String get noPointsTransactions => 'No points transactions yet';

  @override
  String get cashbackHistoryTitle => 'Cashback History';

  @override
  String get cashbackBalanceTitle => 'Cashback Balance';

  @override
  String get egpCurrency => 'EGP';

  @override
  String get discount => 'Discount';

  @override
  String get cashback => 'Cashback';

  @override
  String get sellerLabel => 'Seller';

  @override
  String get noCashbackTransactionsYet => 'No transactions yet';

  @override
  String get cashbackTransactionsWillAppear =>
      'Cashback transactions will appear here after purchases are completed';

  @override
  String get followersAuctions => 'Followed Auctions';

  @override
  String get whoIFollow => 'Who I Follow';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get noFollowedAuctionsYet => 'No auctions yet';

  @override
  String get followSellersToSeeAuctions =>
      'Follow sellers to see their auctions here first';

  @override
  String get discoverSellers => 'Discover Sellers';

  @override
  String compactHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String compactMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get packageFollowing => 'Package following';

  @override
  String get discovery => 'Discovery';

  @override
  String get editBird => 'Edit Bird';

  @override
  String get pigeonBasicData => 'Basic bird data';

  @override
  String get ringNumberRequired => 'Ring number *';

  @override
  String get breedRequired => 'Breed *';

  @override
  String get breedHint => 'Example: racing pigeon';

  @override
  String get genderRequired => 'Gender *';

  @override
  String get optionalData => 'Optional data';

  @override
  String get chooseHatchDate => 'Choose hatch date';

  @override
  String get achievementsRequired => 'Achievements *';

  @override
  String get achievementsHint =>
      'Write the bird\'s most important achievements';

  @override
  String get staminaRequired => 'Stamina ability *';

  @override
  String get saleData => 'Sale data';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameHint => 'Name shown to buyers';

  @override
  String get priceEgpRequired => 'Price (EGP) *';

  @override
  String get priceHint => 'Example: 1500';

  @override
  String get flyingSpeedKmh => 'Flying speed (km/h)';

  @override
  String get flyingSpeedHint => 'Example: 75.5';

  @override
  String get birdStatus => 'Bird status';

  @override
  String get pedigreeData => 'Pedigree data';

  @override
  String get fatherRingOptional => 'Father number (optional)';

  @override
  String get motherRingOptional => 'Mother number (optional)';

  @override
  String get birdIdHint => 'Bird ID';

  @override
  String get saving => 'Saving...';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get nextAddPhotos => 'Next - Add Photos';

  @override
  String get listInMarket => 'List in market';

  @override
  String get listInMarketDesc => 'The bird will appear to buyers in the market';

  @override
  String get auction => 'TODO: هذا المزاد يقبل طائراً واحداً فقط';

  @override
  String get adfMnIla =>
      'TODO: أضف من ٢ إلى ١٠ طيور — كل طائر يُزايد عليه بشكل مستقل';

  @override
  String get pairType =>
      'TODO: أضف طائراً واحداً ثم اختر زوجه من بطاقة الطائر (ذكر + أنثى)';

  @override
  String get pairType2 =>
      'TODO: مزاد تناسل — طائر واحد مع زوجه (ذكر + أنثى) من بطاقة الطائر';

  @override
  String get racingType => 'TODO: أضف طائرين على الأقل لمجموعة السباق';

  @override
  String get packageLabel => 'TODO: باقة';

  @override
  String get pointsLabel => 'TODO: نقاط';

  @override
  String get singleType => 'TODO: فردي';

  @override
  String get multipleType => 'TODO: متعدد';

  @override
  String get pairType3 => 'TODO: زوج';

  @override
  String get breedingType => 'TODO: تناسل';

  @override
  String get racingType2 => 'TODO: سباق';

  @override
  String get add => 'TODO: إضافة طائر جديد';

  @override
  String get auction2 => 'TODO: أنشئ بيانات طائر جديد وأضفه إلى المزاد';

  @override
  String get chooseBird => 'TODO: اختر طائراً موجوداً لم يُدرج في مزاد أو متجر';

  @override
  String get notSpecified => 'TODO: غير محدد';

  @override
  String sna(Object years) {
    return 'TODO: $years سنة';
  }

  @override
  String get aqlMnSna => 'TODO: أقل من سنة';

  @override
  String get notAvailable2 => 'TODO: غير متاح';

  @override
  String get no => 'TODO: لا يوجد وصف.';

  @override
  String get no2 => 'TODO: ملاحظة للبائع (اختياري)';

  @override
  String get no3 => 'TODO: هذا مزادك — لا يمكنك المزايدة';

  @override
  String get auctionEnded2 => 'TODO: انتهى المزاد';

  @override
  String get auctionNotStarted => 'TODO: المزاد لم يبدأ بعد';

  @override
  String get sold => 'TODO: مُباع';

  @override
  String get sold2 => 'TODO: غير مُباع';

  @override
  String get active => 'TODO: نشط';

  @override
  String get expired2 => 'TODO: منتهي';

  @override
  String get upcoming => 'TODO: قادم';

  @override
  String get enterValidNumber2 => 'TODO: أدخل رقمًا صحيحًا';

  @override
  String minimumBid(Object value) {
    return 'TODO: الحد الأدنى $value ج.م';
  }

  @override
  String get minimumBid2 => 'TODO: الحد الأدنى';

  @override
  String get currentPrice2 => 'TODO: السعر الحالي';

  @override
  String jM(Object value) {
    return 'TODO: $value ج.م';
  }

  @override
  String get minimumBid3 => 'TODO: الحد الأدنى';

  @override
  String jM2(Object value) {
    return 'TODO: $value ج.م';
  }

  @override
  String get jM3 => 'TODO: ج.م';

  @override
  String get all2 => 'TODO: الكل';

  @override
  String get ynthyQryba => 'TODO: ينتهي قريباً 🕐';

  @override
  String get auction3 => 'TODO: مزاداتي ✈️';

  @override
  String no4(Object _searchQuery) {
    return 'TODO: لا توجد نتائج لـ \"$_searchQuery\"';
  }

  @override
  String get loading => 'TODO: تحميل المزيد';

  @override
  String get loading2 => 'TODO: جارٍ التحميل...';

  @override
  String get myBids2 => 'TODO: مزايداتي';

  @override
  String get refresh => 'TODO: تحديث';

  @override
  String sna2(Object years) {
    return 'TODO: $years سنة';
  }

  @override
  String get buyer => 'TODO: مشتري';

  @override
  String get user => 'TODO: مستخدم';

  @override
  String shhr(int floor) {
    return 'TODO: $floor شهر';
  }

  @override
  String ywm(int inDays) {
    return 'TODO: $inDays يوم';
  }

  @override
  String saaa(int inHours) {
    return 'TODO: $inHours ساعة';
  }

  @override
  String get now2 => 'TODO: الآن';

  @override
  String get loading3 => 'TODO: فشل تحميل الرسائل';

  @override
  String get errorOccurred2 => 'TODO: حدث خطأ';

  @override
  String get now3 => 'TODO: الآن';

  @override
  String mnthD(int inMinutes) {
    return 'TODO: منذ $inMinutes د';
  }

  @override
  String mnthS(int inHours) {
    return 'TODO: منذ $inHours س';
  }

  @override
  String mnthAyam(int inDays) {
    return 'TODO: منذ $inDays أيام';
  }

  @override
  String get paymentRejectionDispute => 'TODO: اعتراض على رفض الدفع';

  @override
  String get postSaleComplaint => 'TODO: شكوى ما بعد البيع';

  @override
  String get submitComplaint => 'TODO: تقديم شكوى';

  @override
  String get submit => 'TODO: جاري الإرسال...';

  @override
  String get submitComplaintAction => 'TODO: تقديم الشكوى';

  @override
  String shkwa(Object id) {
    return 'TODO: شكوى #$id';
  }

  @override
  String get complaintNumber => 'TODO: رقم الشكوى';

  @override
  String get paymentRequest => 'TODO: طلب الدفع';

  @override
  String get type => 'TODO: النوع';

  @override
  String get creationDate => 'TODO: تاريخ الإنشاء';

  @override
  String get resolutionDate => 'TODO: تاريخ الحل';

  @override
  String get cancel2 => 'TODO: تاريخ الإلغاء';

  @override
  String get no5 => 'TODO: لا يوجد وصف';

  @override
  String get complaints => 'TODO: الشكاوى';

  @override
  String get following => 'TODO: من أتابع';

  @override
  String almrbwnAlmtabawn(int length) {
    return 'TODO: المربّون المتابَعون ($length)';
  }

  @override
  String albaqatAlmtabaa(int length) {
    return 'TODO: الباقات المتابَعة ($length)';
  }

  @override
  String get peopleMayKnow => 'TODO: مربيون قد تعرفهم';

  @override
  String get refresh2 => 'TODO: تحديث';

  @override
  String get room => 'TODO: غرفة';

  @override
  String get listed => 'TODO: معروضة';

  @override
  String get search2 => 'TODO: ابحث باسم الغرفة أو الدولة';

  @override
  String get auction4 => 'TODO: مزاد';

  @override
  String get item => 'TODO: عنصر';

  @override
  String get rating => 'TODO: تقييم';

  @override
  String get no6 => 'TODO: لا توجد غرف حالياً';

  @override
  String get no7 => 'TODO: لا توجد نتائج مطابقة';

  @override
  String get search3 => 'TODO: جرّب البحث باسم آخر أو دولة مختلفة';

  @override
  String get refresh3 => 'TODO: اسحب للأسفل للتحديث والمحاولة مجدداً';

  @override
  String get room2 => 'TODO: غرفة';

  @override
  String mrbyMhtrfMn(String country) {
    return 'TODO: مربي محترف من $country';
  }

  @override
  String get hmamZajl => 'TODO: حمام زاجل';

  @override
  String get mrbyMhtrf => 'TODO: مربي محترف';

  @override
  String get auction5 => 'TODO: مزادات';

  @override
  String get pairType4 => 'TODO: مزاد زوج تربية';

  @override
  String get auction6 => 'TODO: مزاد زاجل بلجيكي';

  @override
  String get sarMbdyyJM => 'TODO: سعر مبدئي: ج.م 5,000';

  @override
  String get sarMbdyyJM2 => 'TODO: سعر مبدئي: ج.م 12,000';

  @override
  String get klAlanwaa => 'TODO: كل الأنواع';

  @override
  String get thanya => 'TODO: ثانية';

  @override
  String get dqyqa => 'TODO: دقيقة';

  @override
  String get saaa2 => 'TODO: ساعة';

  @override
  String get ywm2 => 'TODO: يوم';

  @override
  String get alryysya => 'TODO: الرئيسية';

  @override
  String get auction7 => 'TODO: المزادات';

  @override
  String get almtjr => 'TODO: المتجر';

  @override
  String get rooms => 'TODO: الغرف';

  @override
  String get alntayj => 'TODO: النتائج';

  @override
  String get alsaaa => 'Timer';

  @override
  String get brnamjAlwft => 'Loft Program';

  @override
  String get active2 => 'TODO: مزادات نشطة';

  @override
  String get tnthyQryba => 'TODO: تنتهي قريباً';

  @override
  String alawsma(int length) {
    return 'TODO: الأوسمة ($length)';
  }

  @override
  String get mlgha => 'TODO: مُلغى';

  @override
  String get sjlAjlaAlhz => 'TODO: سجل عجلة الحظ';

  @override
  String get tmAlfwz => 'TODO: تم الفوز';

  @override
  String get lmTfz => 'TODO: لم تفز';

  @override
  String get loading4 => 'TODO: حدث خطأ في تحميل العجلة';

  @override
  String get auction8 =>
      'TODO: حصلت على دورة مجانية بعد انتهاء مزادك بعملية بيع مدفوعة';

  @override
  String get auction9 => 'TODO: حصلت على دورة مجانية بعد مشاركتك في المزاد';

  @override
  String get thanyna => 'TODO: 🎉 تهانينا!';

  @override
  String get jrbHzkMraAkhra => 'TODO: 🎲 جرّب حظك مرة أخرى!';

  @override
  String get rayaAstlmJayztk => 'TODO: رائع! استلم جائزتك';

  @override
  String get upcoming2 => 'TODO: حسناً، في المرة القادمة';

  @override
  String get spinAgain => '🎰 Spin Again!';

  @override
  String spinAttemptsRemaining(int count) {
    return '$count attempts remaining';
  }

  @override
  String get spinNowLabel => 'Spin Now';

  @override
  String get spinningLabel => 'Spinning...';

  @override
  String get noAttemptsLabel => 'No attempts available';

  @override
  String get noPrizesLabel => 'No prizes configured';

  @override
  String get availableAttemptsTitle => 'Available Attempts';

  @override
  String get canSpinNowHint => 'You can spin the wheel now.';

  @override
  String get earnAttemptsHint =>
      'Earn attempts from eligible auction activity.';

  @override
  String get noPrizesConfiguredHint => 'Wheel prizes are not configured yet.';

  @override
  String get wheelTurnAvailable => '🎰 Your spin is available!';

  @override
  String get noPrizesWheelEmpty => 'No prizes';

  @override
  String get addPrizesToShowWheel =>
      'Add active Lucky Wheel prizes to show wheel items.';

  @override
  String get noPrizesYet => 'No wheel prizes yet';

  @override
  String get prizesListEmptyRefresh =>
      'The prize list is currently empty. Refresh the page to try again.';

  @override
  String get loading5 => 'TODO: فشل تحميل الإشعارات';

  @override
  String tlbDfa(Object id) {
    return 'TODO: طلب دفع #$id';
  }

  @override
  String get rqmAltlb => 'TODO: رقم الطلب';

  @override
  String get type2 => 'TODO: النوع';

  @override
  String get almntj => 'TODO: المنتج';

  @override
  String get alfya => 'TODO: الفئة';

  @override
  String get buyer2 => 'TODO: رقم المشتري';

  @override
  String get auction10 => 'TODO: رقم قطعة المزاد';

  @override
  String get item2 => 'TODO: رقم عنصر الطلب';

  @override
  String get creationDate2 => 'TODO: تاريخ الإنشاء';

  @override
  String get tarykhAlqbwl => 'TODO: تاريخ القبول';

  @override
  String get tarykhAlrfd => 'TODO: تاريخ الرفض';

  @override
  String get no8 => 'TODO: ملاحظة المشتري';

  @override
  String get no9 => 'TODO: ملاحظة البائع';

  @override
  String get fthAlswra => 'TODO: فتح الصورة';

  @override
  String get irfaqIthbatAldfa => 'TODO: إرفاق إثبات الدفع';

  @override
  String get resubmitPaymentTitle => 'Resubmit Payment Request';

  @override
  String get resubmitPaymentSubtitle => 'Payment proof is required to resubmit';

  @override
  String get proofRequiredHint => 'Payment proof is required';

  @override
  String get resubmit => 'Resubmit';

  @override
  String shhadaNsb(Object id) {
    return 'TODO: شهادة نسب #$id';
  }

  @override
  String get tmtAlmrajaa => 'TODO: تمت المراجعة';

  @override
  String get save2 => 'TODO: تم حفظ البيانات المُراجَعة بنجاح.';

  @override
  String get tmtAlmaalja => 'TODO: تمت المعالجة';

  @override
  String get tmAstkhrajAlbyanatRajahaAdnah =>
      'TODO: تم استخراج البيانات. راجعها أدناه.';

  @override
  String get fshlAltarfAltlqayy => 'TODO: فشل التعرف التلقائي';

  @override
  String get lmYtmAltarfTlqayyaYmknk =>
      'TODO: لم يتم التعرف تلقائياً، يمكنك المراجعة اليدوية.';

  @override
  String get mrfwa => 'TODO: مرفوع';

  @override
  String get jaryMaaljaAlmlf => 'TODO: جاري معالجة الملف.';

  @override
  String get save3 => 'TODO: جاري الحفظ...';

  @override
  String get save4 => 'TODO: حفظ المراجعة';

  @override
  String get shhadatAlnsb => 'TODO: شهادات النسب';

  @override
  String get rfaShhada => 'TODO: رفع شهادة';

  @override
  String get jaryAlrfa => 'TODO: جاري الرفع...';

  @override
  String get tmtAlmrajaa2 => 'TODO: تمت المراجعة';

  @override
  String get tmtAlmaalja2 => 'TODO: تمت المعالجة';

  @override
  String get fshlMrajaaYdwya => 'TODO: OCR فشل — مراجعة يدوية';

  @override
  String get mrfwa2 => 'TODO: مرفوع';

  @override
  String get mshRmz => 'TODO: مسح رمز QR';

  @override
  String get no10 => 'TODO: الفلاش';

  @override
  String get loading6 => 'TODO: جارٍ تحميل بيانات الطائر...';

  @override
  String get wjhAlkamyraNhwRmzAla =>
      'TODO: وجّه الكاميرا نحو رمز QR على بطاقة الطائر';

  @override
  String get delete2 => 'TODO: حدث خطأ أثناء الحذف';

  @override
  String get alhala => 'TODO: الحالة';

  @override
  String get mwthq => 'TODO: موثّق ✓';

  @override
  String get loading7 => 'TODO: تعذّر تحميل وثائق النسب';

  @override
  String get jarAlmaalja => 'TODO: جارٍ المعالجة';

  @override
  String get tmtAlmaalja3 => 'TODO: تمت المعالجة';

  @override
  String get mraja => 'TODO: مراجع';

  @override
  String get fshl => 'TODO: فشل';

  @override
  String wthyqa(Object id) {
    return 'TODO: وثيقة #$id';
  }

  @override
  String get swrAlhmama => 'TODO: صور الحمامة';

  @override
  String get next2 => 'TODO: التالي — تسجيل فيديو زاجل';

  @override
  String get akhtyary => 'TODO: اختياري';

  @override
  String get mrajaaAlbyanat => 'TODO: مراجعة البيانات';

  @override
  String get almrajaaAlnhayya => 'TODO: المراجعة النهائية';

  @override
  String get albyanatAlasasya => 'TODO: البيانات الأساسية';

  @override
  String get thkr => 'TODO: ذكر 🔵';

  @override
  String get antha => 'TODO: أنثى 🔴';

  @override
  String alswr(int length) {
    return 'TODO: الصور ($length)';
  }

  @override
  String get fydywZajl => 'TODO: فيديو زاجل';

  @override
  String get tmTsjylFydywZajlBnjah => 'TODO: تم تسجيل فيديو زاجل بنجاح ✓';

  @override
  String get lmYtmTsjylAlfydywBad => 'TODO: لم يتم تسجيل الفيديو بعد';

  @override
  String racingType3(int length) {
    return 'TODO: نتائج السباقات ($length)';
  }

  @override
  String get inshaAlhwyaAlrqmya => 'TODO: إنشاء الهوية الرقمية';

  @override
  String get mktml => 'TODO: مكتمل';

  @override
  String get naqs => 'TODO: ناقص';

  @override
  String get btaqaAltayr => 'TODO: بطاقة الطائر';

  @override
  String get sraaAltyran => 'TODO: سرعة الطيران';

  @override
  String get alqdraAlaAlthml => 'TODO: القدرة على التحمل';

  @override
  String get almrby => 'TODO: المربّي';

  @override
  String get no11 => 'TODO: الجسم كاملاً';

  @override
  String get no12 => 'TODO: وجّه الكاميرا لالتقاط الحمامة بالكامل من الجانب';

  @override
  String get aljnahYmynYsar => 'TODO: الجناح (يمين / يسار)';

  @override
  String get afrdAljnahWqrbhMnAlkamyra => 'TODO: افرد الجناح وقربه من الكاميرا';

  @override
  String get alaynMakrw => 'TODO: العين (ماكرو)';

  @override
  String get no13 => 'TODO: قرّب الكاميرا من العين لالتقاط التفاصيل';

  @override
  String get takdMnWdwhArqamAldbla =>
      'TODO: تأكد من وضوح أرقام الدبلة في المربع أسفل الشاشة';

  @override
  String get rqmAldbla => 'TODO: رقم الدبلة';

  @override
  String get mtlwbIthnAlkamyra => 'TODO: مطلوب إذن الكاميرا';

  @override
  String get no14 => 'TODO: لا توجد كاميرا متاحة';

  @override
  String get tathrTshghylAlkamyra => 'TODO: تعذّر تشغيل الكاميرا';

  @override
  String get fshlDmjAlfydyw => 'TODO: فشل دمج الفيديو';

  @override
  String get fshlDmjAlfydyw2 => 'TODO: فشل دمج الفيديو';

  @override
  String get thabtSybdaAltsjylTlqayya =>
      'TODO: ثابت ✓ — سيبدأ التسجيل تلقائياً';

  @override
  String get thbtAlkamyraLbdAltsjyl => 'TODO: ثبّت الكاميرا لبدء التسجيل';

  @override
  String get add2 => 'TODO: إضافة غرفة جديدة';

  @override
  String get errorOccurred3 => 'TODO: حدث خطأ، حاول مجدداً';

  @override
  String get mthalHmamAlzajlAlthhby => 'TODO: مثال: حمام الزاجل الذهبي';

  @override
  String get rooms2 => 'TODO: أدخل اسم الغرفة';

  @override
  String get no15 => 'TODO: الاسم قصير جداً';

  @override
  String get no16 => 'TODO: الاسم المعروض';

  @override
  String get asmkFyAlmnsa => 'TODO: اسمك في المنصة';

  @override
  String get no17 => 'TODO: الاسم مطلوب';

  @override
  String get akhtrDwltk => 'TODO: اختر دولتك';

  @override
  String get alamla => 'TODO: العملة';

  @override
  String get akhtrAlamla => 'TODO: اختر العملة';

  @override
  String get mntqaAlkhtr => 'TODO: منطقة الخطر';

  @override
  String get msr => 'TODO: مصر';

  @override
  String get alsawdya => 'TODO: السعودية';

  @override
  String get alimarat => 'TODO: الإمارات';

  @override
  String get alkwyt => 'TODO: الكويت';

  @override
  String get qtr => 'TODO: قطر';

  @override
  String get albhryn => 'TODO: البحرين';

  @override
  String get aman => 'TODO: عُمان';

  @override
  String get alardn => 'TODO: الأردن';

  @override
  String get alaraq => 'TODO: العراق';

  @override
  String get lbnan => 'TODO: لبنان';

  @override
  String get swrya => 'TODO: سوريا';

  @override
  String get flstyn => 'TODO: فلسطين';

  @override
  String get alymn => 'TODO: اليمن';

  @override
  String get almghrb => 'TODO: المغرب';

  @override
  String get twns => 'TODO: تونس';

  @override
  String get aljzayr => 'TODO: الجزائر';

  @override
  String get lybya => 'TODO: ليبيا';

  @override
  String get alswdan => 'TODO: السودان';

  @override
  String get trkya => 'TODO: تركيا';

  @override
  String get errorOccurred4 => 'TODO: حدث خطأ، حاول مجدداً';

  @override
  String get edit2 => 'TODO: تعديل الغرفة';

  @override
  String get rooms3 => 'TODO: اسم الغرفة';

  @override
  String get mthalHmamAlzajlAlthhby2 => 'TODO: مثال: حمام الزاجل الذهبي';

  @override
  String get rooms4 => 'TODO: أدخل اسم الغرفة';

  @override
  String get no18 => 'TODO: الاسم قصير جداً';

  @override
  String get aldwla => 'TODO: الدولة';

  @override
  String get loading8 => 'TODO: حدث خطأ في تحميل الملف الشخصي';

  @override
  String get buyer3 => 'TODO: مشتري';

  @override
  String get baya => 'TODO: بائع';

  @override
  String get ghyrMfal => 'TODO: غير مفعّل';

  @override
  String get mfal => 'TODO: مفعّل';

  @override
  String get salh => 'TODO: صالح';

  @override
  String get ghyrSalh => 'TODO: غير صالح';

  @override
  String get rsydAlkashbak => 'TODO: رصيد الكاشباك';

  @override
  String get alamla2 => 'TODO: العملة';

  @override
  String get no19 => 'TODO: تاريخ الانضمام';

  @override
  String get altlbatAlmktmla => 'TODO: الطلبات المكتملة';

  @override
  String get aldawatAlnajha => 'TODO: الدعوات الناجحة';

  @override
  String get khsmAlmstwa => 'TODO: خصم المستوى';

  @override
  String get kashBakAlmstwa => 'TODO: كاش باك المستوى';

  @override
  String get alarwdWaltkhfydat => 'TODO: العروض والتخفيضات';

  @override
  String get arwdkAlkhasa => 'TODO: عروضك الخاصة';

  @override
  String get arwdAltkhfyd => 'TODO: عروض التخفيض';

  @override
  String get arwdAlkashBak => 'TODO: عروض الكاش باك';

  @override
  String get tkhfyd => 'TODO: تخفيض';

  @override
  String get kashBak => 'TODO: كاش باك';

  @override
  String get racingType4 => 'TODO: تفاصيل السباق';

  @override
  String get loading9 => 'TODO: حدث خطأ في تحميل السباق';

  @override
  String get no20 => 'TODO: وقت الإطلاق';

  @override
  String get addAltywr => 'TODO: عدد الطيور';

  @override
  String get addAlmtsabqyn => 'TODO: عدد المتسابقين';

  @override
  String get almsafaAlmkhtta => 'TODO: المسافة المخططة';

  @override
  String get halaAltqs => 'TODO: حالة الطقس';

  @override
  String get no21 => 'TODO: ملاحظات';

  @override
  String get errorOccurred5 => 'TODO: حدث خطأ';

  @override
  String get search4 => 'TODO: ابحث برقم حلقة الحمام أو اسم المتسابق';

  @override
  String get errorOccurred6 => 'TODO: حدث خطأ';

  @override
  String get no22 => 'TODO: لا توجد نتائج مطابقة';

  @override
  String get altalyqat => 'TODO: التعليقات';

  @override
  String get brnamjAlihala => 'TODO: برنامج الإحالة';

  @override
  String get loading10 => 'TODO: فشل في تحميل الكود';

  @override
  String get adkhlAlkwdHna => 'TODO: أدخل الكود هنا...';

  @override
  String get alfya2 => 'TODO: الفئة';

  @override
  String get asmAlmntj => 'TODO: اسم المنتج';

  @override
  String get mthalAlfHmamBrymks => 'TODO: مثال: علف حمام بريمكس';

  @override
  String get no23 => 'TODO: الاسم يجب أن يكون 3 أحرف على الأقل';

  @override
  String get sfAlmntjBshklWadh => 'TODO: صف المنتج بشكل واضح...';

  @override
  String get alwsfMtlwb => 'TODO: الوصف مطلوب';

  @override
  String get alsarJM => 'TODO: السعر (ج.م)';

  @override
  String get sarGhyrSalh => 'TODO: سعر غير صالح';

  @override
  String get kmyaGhyrSalha => 'TODO: كمية غير صالحة';

  @override
  String get alhala2 => 'TODO: الحالة';

  @override
  String get alswrHta => 'TODO: الصور (حتى 5)';

  @override
  String get packageLabel2 => 'TODO: الباقة المستخدمة';

  @override
  String get add3 => 'TODO: إضافة المنتج';

  @override
  String get save5 => 'TODO: حفظ التعديلات';

  @override
  String get edit3 => 'TODO: تعديل المنتج';

  @override
  String get add4 => 'TODO: إضافة منتج جديد';

  @override
  String get iksswarat => 'TODO: إكسسوارات';

  @override
  String get no24 => 'TODO: أعلاف والحبوب';

  @override
  String get no25 => 'TODO: مكملات غذائية';

  @override
  String get mtah => 'TODO: متاح';

  @override
  String get mbaa => 'TODO: مباع';

  @override
  String get active3 => 'TODO: غير نشط';

  @override
  String get errorOccurred7 => 'TODO: حدث خطأ';

  @override
  String get all3 => 'TODO: الكل';

  @override
  String get iksswarat2 => 'TODO: إكسسوارات';

  @override
  String get no26 => 'TODO: مكملات';

  @override
  String get no27 => 'TODO: أعلاف';

  @override
  String get lmTdfAyMntjatBad => 'TODO: لم تضف أي منتجات بعد';

  @override
  String get no28 => 'TODO: لا توجد منتجات في هذه الفئة';

  @override
  String get loading11 => 'TODO: حدث خطأ في تحميل المنتجات';

  @override
  String jM4(double price) {
    return 'TODO: $price ج.م';
  }

  @override
  String qtaa(int count) {
    return 'TODO: $count قطعة';
  }

  @override
  String get alakthrShabya => 'TODO: الأكثر شعبية';

  @override
  String get shhr2 => 'TODO: شهر';

  @override
  String get shhran => 'TODO: شهران';

  @override
  String ashhr(int days) {
    return 'TODO: $days أشهر';
  }

  @override
  String ywm3(Object days) {
    return 'TODO: $days يوم';
  }

  @override
  String nqtaIjmalya(Object points) {
    return 'TODO: $points نقطة إجمالية';
  }

  @override
  String auction11(Object auctionCost) {
    return 'TODO: إنشاء مزاد: $auctionCost نقطة لكل مزاد';
  }

  @override
  String nshrMntjNqtaLklMntj(Object productCost) {
    return 'TODO: نشر منتج: $productCost نقطة لكل منتج';
  }

  @override
  String salhaLmda(Object value) {
    return 'TODO: صالحة لمدة $value';
  }

  @override
  String get no29 =>
      'TODO: تم تقديم طلب الاشتراك بنجاح سيتم تفعيل الباقة من قِبَل المشرف قريباً';

  @override
  String get errorOccurred8 => 'TODO: حدث خطأ غير متوقع';

  @override
  String get bantzarTfaylAlmshrf => 'TODO: بانتظار تفعيل المشرف';

  @override
  String get tmIrfaqIthbatAldfa => 'TODO: تم إرفاق إثبات الدفع';

  @override
  String get lmYrfqIthbatAldfa => 'TODO: لم يُرفق إثبات الدفع';

  @override
  String get ynayr => 'TODO: يناير';

  @override
  String get ywnyw => 'TODO: يونيو';

  @override
  String get mayw => 'TODO: مايو';

  @override
  String get fbrayr => 'TODO: فبراير';

  @override
  String get mars => 'TODO: مارس';

  @override
  String get abryl => 'TODO: أبريل';

  @override
  String get dysmbr => 'TODO: ديسمبر';

  @override
  String get ywlyw => 'TODO: يوليو';

  @override
  String get aghsts => 'TODO: أغسطس';

  @override
  String get sbtmbr => 'TODO: سبتمبر';

  @override
  String get aktwbr => 'TODO: أكتوبر';

  @override
  String get nwfmbr => 'TODO: نوفمبر';

  @override
  String auction12(Object auctionCost) {
    return 'TODO: مزاد: $auctionCost نقطة';
  }

  @override
  String mntjNqta(Object productCost) {
    return 'TODO: منتج: $productCost نقطة';
  }

  @override
  String get akhtrMlf => 'TODO: اختر ملف (JPG / PNG / PDF)';

  @override
  String get jM5 => 'TODO: ج.م';

  @override
  String get packageLabel3 => 'TODO: اختر هذه الباقة';

  @override
  String get subscribe => 'TODO: اشترك الآن';

  @override
  String get racingChampion => 'racing, champion, ...';

  @override
  String get writeComment => 'Write a comment';

  @override
  String get notesTitle => 'Notes';

  @override
  String get paymentProofTitle => 'Payment Proof';

  @override
  String get sellerActionTitle => 'Seller Action';

  @override
  String paymentRequestNum(Object id) {
    return 'Request #$id';
  }

  @override
  String get auctionPaymentRejectedNotice =>
      'The payment request was rejected by the seller. You cannot resubmit a payment request for this auction item.';

  @override
  String get selectBirdSubtitle => 'My birds available to add to the auction';

  @override
  String get reservePriceField => 'Reserve Price';

  @override
  String get pickSourceTitle => 'Choose upload method';

  @override
  String get browseFiles => 'Browse Files';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get ongoingAuctions => 'Ongoing Auctions';

  @override
  String get noAuctionsInCategory => 'No auctions in this category right now';

  @override
  String get layoutHorizontal => 'Horizontal';

  @override
  String get layoutGrid => 'Grid';

  @override
  String get cannotBidSellerBlocked =>
      'You cannot bid while this seller is blocked';

  @override
  String wonAuctionBird(String birdName) {
    return 'Won auction for $birdName';
  }

  @override
  String get discussion => 'Discussion';

  @override
  String get auctionClosedLabel => 'Auction closed';

  @override
  String get ownerPill => 'Owner';

  @override
  String get auctionClosedComments =>
      'This auction is closed. Comments are no longer accepted.';

  @override
  String get noAuctionItemComments => 'No auction item available for comments.';

  @override
  String get blocked => 'Blocked';

  @override
  String get messageSeller => 'Message';

  @override
  String get followFirst => 'Follow first';

  @override
  String get auctionEventsLabel => 'Events';
}
