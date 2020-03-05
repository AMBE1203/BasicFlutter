part of expand_logger;

class PrinterLogger extends LogPrinter {
  PrinterLogger({
    this.methodCount = 2,
    this.lineLength = 120,
  }) {
    _startTime ??= DateTime.now();

    final doubleDividerLine = StringBuffer();
    final singleDividerLine = StringBuffer();
    for (int i = 0; i < lineLength - 1; i++) {
      doubleDividerLine.write(doubleDivider);
      singleDividerLine.write(singleDivider);
    }

    _topBorder = '$topLeftCorner$doubleDividerLine';
    _middleBorder = '$middleCorner$singleDividerLine';
    _bottomBorder = '$bottomLeftCorner$doubleDividerLine';
  }

  static const topLeftCorner = '┌';
  static const bottomLeftCorner = '└';
  static const middleCorner = '├';
  static const verticalLine = '│';
  static const doubleDivider = '─';
  static const singleDivider = '┄';

  static final stackTraceRegex = RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');

  static DateTime _startTime;

  final int methodCount;
  final int lineLength;

  String _topBorder = '';
  String _middleBorder = '';
  String _bottomBorder = '';

  @override
  void log(LogEvent event) {
    final headerStr = stringifyHeader(event.header);
    final messageStr = stringifyMessage(event.message);
    formatAndPrint(headerStr, messageStr);
  }

  String formatStackTrace(StackTrace stackTrace, int methodCount) {
    final lines = stackTrace.toString().split('\n');

    final formatted = <String>[];
    var count = 0;
    for (var line in lines) {
      final match = stackTraceRegex.matchAsPrefix(line);
      if (match != null) {
        if (match.group(2).startsWith('package:logger')) {
          continue;
        }
        final newLine = '#$count   ${match.group(1)} (${match.group(2)})';
        formatted.add(newLine.replaceAll('<anonymous closure>', '()'));
        if (++count == methodCount) {
          break;
        }
      } else {
        formatted.add(line);
      }
    }

    if (formatted.isEmpty) {
      return null;
    } else {
      return formatted.join('\n');
    }
  }

  String stringifyHeader(dynamic header) {
    final lines = header.toString().split('\n');
    final formatted = <String>[];
    // ignore: prefer_foreach
    for (var line in lines) {
      formatted.add(line);
    }
    if (formatted.isEmpty) {
      return null;
    } else {
      return formatted.join('\n');
    }
  }

  String stringifyMessage(dynamic message) {
    if (message is Map || message is Iterable) {
      // ignore: prefer_const_constructors
      final encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(message);
    } else {
      return message.toString();
    }
  }

  formatAndPrint(String header, String message) {
    println(_topBorder);
    if (header != null) {
      for (var line in header.split('\n')) {
        println('$verticalLine $line');
      }
      println(_middleBorder);
    }

    for (var line in message.split('\n')) {
      println('$verticalLine $line');
    }
    println(_bottomBorder);
  }
}
