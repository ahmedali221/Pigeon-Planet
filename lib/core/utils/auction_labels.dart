import '../../l10n/app_localizations.dart';

String localizedAuctionType(String type, AppLocalizations l) {
  switch (type) {
    case 'single':
      return l.auctionTypeSingle;
    case 'multi':
      return l.auctionTypeMulti;
    case 'pair':
      return l.auctionTypePair;
    case 'breeding':
      return l.auctionTypeBreeding;
    case 'racing':
      return l.auctionTypeRacing;
    default:
      return type.isNotEmpty ? type : l.auctionTypeDefault;
  }
}

String localizedAuctionStatus(String status, AppLocalizations l) {
  switch (status) {
    case 'active':
      return l.statusActive;
    case 'ended':
      return l.statusEnded;
    case 'cancelled':
      return l.statusCancelled;
    case 'closed':
      return l.statusClosed;
    default:
      return status;
  }
}
