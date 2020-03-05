part of expand_logger;

class LogEvent {
  LogEvent(this.header, this.message);

  final dynamic message;
  final dynamic header;
}

class OutputEvent {
  OutputEvent(this.lines);

  final List<String> lines;
}

typedef LogCallback = void Function(LogEvent event);
typedef OutputCallback = void Function(OutputEvent event);

/// Use instances of logger to send log messages to the [LogPrinter].
class ResponseLogger {
  /// Create a new instance of Logger.
  ResponseLogger(String header, String message)
      : _printer = PrinterLogger(),
        _output = ConsoleOutput() {
    if (Env.value.flavor != Flavor.RELEASE) {
      _printer._buffer = _outputBuffer;
      _printer.init();
      _output.init();
      log(header, message);
    }
  }

  final LogPrinter _printer;
  final LogOutput _output;
  List<String> _outputBuffer = [];

  /// Log a message with [level].
  void log(
    dynamic header,
    dynamic message,
  ) {
    final logEvent = LogEvent(header, message);
    _printer.log(logEvent);
    if (_outputBuffer.isNotEmpty) {
      final outputEvent = OutputEvent(_outputBuffer);
      _output.output(outputEvent);
      _outputBuffer = [];
      _printer._buffer = _outputBuffer;
    }
  }

  /// Closes the logger and releases all resources.
  void close() {
    _outputBuffer = null;
    _printer.destroy();
    _printer._buffer = null;
    _output.destroy();
  }
}
