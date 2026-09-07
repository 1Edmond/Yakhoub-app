import 'dart:convert';

import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/payment_status_enum.dart';


enum AuctionOwnerType {
  admin,
  seller,
  customer,
  unknown;

  static AuctionOwnerType fromString(String? value) {
    switch (value) {
      case 'admin':     return AuctionOwnerType.admin;
      case 'seller':    return AuctionOwnerType.seller;
      case 'customer':  return AuctionOwnerType.customer;
      default:          return AuctionOwnerType.unknown;
    }
  }
}

class ParticipationAuctionDetailsModel {
  final AuctionProductDetails? product;
  final List<SimilarProduct>? similarProducts;
  final List<SameAuthorProduct>? sameAuthorProducts;
  final PaymentInfo? paymentInfo;
  final BillingInfo? billingInfo;

  ParticipationAuctionDetailsModel({
    this.product,
    this.similarProducts,
    this.sameAuthorProducts,
    this.paymentInfo,
    this.billingInfo,
  });

  factory ParticipationAuctionDetailsModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    final mergedProductJson = productJson != null
        ? {...productJson, 'second_highest_bid': json['second_highest_bid']}
        : null;
    return ParticipationAuctionDetailsModel(
      product: mergedProductJson != null ? AuctionProductDetails.fromJson(mergedProductJson) : null,
      similarProducts: json['similar_products'] != null
          ? List.from(json['similar_products']).map((e) => SimilarProduct.fromJson(e)).toList() : null,
      sameAuthorProducts: json['same_author_products'] != null
          ? List.from(json['same_author_products']).map((e) => SameAuthorProduct.fromJson(e)).toList() : null,
      paymentInfo: json['payment_info'] != null
          ? PaymentInfo.fromJson(json['payment_info'])
          : null,
      billingInfo: json['billing_info'] != null
          ? BillingInfo.fromJson(json['billing_info'])
          : null,
    );
  }
}

class AuctionProductDetails {
  final int? id;
  final String? name;
  final int? categoryId;
  final int? ownerId;
  final AuctionOwnerType? ownerType;
  final OwnerInfo? ownerInfo;
  final String? details;
  final String? itemCondition;

  final double? shippingFee;
  final String? returnPolicy;

  final double? startingPrice;
  final double? highestBidAmount;
  final double? minimumIncrementAmount;
  final double? maximumDecrementAmount;
  final double? currentHighestBidAmount;

  final int? totalViews;
  final int? totalBidsCount;

  final String? startTime;
  final String? endTime;

  final ThumbnailFullUrl? thumbnailFullUrl;
  final List<ThumbnailFullUrl>? imagesFullUrl;

  final Brand? brand;
  final List<Bid>? bids;

  final MyParticipation? myParticipation;
  final MyBid? myBid;

  final double? totalTaxAmount;

  final int? shippingAddressId;
  final AddressInfo? shippingAddressInfo;
  final int? billingAddress;
  final AddressInfo? billingAddressInfo;

  final int? totalParticipants;
  final int? participantsCount;
  final int? totalParticipantsCount;

  final bool? hasReadyToDeliveryParticipantSignal;
  final bool? hasOnTheWayParticipantSignal;
  final bool? hasPurchaseCompleteParticipantSignal;
  final AuctionParticipationStatus? auctionStatus;
  final AuctionParticipationStatus? myAuctionStatus;
  final String? auctionOwnerStatus;
  final String? trackingUrl;
  final AuctionInsights? auctionInsights;
  final bool? isAuctionSave;
  final bool? isSameAddress;
  final MySavedProduct? mySavedProduct;
  final String? videoProvider;
  final String? youtubeVideoUrl;
  final ThumbnailFullUrl? customVideoUrlFullUrl;
  final SecondHighestBid? secondHighestBid;
  final bool? isAllBidWithdrawn;

