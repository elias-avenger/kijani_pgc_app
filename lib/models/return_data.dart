class Data<T> {
  final bool status;
  final T? data;
  final String? message;

  Data({
    required this.status,
    this.data,
    this.message,
  });

  factory Data.success(T data) => Data(status: true, data: data);
  factory Data.failure(String message) => Data(status: false, message: message);
}
