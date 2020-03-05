import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:liveshop/core/mvp/contract.dart';
import 'package:liveshop/src/net/net.dart';
import 'package:liveshop/config/src/app/database_provider.dart';
import 'package:sqflite/sqflite.dart';

enum ResponseState { SUCCESSFUL, FAILED }

///
/// Type of callback called when the future returned by a ResponseFuture
/// is canceled.
///
typedef CompleteCallback = void Function(ResponseState state);

class ResponseFuture<T> implements Future<T> {
  /// Constructs a [Future] which wraps another [Future].
  ResponseFuture(this._wrapped);

  /// This method will be called when the returned code is [ExceptionHandle.success]
  ResponseFuture<T> successful<R>(FutureOr<R> Function(T value) onValue,
      {Function onError}) {
    _wrapped._outerCompleter.future.then(onValue, onError: onError);
    return this;
  }

  /// This method will not be called when the error code returned is
  ///  [ExceptionHandle.socket_error]
  ///  [ExceptionHandle.net_error]
  ///  [ExceptionHandle.http_error]
  ///  [ExceptionHandle.timeout]
  ///  [ExceptionHandle.timeout_error]
  ///  [ExceptionHandle.unauthorized]
  ///  [ExceptionHandle.force_logout]
  ///  [ExceptionHandle.forbidden]
  ///  [ExceptionHandle.not_found]
  ///  [ExceptionHandle.wrong_data_format]
  ///  [ExceptionHandle.unknown_error]
  ///  [ExceptionHandle.client_unknown_error]
  ResponseFuture<T> failed(Function onError,
      {bool Function(Object error) test}) {
    _wrapped._outerCompleter.future.catchError(onError, test: test);
    return this;
  }

  /// This method will always be returned when the request is completed.
  /// It doesn't care if the process [ResponseState.SUCCESSFUL] or [ResponseState.FAILED]
  void completed(CompleteCallback onCompleted) {
    _wrapped.onCompleted = onCompleted;
  }

  /// A reference to the wrapped [Future].
  final _Completer<T> _wrapped;

  @override
  Stream<T> asStream() => _wrapped._outerCompleter.future.asStream();

  /// [catchError] method has been removed,
  ///since it will return a [Future] without a [ResponseFuture]
  ///so it will not be possible to call the [completed] method.
  @deprecated
  @override
  Future<T> catchError(Function onError, {bool Function(Object error) test}) =>
      _wrapped._outerCompleter.future.catchError(onError, test: test);

  ///[then] method has been removed,
  ///since it will return a [Future] without a [ResponseFuture]
  ///so it will not be possible to call the [completed] method.
  @deprecated
  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue,
          {Function onError}) =>
      _wrapped._outerCompleter.future.then(onValue, onError: onError);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function() onTimeout}) =>
      _wrapped._outerCompleter.future.timeout(timeLimit, onTimeout: onTimeout);

  ///[whenComplete] method has been removed,
  ///since it will return a [Future] without a [ResponseFuture]
  ///so it will not be possible to call the [completed] method.
  @deprecated
  @override
  Future<T> whenComplete(FutureOr Function() action) =>
      _wrapped._outerCompleter.future..whenComplete(action);
}

class _Completer<T> implements Completer<T> {
  ///
  /// Create a CancelableCompleter that will invoke the given callback
  /// synchronously if its future is canceled.  The callback will not be
  /// invoked if the future is completed before being canceled.
  ///
  _Completer() {
    _future = ResponseFuture<T>(this);
  }

  @override
  void complete([FutureOr<T> value]) => _outerCompleter.complete(value);

  @override
  void completeError(Object error, [StackTrace stackTrace]) =>
      _outerCompleter.completeError(error, stackTrace);

  void completed(ResponseState state) {
    if (onCompleted != null) onCompleted(state);
  }

  @override
  ResponseFuture<T> get future => _future;

  @override
  bool get isCompleted => _outerCompleter.isCompleted;

