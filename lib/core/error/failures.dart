import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'تحقق من اتصالك بالإنترنت']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'رقم الهاتف أو كلمة المرور غير صحيحة']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'المورد غير موجود']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'لا تملك صلاحية الوصول']);
}
