// @see https://suragch.medium.com/working-with-bytes-in-dart-6ece83455721

// TODO: make real types to prevent accidental misuse?

typedef Data = List<int>; // typed_data.Uint8List;
typedef Uint16 = int;
typedef Uint8 = int;
typedef Uint32 = int;
typedef UUID = String;

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
