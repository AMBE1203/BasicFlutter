part of net;

const String SLASH = '\"';
const String MESSAGE = 'message';
const String STATUS = 'status';
const String ERROR = 'error';
const String DATA = 'data';

const String NO_RETURN_INFO = '{\"content\":\"No return information\"}';

const String DEFAULT =
    '{\"status\":${ExceptionHandle.success},\"message\":\"\",\"error\":\"\",\"data\":{\"content\":\"No return information\"}}';

const String NOT_FOUND = '\"No query information found\"';

const String FAILURE_FORMAT =
    '{\"status\":%d,\"message\":%s,\"error\":%s,\"data\":{\"content\":\"error\"}}';
const String SUCCESS_FORMAT =
    '{\"status\":%d,\"message\":\"\",\"error\":\"\",\"data\":%s}';

const String SUCCESS_FORMAT_NO_RETURN_INFO =
    '{\"status\":%d,\"message\":%s,\"error\":%s,\"data\":$NO_RETURN_INFO}';

class AuthInterceptor extends Interceptor {
  @override
  onRequest(RequestOptions options) {
    UserPrefs.getToken().then((token) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    });
    return super.onRequest(options);
  }
}

class TokenInterceptor extends Interceptor {

  DateTime startTime;
  DateTime endTime;
  final Dio _tokenDio = Dio();

  Future<String> getToken() async {
    startTime = DateTime.now();

    try {
      _tokenDio.options = DioUtils.instance.getDio.options;

      final email = await UserPrefs.getEmail();
      final pass = await UserPrefs.getPassword();
      final version = await UserPrefs.getVersion();
      final deviceId = await UserPrefs.getDeviceId();
      final deviceName = await UserPrefs.getDeviceName();
      final deviceType = await UserPrefs.getDeviceType();
      final osVersion = await UserPrefs.getOsVersion();

      final request = SignInReq(
        email: email,
        password: pass,
        appVersion: version,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceType: deviceType,
        osVersion: osVersion,
        notifyToken: '',
      );

      final response =
          await _tokenDio.post(HttpApi.login, data: request.toJson());

      endTime = DateTime.now();
      final int duration = endTime.difference(startTime).inMilliseconds;
      final String header = '【Relogin】\n'
          'Url: ${response.request.baseUrl + response.request.path}\n'
          'RequestMethod: ${response.request.method}\n'
          'RequestHeaders: ${response.request.headers.toString()}\n'
          'RequestContentType: ${response.request.contentType}\n'
          'RequestExtra: ${response.request.extra}\n'
          'RequestData: ${response.request.data.toString()}\n'
          'ResponseCode: ${response.statusCode}\n'
          'End: $duration millisecond';
      ResponseLogger(header, response.data);


      if (response.statusCode == ExceptionHandle.http_success) {
        String result;
        String content = response.data == null ? '' : response.data.toString();
        if (content == null || content.isEmpty) content = DEFAULT;

        result =  formatSuccess(content);
        final baseEntity = BaseEntity.fromJson(jsonDecode(result));
        final json = jsonDecode(baseEntity.rowData);

        return SignInBean.fromJson(json)?.token;
      }
    } catch (e) {
      Log.severe('TokenInterceptor', 'Failed to refresh Token!');
    }
    return null;
  }

  @override
  onResponse(Response response) async {
    //401 represents the token expired
    if (response != null &&
        response.statusCode == ExceptionHandle.unauthorized) {

      final dio = DioUtils.instance.getDio;

      dio.interceptors.requestLock.lock();
      final accessToken = await getToken(); // Get the new accessToken
      dio.interceptors.requestLock.unlock();

      if (accessToken != null && accessToken.isNotEmpty) {
        UserPrefs.saveToken(accessToken); // save to cache
        dio.interceptors.requestLock.unlock();
        // Re-request failed interface
        final request = response.request;
        request.headers['Authorization'] = 'Bearer $accessToken';
        try {
          /// Avoid repeating the interceptor, using tokenDio
          final newResponse = await _tokenDio.request(request.path,
              data: request.data,
              queryParameters: request.queryParameters,
              cancelToken: request.cancelToken,
              options: request,
              onReceiveProgress: request.onReceiveProgress);
          return super.onResponse(newResponse);
        } on DioError catch (e) {
          return e;
        }
      }else{
        UserPrefs.clearLoginInfo();
        response.statusCode = ExceptionHandle.force_logout;
      }
    }
    return super.onResponse(response);
  }
}

class LoggingInterceptor extends Interceptor {
  DateTime startTime;
  DateTime endTime;
  RequestOptions options;

  @override
  onRequest(RequestOptions options) {
    startTime = DateTime.now();
    this.options = options;
    return super.onRequest(options);
  }

