import 'package:equatable/equatable.dart';

/// A delivery area. Plans and their prices are defined per zone.
class DeliveryZone extends Equatable {
  final int id;
  final String name;

  const DeliveryZone({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
