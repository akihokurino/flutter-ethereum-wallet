import 'dart:isolate';

class AppError extends RemoteError {
  AppError(String message, {int? statusCode}) : super(message, "");
}
