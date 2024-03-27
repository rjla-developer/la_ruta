class TripModel {
  final String tripId;
  final double routeId;
  final String serviceId;
  final double shapeId;

  TripModel(
      {required this.tripId,
      required this.routeId,
      required this.serviceId,
      required this.shapeId});

  factory TripModel.fromList(List<String> data) {
    return TripModel(
      tripId: data[0],
      routeId: double.parse(data[1]),
      serviceId: data[2],
      shapeId: double.parse(data[3]),
    );
  }

  @override
  String toString() {
    return 'TripModel(tripId: $tripId, routeId: $routeId, serviceId: $serviceId, shapeId: $shapeId)';
  }
}