  AuctionProductDetails({
    this.id,
    this.name,
    this.categoryId,
    this.ownerId,
    this.ownerType,
    this.ownerInfo,
    this.details,
    this.itemCondition,
    this.shippingFee,
    this.returnPolicy,
    this.startingPrice,
    this.highestBidAmount,
    this.minimumIncrementAmount,
    this.maximumDecrementAmount,
    this.currentHighestBidAmount,
    this.totalViews,
    this.totalBidsCount,
    this.startTime,
    this.endTime,
    this.thumbnailFullUrl,
    this.imagesFullUrl,
    this.brand,
    this.bids,
    this.myParticipation,
    this.myBid,
    this.totalTaxAmount,
    this.shippingAddressId,
    this.shippingAddressInfo,
    this.billingAddress,
    this.billingAddressInfo,
    this.totalParticipants,
    this.participantsCount,
    this.totalParticipantsCount,
    this.hasReadyToDeliveryParticipantSignal,
    this.hasOnTheWayParticipantSignal,
    this.hasPurchaseCompleteParticipantSignal,
    this.auctionStatus,
    this.myAuctionStatus,
    this.auctionOwnerStatus,
    this.trackingUrl,
    this.auctionInsights,
    this.mySavedProduct,
    this.videoProvider,
    this.youtubeVideoUrl,
    this.customVideoUrlFullUrl,
    this.isAuctionSave,
    this.isSameAddress,
    this.secondHighestBid,
    this.isAllBidWithdrawn,
  });

  factory AuctionProductDetails.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) =>
        value != null ? double.tryParse(value.toString()) : null;

    final ownerType = AuctionOwnerType.fromString(json['owner_type']);

    OwnerInfo? ownerInfo;
    if (ownerType == AuctionOwnerType.admin || ownerType == AuctionOwnerType.seller) {
      ownerInfo = json['seller'] != null ? OwnerInfo.fromJson(json['seller']) : null;
    } else if (ownerType == AuctionOwnerType.customer) {
      ownerInfo = json['customer'] != null ? OwnerInfo.fromJson(json['customer']) : null;
    }

    return AuctionProductDetails(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      ownerId: json['owner_id'],
      ownerType: ownerType,
      ownerInfo: ownerInfo,
      details: json['details'],
      itemCondition: json['item_condition'],

      shippingFee: parseDouble(json['shipping_fee']),
      returnPolicy: json['return_policy'],

      startingPrice: parseDouble(json['starting_price']),
      highestBidAmount: parseDouble(json['highest_bid_amount']),
      minimumIncrementAmount: parseDouble(json['minimum_increment_amount']),
      maximumDecrementAmount: parseDouble(json['maximum_decrement_amount']),
      currentHighestBidAmount: parseDouble(json['current_highest_bid_amount']),

      totalViews: json['total_views'],
      totalBidsCount: json['total_bids_count'],

      startTime: json['start_time'],
      endTime: json['end_time'],

      totalTaxAmount: parseDouble(json['total_tax_amount']),

      thumbnailFullUrl: json['thumbnail_full_url'] != null
          ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url'])
          : null,

      imagesFullUrl: json['images_full_url'] != null
          ? List.from(json['images_full_url'])
          .map((e) => ThumbnailFullUrl.fromJson(e))
          .toList()
          : null,

      brand: json['brand'] != null
          ? Brand.fromJson(json['brand'])
          : null,

      bids: json['bids'] != null
          ? List.from(json['bids'])
          .map((e) => Bid.fromJson(e))
          .toList()
          : null,

      myParticipation: json['my_participation'] != null
          ? MyParticipation.fromJson(json['my_participation'])
          : null,

      myBid: json['my_bid'] != null
          ? MyBid.fromJson(json['my_bid'])
          : null,

      shippingAddressId: json['shipping_address_id'],
      shippingAddressInfo: json['shipping_address_info'] != null ? AddressInfo.fromJson(json['shipping_address_info']) : null,
      billingAddress: json['billing_address'],
      billingAddressInfo: json['billing_address_info'] != null ? AddressInfo.fromJson(json['billing_address_info']) : null,

      totalParticipants: json['total_participants'],
      participantsCount: json['participants_count'],
      totalParticipantsCount: json['total_participants_count'],

      hasReadyToDeliveryParticipantSignal:
      json['has_ready_to_delivery_participant_signal'],
      hasOnTheWayParticipantSignal:
      json['has_on_the_way_participant_signal'],
      hasPurchaseCompleteParticipantSignal:
      json['has_purchase_complete_participant_signal'],

      auctionStatus: AuctionParticipationStatus.fromString(json['auction_status']),

      myAuctionStatus: AuctionParticipationStatus.fromString(json['my_auction_status']),

      auctionOwnerStatus: json['auction_status']?.toString(),

      trackingUrl: json['tracking_url'],

      auctionInsights: json['auction_insights'] != null
          ? AuctionInsights.fromJson(json['auction_insights'])
          : null,
      mySavedProduct: json['my_saved_product'] != null
          ? MySavedProduct.fromJson(json['my_saved_product'])
          : null,
      videoProvider: json['video_provider'],
      youtubeVideoUrl: json['youtube_video_url'],
      customVideoUrlFullUrl: json['custom_video_url_full_url'] != null ? ThumbnailFullUrl.fromJson(json['custom_video_url_full_url']) : null,
      isAuctionSave: json['is_auction_save'] ?? false,
      isSameAddress: json['billing_same_as_shipping'] ?? false,
      secondHighestBid: json['second_highest_bid'] != null
          ? SecondHighestBid.fromJson(json['second_highest_bid'])
          : null,
      isAllBidWithdrawn: json['is_all_bid_withdrawn'] ?? false,
    );
  }
}

