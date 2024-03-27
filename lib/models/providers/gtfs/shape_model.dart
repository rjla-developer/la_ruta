class Shape {
  final double shapeId;
  final double shapePtLat;
  final double shapePtLon;
  final int shapePtSequence;
  final int stopSequence;

  Shape(
      {required this.shapeId,
      required this.shapePtLat,
      required this.shapePtLon,
      required this.shapePtSequence,
      required this.stopSequence});

  factory Shape.fromList(List<String> data) {
    return Shape(
      shapeId: double.parse(data[0]),
      shapePtLat: double.parse(data[1]),
      shapePtLon: double.parse(data[2]),
      shapePtSequence: int.parse(data[3]),
      stopSequence: int.parse(data[4]),
    );
  }

  @override
  String toString() {
    return 'Shape(shapeId: $shapeId, shapePtLat: $shapePtLat, shapePtLon: $shapePtLon, shapePtSequence: $shapePtSequence, stopSequence: $stopSequence)';
  }
}
