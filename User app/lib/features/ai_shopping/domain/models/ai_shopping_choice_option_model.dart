class AiShoppingChoiceOptionModel {
  final String? name;
  final String? title;
  final List<String> options;

  const AiShoppingChoiceOptionModel({
    this.name,
    this.title,
    required this.options,
  });

  factory AiShoppingChoiceOptionModel.fromJson(Map<String, dynamic> json) {
    return AiShoppingChoiceOptionModel(
      name: json['name'],
      title: json['title'],
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