class SimilarProduct {
  final int? id;
  final String? slug;
  final String? name;
  final double? highestBidAmount;
  final double? startingPrice;
  final AuctionParticipationStatus? auctionCurrentStatus;
  final AuctionDetails? auctionDetails;
  final ThumbnailFullUrl? thumbnailFullUrl;

  SimilarProduct({
    this.id,
    this.slug,
    this.name,
    this.highestBidAmount,
    this.startingPrice,
    this.auctionCurrentStatus,
    this.auctionDetails,
    this.thumbnailFullUrl,
  });

  factory SimilarProduct.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) =>
        value != null ? double.tryParse(value.toString()) : null;

    return SimilarProduct(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      highestBidAmount: parseDouble(json['highest_bid_amount']),
      startingPrice: parseDouble(json['starting_price']),
      auctionCurrentStatus: AuctionParticipationStatus.fromString(json['auction_current_status']),
      auctionDetails: json['auction_details'] != null ? AuctionDetails.fromJson(json['auction_details']) : null,
      thumbnailFullUrl: json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null,
    );
  }
}

class SameAuthorProduct {
  final int? id;
  final String? slug;
  final String? name;
  final double? highestBidAmount;
  final double? startingPrice;
  final AuctionParticipationStatus? auctionCurrentStatus;
  final AuctionDetails? auctionDetails;
  final ThumbnailFullUrl? thumbnailFullUrl;

  SameAuthorProduct({
    this.id,
    this.slug,
    this.name,
    this.highestBidAmount,
    this.startingPrice,
    this.auctionCurrentStatus,
    this.auctionDetails,
    this.thumbnailFullUrl,
  });

  factory SameAuthorProduct.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) =>
        value != null ? double.tryParse(value.toString()) : null;

    return SameAuthorProduct(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      highestBidAmount: parseDouble(json['highest_bid_amount']),
      startingPrice: parseDouble(json['starting_price']),
      auctionCurrentStatus: AuctionParticipationStatus.fromString(json['auction_current_status']),
      auctionDetails: json['auction_details'] != null ? AuctionDetails.fromJson(json['auction_details']) : null,
      thumbnailFullUrl: json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null,
    );
  }
}

class Brand {
  final int? id;
  final String? name;
  final String? image;

  Brand({this.id, this.name, this.image});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}

class Bid {
  final double? bidAmount;
  final String? bidTime;
  final Customer? customer;

