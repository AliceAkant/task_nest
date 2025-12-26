import 'package:task_nest/core/logger/logger_service.dart';
import 'package:task_nest/infrastructure/di/injection.dart';

class LoggerHelper {
  static final LoggerService _logger = DI.container.get<LoggerService>();

  static void response(
    String method,
    String statusCode,
    String body,
    String? dataSent,
  ) {
    var logString =
        "[RESPONSE FOR]: \n[URI]: $method\n[status]: $statusCode\n[body]: $body";
    if (dataSent != null) {
      logString += "\n[data sent]: $dataSent";
    }
    _logger.info(logString);
  }

  static void info(String info) => _logger.info(info);

  static void databaseError(String error) =>
      _logger.error("[DATABASE]\n$error");

  static void databaseInfo(String info) => _logger.info("[DATABASE]\n$info");
}
