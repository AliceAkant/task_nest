import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';

class DataSourceHelper {
  static Future<Either<Failure, T>> executeSafe<T>({
    required Future<T> Function() action,
    String errorTitle = 'Local storage error',
  }) async {
    try {
      final result = await action();

      return Right(result);
    } catch (e) {
      return Left(LocalStorageFailure('$errorTitle: $e'));
    }
  }
}
