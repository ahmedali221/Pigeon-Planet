class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'غير مصرح لك بهذا الإجراء'])
      : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'لا تملك صلاحية الوصول'])
      : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'المورد غير موجود'])
      : super(statusCode: 404);
}

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;

  const ValidationException(super.message, {required this.errors})
      : super(statusCode: 400);
}

class ServerException extends ApiException {
  const ServerException([super.message = 'حدث خطأ في الخادم'])
      : super(statusCode: 500);
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'تحقق من اتصالك بالإنترنت'])
      : super(statusCode: null);
}
