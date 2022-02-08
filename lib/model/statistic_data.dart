class StatisticData {
  String? packages;

  String? identify;

  late final String event;

  late Map<String, dynamic> data;

  late final int time = DateTime.now().millisecondsSinceEpoch;

  StatisticData(
    this.event,
    this.data, {
    this.packages,
    this.identify,
  });

  Map<String, dynamic> toJson() {
    return {
      "packages": packages ?? '',
      "identify": identify ?? '',
      "event": event,
      "data": data,
      "time": time
    };
  }
}
