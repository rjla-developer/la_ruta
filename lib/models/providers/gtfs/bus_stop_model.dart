class BusStop {
  final double routeId;
  final int stopId;
  final int stopSequence;

  BusStop(
      {required this.routeId,
      required this.stopId,
      required this.stopSequence});

  factory BusStop.fromList(List<String> data) {
    return BusStop(
      routeId: double.parse(data[0]),
      stopId: int.parse(data[1]),
      stopSequence: int.parse(data[2]),
    );
  }

  @override
  String toString() {
    return 'BusStop(routeId: $routeId, stopId: $stopId, stopSequence: $stopSequence)';
  }
}
