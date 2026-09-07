class AiShoppingColorImageModel {
  final String? code;
  final String? url;

  const AiShoppingColorImageModel({this.code, this.url});

  factory AiShoppingColorImageModel.fromJson(Map<String, dynamic> json) {
    return AiShoppingColorImageModel(
      code: json['code'],
      url: json['url'],
    );
  }
}
