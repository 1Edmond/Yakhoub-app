class CourierTrackingEventModel {
  String? status;
  String? label;
  String? tone;
  String? time;
  String? description;

  CourierTrackingEventModel({
    this.status,
    this.label,
    this.tone,
    this.time,
    this.description,
  });

  factory CourierTrackingEventModel.fromJson(Map<String, dynamic> json) {
    return CourierTrackingEventModel(
      status: json['status']?.toString(),
      label: json['label']?.toString(),
      tone: json['tone']?.toString(),
      time: json['time']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