  Bid({this.bidAmount, this.bidTime, this.customer});

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      bidAmount: json['bid_amount'] != null
          ? double.tryParse(json['bid_amount'].toString())
          : null,
      bidTime: json['bid_time'],
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
    );
  }
}

class Customer {
  final int? id;
  final String? fName;
  final String? lName;
  final String? image;
  final ThumbnailFullUrl? imageFullUrl;

  Customer({
    this.id,
    this.fName,
    this.lName,
    this.image,
    this.imageFullUrl,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      fName: json['f_name'],
      lName: json['l_name'],
      image: json['image'],
      imageFullUrl: json['image_full_url'] != null
          ? ThumbnailFullUrl.fromJson(json['image_full_url'])
          : null,
    );
  }
}

class AuctionDetails {
  final String? startTime;
  final String? endTime;
  final double? highestBidAmount;
  final int? totalBids;
  final int? totalParticipants;
  final int? totalViews;
  final String? status;

  AuctionDetails({
    this.startTime,
    this.endTime,
    this.highestBidAmount,
    this.totalBids,
    this.totalParticipants,
    this.totalViews,
    this.status,
  });

  factory AuctionDetails.fromJson(Map<String, dynamic> json) {
    return AuctionDetails(
      startTime: json['start_time'],
      endTime: json['end_time'],
      highestBidAmount: json['highest_bid_amount'] != null
          ? double.tryParse(json['highest_bid_amount'].toString())
          : null,
      totalBids: json['total_bids'],
      totalParticipants: json['total_participants'],
      totalViews: json['total_views'],
      status: json['status'],
    );
  }
}

class AddressInfo {
  final String? zip;
  final String? city;
  final String? phone;
  final String? address;
  final String? country;
  final String? contactPersonName;

  AddressInfo({
    this.zip,
    this.city,
    this.phone,
    this.address,
    this.country,
    this.contactPersonName,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      zip: json['zip']?.toString(),
      city: json['city']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      country: json['country']?.toString(),
      contactPersonName: json['contact_person_name']?.toString(),
    );
  }
}

class ThumbnailFullUrl {
  final String? key;
  final String? path;
  final int? status;

  ThumbnailFullUrl({this.key, this.path, this.status});

  factory ThumbnailFullUrl.fromJson(Map<String, dynamic> json) {
    return ThumbnailFullUrl(
      key: json['key'],
      path: json['path'],
      status: json['status'],
    );
  }
}

class MyParticipation {
  final int? id;
  final int? auctionProductId;
  final int? userId;
  final String? entryFeePaidStatus;
  final double? entryFeePaidAmount;
  final String? entryFeePaymentMethod;
  final String? entryFeePaymentStatus;
  final String? entryFeeDeniedNote;
  final String? joinedAt;
  final int? transactionId;
  final String? createdAt;
  final String? updatedAt;
  final AuctionTransaction? auctionTransaction;

  MyParticipation({
    this.id,
    this.auctionProductId,
    this.userId,
    this.entryFeePaidStatus,
    this.entryFeePaidAmount,
    this.entryFeePaymentMethod,
    this.entryFeePaymentStatus,
    this.entryFeeDeniedNote,
    this.joinedAt,
    this.transactionId,
    this.createdAt,
    this.updatedAt,
    this.auctionTransaction,
  });

  factory MyParticipation.fromJson(Map<String, dynamic> json) {
    return MyParticipation(
      id: json['id'],
      auctionProductId: json['auction_product_id'],
      userId: json['user_id'],
      entryFeePaidStatus: json['entry_fee_paid_status']?.toString(),
      entryFeePaidAmount: json['entry_fee_paid_amount'] != null ? double.tryParse(json['entry_fee_paid_amount'].toString()) : null,
      entryFeePaymentMethod: json['entry_fee_payment_method']?.toString(),
      entryFeePaymentStatus: json['entry_fee_payment_status']?.toString(),
      entryFeeDeniedNote: json['entry_fee_denied_note']?.toString(),
      joinedAt: json['joined_at']?.toString(),
      transactionId: json['transaction_id'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      auctionTransaction: json['auction_transaction'] != null ? AuctionTransaction.fromJson(json['auction_transaction']) : null,
    );
  }
}

class MethodInformations {
  final String? mobileNumber;
  final String? transactionId;
  final String? date;
  final String? reference;

