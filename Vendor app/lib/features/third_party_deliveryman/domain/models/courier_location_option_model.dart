class CourierLocationOptionModel {
  String? id;
  String? name;

  CourierLocationOptionModel({this.id, this.name});

  factory CourierLocationOptionModel.fromJson(Map<String, dynamic> json) {
    return CourierLocationOptionModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }
}
