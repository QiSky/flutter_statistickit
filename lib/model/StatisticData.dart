class StatisticData {
  String? package;

  String? identify;

  late final String event;

  late Map<String, dynamic> data;

  StatisticData(
    this.event,
    this.data, {
    this.package,
    this.identify,
  });

  Map<String, dynamic> toJson() {
    return {
      "package": package ?? '',
      "identify": identify ?? '',
      "event": event,
      "data": data
    };
  }
}
