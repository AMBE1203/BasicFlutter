part of expand_logger;

/// Default implementation of [LogOutput].
///
/// It sends everything to the system console.
class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // ignore: prefer_foreach
    for (var line in event.lines) {
     print(line);
    }
  }
}
