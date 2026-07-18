// TODO (docs)

///
///A simple implementation of the Result type, which can be used to represent the result of an operation that can either succeed or fail.
///
///The Result type is a generic type that takes two type parameters: T, which represents the
///type of the value that is returned when the operation succeeds, and E, which represents the type of the error that is returned when the operation fails.
///
///The Result type has two subclasses: Ok, which represents a successful result, and Error, which represents a failed result.
///The Result type also has a when method, which can be used to handle the result of an operation in a functional way, and a getOrElse method, which can be used to get the value of a successful result or return a default value if the result is an error.
///
///Example usage:
///```dart
///Future<Result<String, String>> fetchData() async {
///  try {
///    final response = await http.get(Uri.parse('https://api.example.com/data'));
///    if (response.statusCode == 200) {
///      return Ok(response.body);
///    } else {
///      return Error('Failed to fetch data: ${response.statusCode}');
///    }
///  } catch (e) {
///    return Error('Failed to fetch data: $e');
///  }
///}
///```
///
abstract class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isError => this is Error<T, E>;

  R when<R>({
    required R Function(T value) ok,
    required R Function(E error) error,
  }) {
    if (this is Ok<T, E>) {
      return ok((this as Ok<T, E>).value);
    }
    return error((this as Error<T, E>).error);
  }

  T getOrElse(T Function() orElse) {
    if (this is Ok<T, E>) {
      return (this as Ok<T, E>).value;
    }
    return orElse();
  }
}

class Ok<T, E> extends Result<T, E> {
  final T value;

  const Ok(this.value);

  @override
  String toString() => 'Ok - ($value)';
}

class Error<T, E> extends Result<T, E> {
  final E error;

  const Error(this.error);

  @override
  String toString() => 'Error - ($error)';
}