  MethodInformations({this.mobileNumber, this.transactionId, this.date, this.reference});

  factory MethodInformations.fromJson(Map<String, dynamic> json) => MethodInformations(
    mobileNumber: json['mobile_number']?.toString(),
    transactionId: json['transaction_id']?.toString(),
    date: json['date']?.toString(),
    reference: json['reference']?.toString(),
  );
}

class AuctionTransactionPaymentInfo {
  final String? paymentNote;
  final int? methodId;
  final String? methodName;
  final MethodInformations? methodInformations;

  AuctionTransactionPaymentInfo({this.paymentNote, this.methodId, this.methodName, this.methodInformations});

  factory AuctionTransactionPaymentInfo.fromJson(Map<String, dynamic> json) => AuctionTransactionPaymentInfo(
    paymentNote: json['payment_note']?.toString(),
    methodId: json['method_id'],
    methodName: json['method_name']?.toString(),
    methodInformations: json['method_informations'] != null
        ? MethodInformations.fromJson(json['method_informations'])
        : null,
  );
}

class AuctionTransaction {
  final int? id;
  final double? amount;
  final String? currencyCode;
  final String? paymentMethod;
  final AuctionTransactionPaymentInfo? paymentInfo;
  final String? paymentStatus;

  AuctionTransaction({this.id, this.amount, this.currencyCode, this.paymentMethod, this.paymentInfo, this.paymentStatus});

  factory AuctionTransaction.fromJson(Map<String, dynamic> json) => AuctionTransaction(
    id: json['id'],
    amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
    currencyCode: json['currency_code']?.toString(),
    paymentMethod: json['payment_method']?.toString(),
    paymentInfo: json['payment_info'] != null
        ? AuctionTransactionPaymentInfo.fromJson(
            json['payment_info'] is String ? Map<String, dynamic>.from(jsonDecode(json['payment_info'])) : json['payment_info'] as Map<String, dynamic>) : null,
    paymentStatus: json['payment_status']?.toString(),
  );
}

class SecondHighestBid {
  final int? id;
  final int? auctionProductId;
  final int? userId;
  final double? bidAmount;
  final String? bidTime;

  SecondHighestBid({
    this.id,
    this.auctionProductId,
    this.userId,
    this.bidAmount,
    this.bidTime,
  });

  factory SecondHighestBid.fromJson(Map<String, dynamic> json) {
    return SecondHighestBid(
      id: json['id'],
      auctionProductId: json['auction_product_id'],
      userId: json['user_id'],
      bidAmount: json['bid_amount'] != null ? double.tryParse(json['bid_amount'].toString()) : null,
      bidTime: json['bid_time'],
    );
  }
}

class MyBid {
  final int? id;
  final int? auctionProductId;
  final int? userId;
  final double? bidAmount;
  final bool? isAutoBid;
  final bool? isWithdrawBid;
  final String? bidTime;
  final String? claimStartTime;
  final bool? isLeadBid;
  final bool? isMyBid;
  final bool? isRollbackBid;

  MyBid({
    this.id,
    this.auctionProductId,
    this.userId,
    this.bidAmount,
    this.isAutoBid,
    this.isWithdrawBid,
    this.bidTime,
    this.claimStartTime,
    this.isLeadBid,
    this.isMyBid,
    this.isRollbackBid,
  });