  @override
  onResponse(Response response) {
    endTime = DateTime.now();
    final int duration = endTime.difference(startTime).inMilliseconds;

    String url;
    if (response.request.queryParameters.isEmpty) {
      url = response.request.baseUrl + response.request.path;
    } else {
      url = response.request.baseUrl +
          response.request.path +
          '?' +
          Transformer.urlEncodeMap(response.request.queryParameters);
    }

    final String header = 'Url: $url\n'
        'RequestMethod: ${response.request.method}\n'
        'RequestHeaders: ${response.request.headers.toString()}\n'
        'RequestContentType: ${response.request.contentType}\n'
        'RequestExtra: ${response.request.extra}\n'
        'RequestData: ${response.request.data.toString()}\n'
        'ResponseCode: ${response.statusCode}\n'
        'End: $duration millisecond';
    ResponseLogger(header, response.data);
    return super.onResponse(response);
  }

  @override
  onError(DioError err) {
    endTime = DateTime.now();
    final int duration = endTime.difference(startTime).inMilliseconds;
    final String header = 'RequestMethod: ${options.method}\n'
        'RequestHeaders: ${options.headers.toString()}\n'
        'RequestContentType: ${options.contentType}\n'
        'RequestExtra: ${options.extra}\n'
        'RequestData: ${options.data.toString()}\n'
        'ResponseCode: \n'
        'End: $duration millisecond';
    ResponseLogger(header, 'Error: $err');
    return super.onError(err);
  }
}

class AdapterInterceptor extends Interceptor {
  @override
  Future onResponse(Response response) {
    final Response convertResponse = adapterData(response);
    return super.onResponse(convertResponse);
  }

  @override
  Future onError(DioError err) {
    if (err.response != null) {
      adapterData(err.response);
    }
    return super.onError(err);
  }

  Response adapterData(Response response) {
    String result;

    String content = response.data == null ? '' : response.data.toString();

    /// When successful, return directly to format
    if (response.statusCode == ExceptionHandle.success ||
        response.statusCode == ExceptionHandle.http_success ||
        response.statusCode == ExceptionHandle.success_not_content) {
      if (content == null || content.isEmpty) content = DEFAULT;

      result = formatSuccess(content);

      response.statusCode = ExceptionHandle.http_success;
    } else {
      if (response.statusCode == ExceptionHandle.not_found) {
        /// After the error data is formatted, it returns according to the success data.
        result = sprintf(
            FAILURE_FORMAT, [response.statusCode, NOT_FOUND, NOT_FOUND]);
        response.statusCode = ExceptionHandle.http_success;
      } else {
        if (content == null || content.isEmpty) {
          // Generally, the network is disconnected and other exceptions
          result = content;
        } else {
          try {
            result =
                formatFailure(FAILURE_FORMAT, content, response.statusCode);
            // When the 401 token fails, it is handled separately, and the others are all successful.
            if (response.statusCode == ExceptionHandle.unauthorized) {
              response.statusCode = ExceptionHandle.unauthorized;
            } else {
              response.statusCode = ExceptionHandle.http_success;
            }
          } catch (e) {
            Log.severe('AdapterInterceptor', 'Exception information: $e');
            // Parsing exceptions are handled directly by returning the original data (generally returning 500, 503 HTML page code)
            result = sprintf(FAILURE_FORMAT, [
              response.statusCode,
              'Server exception(${response.statusCode})',
              'Exception information: $e'
            ]);
          }
        }
      }
    }

    ResponseLogger('【Adapter Data】', result);
    response.data = result;
    return response;
  }
}

String formatSuccess(String content) {
  String result;

  final Map<String, dynamic> map = json.decode(content);
  int status = ExceptionHandle.client_unknown_error;
  if (map.containsKey(STATUS)) status = int.parse(jsonEncode(map[STATUS]));

  if (status == ExceptionHandle.success) {

    final String data = map.containsKey(DATA)
        ? jsonEncode(map[DATA])
        : NO_RETURN_INFO;

    result = sprintf(SUCCESS_FORMAT, [status, data]);
  } else {
    result = formatFailure(SUCCESS_FORMAT_NO_RETURN_INFO, content, status);
  }
  return result;
}

String formatFailure(String format, String content, int status) {
  String msg;
  String msgBody;

  String newContent = content.replaceAll('\\', '');

  if (SLASH == newContent.substring(0, 1)) {
    newContent = newContent.substring(1, newContent.length - 1);
  }

  final Map<String, dynamic> map = json.decode(newContent);
  if (map.containsKey(MESSAGE)) {
    msg = map[MESSAGE].toString();
  } else {
    msg = 'Unknown exception';
  }
  if (map.containsKey(ERROR)) {
    msgBody = map[ERROR].toString();
  } else {
    msgBody = 'Unknown exception';
  }

  // ignore: unrelated_type_equality_checks
  return sprintf(format, [
    status,
    // ignore: unrelated_type_equality_checks
    msg.runtimeType != 'String' ? '\"$msg\"' : msg,
    // ignore: unrelated_type_equality_checks
    msgBody.runtimeType != 'String' ? '\"$msgBody\"' : msgBody
  ]);
}
