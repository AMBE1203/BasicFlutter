part of net;

class ExceptionHandle {
  ///Server Response
  static const int success = 0;
  static const int http_success = 200;
  static const int unknown_error = 1;
  static const int wrong_data_format = 2;
  static const int invalid_account = 9;
  static const int username_not_found = 10;
  static const int invalid_email = 11;
  static const int username_registed = 12;
  static const int invalid_birthday = 15;
  static const int unusable_email = 16;
  static const int invalid_phone = 26;
  static const int duplicate_user_name = 17;
  static const int nickname_registered = 18;
  static const int incorrect_password = 20;
  static const int invalid_password = 21;
  static const int user_not_exist = 80;
  static const int lock_user = 81;
  static const int access_denied = 41;
  static const int max_shop_create = 23;
  static const int invalid_kol = 101;
  static const int hired_kol = 102;
  static const int invalid_hired_time = 103;
  static const int shop_default_existed = 105;

  /// dio Response
  static const int success_not_content = 204;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int not_found = 404;
  static const int timeout = 500;

  /// Client Response
  static const int net_error = 1000;
  static const int parse_error = 1001;
  static const int socket_error = 1002;
  static const int http_error = 1003;
  static const int timeout_error = 1004;
  static const int cancel_error = 1005;
  static const int force_logout = 1006;
  static const int client_unknown_error = 9999;

  static NetError handleException(dynamic error) {
    print(error);
    if (error is DioError) {
      if (error.type == DioErrorType.DEFAULT ||
          error.type == DioErrorType.RESPONSE) {
        final dynamic e = error.error;
        if (e is SocketException) {
          return NetError(
              socket_error, 'Network exception, please check your network!');
        }
        if (e is HttpException) {
          return NetError(http_error, 'Server exception!');
        }
        return NetError(client_unknown_error, 'Unknown exception');
      } else if (error.type == DioErrorType.CONNECT_TIMEOUT ||
          error.type == DioErrorType.SEND_TIMEOUT ||
          error.type == DioErrorType.RECEIVE_TIMEOUT) {
        return NetError(timeout_error, 'Connection timed out! ');
      } else if (error.type == DioErrorType.CANCEL) {
        return NetError(cancel_error, 'Cancel request');
      } else {
        return NetError(client_unknown_error, 'Unknown exception');
      }
    } else {
      return NetError(client_unknown_error, 'Unknown exception');
    }
  }
}

class NetError {
  NetError(this.code, this.msg);

  int code;
  String msg;
}