  factory MyBid.fromJson(Map<String, dynamic> json) {
    return MyBid(
      id: json['id'],
      auctionProductId: json['auction_product_id'],
      userId: json['user_id'],
      bidAmount: json['bid_amount'] != null
          ? double.tryParse(json['bid_amount'].toString())
          : null,
      isAutoBid: json['is_auto_bid'],
      isWithdrawBid: json['is_withdraw_bid'],
      bidTime: json['bid_time'],
      claimStartTime: json['claim_start_time'],
      isLeadBid: json['is_lead_bid'],
      isMyBid: json['is_my_bid'],
      isRollbackBid: json['is_rollback_bid'],
    );
  }
}

class PaymentInfo {
  final PaymentStatus? paymentStatus;
  final String? paymentMethod;
  final double? paidAmount;
  final String? transactionRef;
  final String? currencyCode;

  PaymentInfo({
    this.paymentStatus,
    this.paymentMethod,
    this.paidAmount,
    this.transactionRef,
    this.currencyCode,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      paymentStatus: PaymentStatus.fromString(json['payment_status']),
      paymentMethod: json['payment_method'],
      paidAmount: json['paid_amount'] != null ? double.tryParse(json['paid_amount'].toString()) : null,
      transactionRef: json['transaction_ref'],
      currencyCode: json['currency_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_status': paymentStatus?.toJson(),
      'payment_method': paymentMethod,
      'paid_amount': paidAmount,
      'transaction_ref': transactionRef,
      'currency_code': currencyCode,
    };
  }
}

class BillingInfo {
  final double? productPrice;
  final double? winningBid;
  final double? shippingFee;
  final double? taxAmount;
  final String? taxType;
  final int? paidBy;

  BillingInfo({
    this.productPrice,
    this.winningBid,
    this.shippingFee,
    this.taxAmount,
    this.taxType,
    this.paidBy,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) {
    return BillingInfo(
      productPrice: json['product_price'] != null
          ? double.tryParse(json['product_price'].toString())
          : null,
      winningBid: json['winning_bid'] != null
          ? double.tryParse(json['winning_bid'].toString())
          : null,
      shippingFee: json['shipping_fee'] != null
          ? double.tryParse(json['shipping_fee'].toString())
          : null,
      taxAmount: json['tax_amount'] != null
          ? double.tryParse(json['tax_amount'].toString())
          : null,
      taxType: json['tax_type'],
      paidBy: json['paid_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_price': productPrice,
      'winning_bid': winningBid,
      'shipping_fee': shippingFee,
      'tax_amount': taxAmount,
      'tax_type': taxType,
      'paid_by': paidBy,
    };
  }
}

class OwnerInfo {
  final int? id;
  final String? fName;
  final String? lName;
  final String? image;
  final ThumbnailFullUrl? imageFullUrl;

  OwnerInfo({
    this.id,
    this.fName,
    this.lName,
    this.image,
    this.imageFullUrl,
  });

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      id: json['id'],
      fName: json['f_name'],
      lName: json['l_name'],
      image: json['image'],
      imageFullUrl: json['image_full_url'] != null
          ? ThumbnailFullUrl.fromJson(json['image_full_url'])
          : null,
    );
  }
}

class AuctionInsights {
  final int? totalBids;
  final double? avgBidIncrease;
  final double? highestJump;

  AuctionInsights({
    this.totalBids,
    this.avgBidIncrease,
    this.highestJump,
  });

  factory AuctionInsights.fromJson(Map<String, dynamic> json) {
    return AuctionInsights(
      totalBids: json['total_bids'],
      avgBidIncrease: json['avg_bid_increase'] != null
          ? double.tryParse(json['avg_bid_increase'].toString())
          : null,
      highestJump: json['highest_jump'] != null
          ? double.tryParse(json['highest_jump'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bids': totalBids,
      'avg_bid_increase': avgBidIncrease,
      'highest_jump': highestJump,
    };
  }
}

class MySavedProduct {
  final int? id;
  final int? auctionProductId;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;

  MySavedProduct({
    this.id,
    this.auctionProductId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory MySavedProduct.fromJson(Map<String, dynamic> json) {
    return MySavedProduct(
      id: json['id'],
      auctionProductId: json['auction_product_id'],
      userId: json['user_id'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}