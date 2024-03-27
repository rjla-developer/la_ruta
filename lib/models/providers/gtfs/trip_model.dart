class Trip {
  final String tripId;
  final double routeId;
  final String serviceId;
  final double shapeId;

  Trip(
      {required this.tripId,
      required this.routeId,
      required this.serviceId,
      required this.shapeId});

  factory Trip.fromList(List<String> data) {
    return Trip(
      tripId: data[0],
      routeId: double.parse(data[1]),
      serviceId: data[2],
      shapeId: double.parse(data[3]),
    );
  }

  @override
  String toString() {
    return 'Trip(tripId: $tripId, routeId: $routeId, serviceId: $serviceId, shapeId: $shapeId)';
  }
}
