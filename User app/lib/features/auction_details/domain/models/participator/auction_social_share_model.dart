class AuctionSocialShareModel {
  final String link;

  AuctionSocialShareModel({
    required this.link,
  });

  factory AuctionSocialShareModel.fromJson(Map<String, dynamic> json) {
    return AuctionSocialShareModel(
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
    };
  }
}