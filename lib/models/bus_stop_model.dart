class BusStopModel {
  final double routeId;
  final int stopId;
  final int stopSequence;

  BusStopModel(
      {required this.routeId,
      required this.stopId,
      required this.stopSequence});

  factory BusStopModel.fromList(List<String> data) {
    return BusStopModel(
      routeId: double.parse(data[0]),
      stopId: int.parse(data[1]),
      stopSequence: int.parse(data[2]),
    );
  }

  @override
  String toString() {
    return 'BusStopModel(routeId: $routeId, stopId: $stopId, stopSequence: $stopSequence)';
  }
}
