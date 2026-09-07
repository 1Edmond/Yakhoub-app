class AuctionSaveRequestModel {
  final int auctionProductId;

  AuctionSaveRequestModel({required this.auctionProductId});

  Map<String, dynamic> toJson() => {
    'auction_product_id': auctionProductId,
  };
}

class AuctionSaveResponseModel {
  final String message;
  final bool isSaved;

  AuctionSaveResponseModel({
    required this.message,
    required this.isSaved,
  });

  factory AuctionSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return AuctionSaveResponseModel(
      message: json['message'] ?? '',
      isSaved: json['is_saved'] ?? false,
    );
  }
}