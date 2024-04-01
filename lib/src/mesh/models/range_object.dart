import 'package:equatable/equatable.dart';

import '../types.dart';

// TODO: freezed?

// https://github.com/NordicSemiconductor/IOS-nRF-Mesh-Library/blob/main/Library/Mesh%20Model/RangeObject.swift

/// A base class for an address or scene range.
///
/// Ranges are assigned to ``Provisioner`` objects. Each Provisioner
/// may provision new Nodes, create Groups and Scenes using only values
/// from assigned ranges. The assigned ranges may not overlap with the ranges
/// of other Provisioners, otherwise different instances could reuse the same
/// values leading to collisions.

class RangeObject extends Equatable {
  const RangeObject({
    required this.lowerBound,
    required this.upperBound,
  });

  final Uint16 lowerBound;
  final Uint16 upperBound;

  // equatable

  @override
  List<Object> get props => [lowerBound, upperBound];

  bool overlapsWith(RangeObject other) {
    return lowerBound <= other.upperBound && upperBound >= other.lowerBound;
  }
}
