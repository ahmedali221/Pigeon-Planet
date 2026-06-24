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
}
