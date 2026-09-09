import 'package:flutter/material.dart';
import 'package:user_app/localization/language_constrants.dart';

enum AuctionApprovalStatus {
  pending('pending'),
  rejected('rejected'),
  approved('approved');

  final String key;
  const AuctionApprovalStatus(this.key);

  String label(BuildContext context) {
    switch (this) {
      case AuctionApprovalStatus.pending:
        return getTranslated('pending', context) ?? 'Pending';
      case AuctionApprovalStatus.rejected:
        return getTranslated('rejected', context) ?? 'Rejected';
      case AuctionApprovalStatus.approved:
        return getTranslated('approved', context) ?? 'Approved';
    }
  }
}