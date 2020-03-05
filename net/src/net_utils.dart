part of net;

Map<String, dynamic> parseData(String data) {
  return json.decode(data);
}

enum Method { get, post, put, patch, delete, head }

class DioUtils {
  factory DioUtils() {
    return _singleton;
  }

  DioUtils._internal() {
    final options = BaseOptions(
      connectTimeout: 15000,
      receiveTimeout: 15000,
      responseType: ResponseType.plain,
      validateStatus: (status) {
        return true;
      },
      baseUrl: FlavorConfig.instance.values.baseUrl,
    );
    _dio = Dio(options);

    /// Unified add authentication request header
    _dio.interceptors.add(AuthInterceptor());

    /// Refresh Token
    _dio.interceptors.add(TokenInterceptor());

    /// Print Log (production mode removal)
    if (FlavorConfig.instance.flavor != Flavor.RELEASE) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    /// Adapt data (according to your own data structure, you can choose to add it)
    _dio.interceptors.add(AdapterInterceptor());
  }

  static final DioUtils _singleton = DioUtils._internal();

  static DioUtils get instance => DioUtils();

  static Dio _dio;

  Dio get getDio => _dio;

  static NetworkCheck networkCheck = NetworkCheck();

  asyncRequestNetwork(String path, Method method,
      {Function(Map<String, dynamic> json) onSuccess,
      Function(List<dynamic> list) onSuccessList,
      Function(int code, String msg) onError,
      dynamic data,
      Map<String, dynamic> queryParameters,
      Options options,
      bool isList = false}) {
    networkCheck.checkInternet((isNetworkPresent) {
      if (isNetworkPresent) {
        Log.info('DioUtils', 'network is connected!');
        final String m = _getRequestMethod(method);

        Observable.fromFuture(_request(m, path,
                isList: isList,
                data: data,
                queryParameters: queryParameters,
                options: options))
            .asBroadcastStream()
            .listen((result) {
          try {
            Log.info('DioUtils', 'Response result status: ${result.status}');
            if (result.status == ExceptionHandle.success) {
              final data = jsonDecode(result.rowData);
              if (data is List) {
                onSuccessList(data);
              } else {
                onSuccess(data);
              }
            } else {
              print('Error(0) ${result.status}');
              _onError(result.status, result.errorMessage, onError);
            }
          } catch (e) {
            print('Error(1) $e');
            final NetError error = ExceptionHandle.handleException(e);
            _onError(ExceptionHandle.wrong_data_format, error.msg, onError);
          }
        }, onError: (e) {
          print('Error(2) $e');
          final NetError error = ExceptionHandle.handleException(e);
          _onError(error.code, error.msg, onError);
        }, onDone: () {});
      } else {
        print('Error(3) network  not connected!');
        _onError(ExceptionHandle.net_error, 'network  not connected!', onError);
      }
    });
  }

  // Data return format is unified, unified processing exception
  Future<BaseEntity> _request(String method, String url,
      {bool isList = false,
      dynamic data,
      Map<String, dynamic> queryParameters,
      Options options}) async {
    final response = await _dio.request(url,
        data: data,
        queryParameters: queryParameters,
        options: _checkOptions(method, options),
        onSendProgress: (int count, int total) {
      print('onSendProgress: count:{$count} | total:{$total} | ');
    }, onReceiveProgress: (int count, int total) {
      print('onSendProgress: count:{$count} | total:{$total} | ');
    });

    try {
      /// Integration test cannot use isolate
      final Map<String, dynamic> _map =
          await compute(parseData, response.data.toString());
      print(_map);
      return BaseEntity.fromJson(_map);
    } catch (e) {
      Log.severe('DioUtils', e);
      return BaseEntity(
          status: ExceptionHandle.parse_error,
          errorMessage: 'Data parsing error',
          errorBody: e,
          rowData: null);
    }
  }

  _onError(int code, String msg, Function(int code, String mag) onError) {
    Log.severe('DioUtils', 'Interface request exception： code: $code, mag: $msg');
    if (onError != null) {
      onError(code, msg);
    }
  }

  Options _checkOptions(method, options) {
    // ignore: parameter_assignments
    options ??= Options();
    options.method = method;
    return options;
  }

  String _getRequestMethod(Method method) {
    String m;
    switch (method) {
      case Method.get:
        m = 'GET';
        break;
      case Method.post:
        m = 'POST';
        break;
      case Method.put:
        m = 'PUT';
        break;
      case Method.patch:
        m = 'PATCH';
        break;
      case Method.delete:
        m = 'DELETE';
        break;
      case Method.head:
        m = 'HEAD';
        break;
    }
    return m;
  }
}
