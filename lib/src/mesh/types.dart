// @see https://suragch.medium.com/working-with-bytes-in-dart-6ece83455721

// TODO: make real types to prevent accidental misuse?

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:uuid/uuid.dart';

typedef Data = List<int>; // typed_data.Uint8List;
typedef Uint16 = int;
typedef Uint8 = int;
typedef Uint32 = int;

// TODO: use Guid instead?
class UUID {
  final String _uuidString;

  // Constructor for creating a new UUID
  UUID() : _uuidString = const Uuid().v4();

  /// Constructor for creating a UUID from an existing string
  /// TODO: validate the string
  const UUID.fromString(String uuidString) : _uuidString = uuidString;

  // Getter to retrieve the UUID string
  String get uuidString => _uuidString;

  @override
  String toString() => _uuidString;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UUID &&
          runtimeType == other.runtimeType &&
          _uuidString == other._uuidString;

  @override
  int get hashCode => _uuidString.hashCode;

  String get hex => _uuidString.replaceAll('-', '');

  Data get data {
    final hex = this.hex;
    return List<int>.generate(
      hex.length ~/ 2,
      (i) => int.parse(
        hex.substring(i * 2, i * 2 + 2),
        radix: 16,
      ),
    );
  }
}

extension GuidX on Guid {
  UUID toUUID() => UUID.fromString(str);
}

/// Base Result class
/// [S] represents the type of the success value
// sealed class Result<S> {
//   const Result();
// }

// TODO use own result type

// final class Success<S> extends Result<S> {
//   const Success(this.value);
//   final S value;
// }

// final class Failure<S> extends Result<S> {
//   const Failure(this.error);
//   final Object error;
// }

// // factory
// Result<S> value<S>(S value) {
//   return Success(value);
// }

// Result<S> error<S>(Object error) {
//   return Failure(error);
// }

/// Base Result class
/// [S] represents the type of the success value
/// [E] should be [Exception] or a subclass of it
// sealed class Result<S, E extends Exception> {
//   const Result();
// }

// final class Success<S, E extends Exception> extends Result<S, E> {
//   const Success(this.value);
//   final S value;
// }

// final class Failure<S, E extends Exception> extends Result<S, E> {
//   const Failure(this.exception);
//   final E exception;
// }

class Range<T extends Comparable> {
  T start;
  T end;

  Range(this.start, this.end) {
    if (start.compareTo(end) > 0) {
      throw ArgumentError('Start must be less than or equal to end');
    }
  }

  bool contains(T value) =>
      value.compareTo(start) >= 0 && value.compareTo(end) <= 0;

  @override
  String toString() => '[$start, $end]';

  bool overlaps(Range<T> other) =>
      start.compareTo(other.end) <= 0 && end.compareTo(other.start) >= 0;
}
