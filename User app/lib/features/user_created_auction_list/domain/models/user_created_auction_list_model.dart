class AuctionCounts {
  final int upcoming;
  final int live;
  final int readyToClaim;
  final int purchaseComplete;
  final int readyToDelivery;
  final int onTheWay;
  final int delivered;
  final int unsold;
  final int canceled;

  const AuctionCounts({
    this.upcoming = 0,
    this.live = 0,
    this.readyToClaim = 0,
    this.purchaseComplete = 0,
    this.readyToDelivery = 0,
    this.onTheWay = 0,
    this.delivered = 0,
    this.unsold = 0,
    this.canceled = 0,
  });

  int get total => upcoming + live + readyToClaim + purchaseComplete + readyToDelivery + onTheWay + delivered + unsold + canceled;

  factory AuctionCounts.fromJson(Map<String, dynamic> json) {
    return AuctionCounts(
      upcoming: json['upcoming'] as int? ?? 0,
      live: json['live'] as int? ?? 0,
      readyToClaim: json['ready_to_claim'] as int? ?? 0,
      purchaseComplete: json['purchase_complete'] as int? ?? 0,
      readyToDelivery: json['ready_to_delivery'] as int? ?? 0,
      onTheWay: json['on_the_way'] as int? ?? 0,
      delivered: json['delivered'] as int? ?? 0,
      unsold: json['unsold'] as int? ?? 0,
      canceled: json['canceled'] as int? ?? 0,
    );
  }
}

class UserCreatedAuctionListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<UserCreatedAuctionProduct>? products;
  AuctionCounts? counts;

  UserCreatedAuctionListModel({this.totalSize, this.limit, this.offset, this.products, this.counts});

  UserCreatedAuctionListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['products'] != null) {
      products = <UserCreatedAuctionProduct>[];
      for (var v in json['products']) {
        products!.add(UserCreatedAuctionProduct.fromJson(v));
      }
    }
    counts = json['counts'] != null ? AuctionCounts.fromJson(json['counts']) : null;
  }
}

class UserCreatedAuctionProduct {
  int? id;
  String? slug;
  String? name;
  String? productType;
  double? startingPrice;
  double? adminCommission;
  bool? isAdminCommissionPaid;
  bool? isRelaunched;
  ThumbnailFullUrl? thumbnailFullUrl;
  UserCreatedAuctionDetails? auctionDetails;
  ClaimTransaction? claimTransaction;

  UserCreatedAuctionProduct({
    this.id,
    this.slug,
    this.name,
    this.productType,
    this.startingPrice,
    this.adminCommission,
    this.isAdminCommissionPaid,
    this.isRelaunched,
    this.thumbnailFullUrl,
    this.auctionDetails,
    this.claimTransaction,
  });

  UserCreatedAuctionProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    productType = json['product_type'];
    startingPrice = json['starting_price'] != null ? double.tryParse(json['starting_price'].toString()) : null;
    adminCommission = json['admin_commission'] != null ? double.tryParse(json['admin_commission'].toString()) : null;
    isAdminCommissionPaid = json['admin_commission_given'];
    isRelaunched = json['is_relaunched'] as bool?;
    thumbnailFullUrl = json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null;
    auctionDetails = json['auction_details'] != null ? UserCreatedAuctionDetails.fromJson(json['auction_details']) : null;
    claimTransaction = json['claim_transaction'] != null ? ClaimTransaction.fromJson(json['claim_transaction']) : null;
  }
}

class UserCreatedAuctionDetails {
  String? startTime;
  String? endTime;
  double? highestBidAmount;
  int? totalBids;
  int? totalParticipants;
  int? totalViews;
  String? status;
  String? deliveryStatus;

  UserCreatedAuctionDetails({
    this.startTime,
    this.endTime,
    this.highestBidAmount,
    this.totalBids,
    this.totalParticipants,
    this.totalViews,
    this.status,
    this.deliveryStatus,
  });

  UserCreatedAuctionDetails.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse(json['highest_bid_amount'].toString()) : null;
    totalBids = json['total_bids'];
    totalParticipants = json['total_participants'];
    totalViews = json['total_views'];
    status = json['status'];
    deliveryStatus = json['delivery_status'];
  }
}


class ThumbnailFullUrl {
  String? key;
  String? path;
  int? status;

  ThumbnailFullUrl({this.key, this.path, this.status});

  ThumbnailFullUrl.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    path = json['path'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['path'] = path;
    data['status'] = status;
    return data;
  }
}

class ClaimTransaction {
  final int? id;
  final int? auctionProductId;
  final String? paymentMethod;
  final String? type;
  final String? paymentStatus;

  const ClaimTransaction({
    this.id,
    this.auctionProductId,
    this.paymentMethod,
    this.type,
    this.paymentStatus,
  });

  factory ClaimTransaction.fromJson(Map<String, dynamic> json) {
    return ClaimTransaction(
      id: json['id'] as int?,
      auctionProductId: json['auction_product_id'] as int?,
      paymentMethod: json['payment_method'] as String?,
      type: json['type'] as String?,
      paymentStatus: json['payment_status'] as String?,
    );
  }
}