  ///
  /// The completer which holds the future that is exposed to the client
  /// through [future].  If the computation is canceled, this completer will
  /// be completed with a FutureCanceledError.
  ///
  final Completer<T> _outerCompleter = Completer<T>();

  ResponseFuture<T> _future;

  ///
  /// The callback to invoke if the 'cancel' method is called on the future
  /// returned by [future].  This callback will only be invoked if the future
  /// is canceled before being completed.
  ///
  CompleteCallback onCompleted;
}

abstract class RepoImpl<P extends Presenter> implements Repo<P> {
  P presenter;

  @override
  attackPresenter(P p) {
    presenter = p;
  }

  _Completer<T> _createIsolate<T>(
      {@required String path,
      Method method,
      dynamic data,
      Map<String, dynamic> queryParameters,
      bool isCloseWhenError = true,
      bool isAutoErrorChecking = true,
      bool isList = false,
      Function(Map<String, dynamic> json) convertData}) {
    //create isolate
    final _Completer<T> completer = _Completer<T>();

    DioUtils.instance.asyncRequestNetwork(path, method ?? Method.post,
        data: data, queryParameters: queryParameters, onSuccess: (data) async {
      completer.complete(convertData == null ? null : convertData(data));
      await presenter?.completed(ExceptionHandle.success);
      completer.completed(ResponseState.SUCCESSFUL);
    }, onError: (status, msg) async {
      if (presenter?.isSystemError(status) == false &&
          isAutoErrorChecking) {
        completer.completeError(status);
      }
      if (isAutoErrorChecking) {
        await presenter?.completed(status);
      }
      completer.completed(ResponseState.FAILED);
    });

    //return the future
    return completer;
  }

  _Completer<List<T>> _createIsolateList<T>(
      {@required String path,
      Method method,
      dynamic data,
      Map<String, dynamic> queryParameters,
      bool isCloseWhenError = true,
      bool isAutoErrorChecking = true,
      Function(List<dynamic> list) convertList}) {
    //create isolate
    final _Completer<List<T>> completer = _Completer<List<T>>();

    DioUtils.instance.asyncRequestNetwork(path, method ?? Method.post,
        data: data,
        queryParameters: queryParameters,
        isList: true, onSuccessList: (list) async {
      completer.complete(convertList == null ? [] : convertList(list));

      await presenter?.completed(ExceptionHandle.success);
      completer.completed(ResponseState.SUCCESSFUL);
    }, onError: (status, msg) async {
      if (presenter?.isSystemError(status) == false &&
          isAutoErrorChecking) {
        completer.completeError(status);
      }
      if (isAutoErrorChecking) {
        await presenter?.completed(status);
      }
      completer.completed(ResponseState.FAILED);
    });

    //return the future
    return completer;
  }

  ResponseFuture<T> asyncRequestNetwork<T>(
      {@required String path,
      Method method,
      dynamic data,
      Map<String, dynamic> queryParameters,
      bool isCloseWhenError = true,
      bool isAutoErrorChecking = true,
      bool isList = false,
      Function(Map<String, dynamic> json) convertData}) {
    //return the future
    return _createIsolate<T>(
            path: path,
            method: method,
            data: data,
            queryParameters: queryParameters,
            isCloseWhenError: isCloseWhenError,
            isAutoErrorChecking: isAutoErrorChecking,
            isList: isList,
            convertData: convertData)
        .future;
  }

  ResponseFuture<List<T>> asyncRequestNetworkByList<T>(
      {@required String path,
      Method method,
      dynamic data,
      Map<String, dynamic> queryParameters,
      bool isCloseWhenError = true,
      bool isAutoErrorChecking = true,
      Function(List<dynamic> list) convertList}) {
    //return the future
    return _createIsolateList<T>(
            path: path,
            method: method,
            data: data,
            queryParameters: queryParameters,
            isCloseWhenError: isCloseWhenError,
            isAutoErrorChecking: isAutoErrorChecking,
            convertList: convertList)
        .future;
  }

  @override
  Future<Database> database() async => await DBProvider.db.database;
}
