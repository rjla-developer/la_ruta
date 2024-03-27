class Stop {
  final int stopId;
  final String stopName;
  final double stopLat;
  final double stopLon;

  Stop(
      {required this.stopId,
      required this.stopName,
      required this.stopLat,
      required this.stopLon});

  factory Stop.fromList(List<String> data) {
    return Stop(
      stopId: int.parse(data[0]),
      stopName: data[1],
      stopLat: double.parse(data[2]),
      stopLon: double.parse(data[3]),
    );
  }

  @override
  String toString() {
    return 'Stop(stopId: $stopId, stopName: $stopName, stopLat: $stopLat, stopLon: $stopLon)';
  }
}
