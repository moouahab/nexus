class TerminationRule {
  const TerminationRule({
    required this.shouldTerminate,
    required this.exception,
  });

  final bool Function() shouldTerminate;
  final Object exception;

  static void validateAll(Iterable<TerminationRule> rules) {
    for (final rule in rules) {
      if (rule.shouldTerminate()) {
        throw rule.exception;
      }
    }
  }
}

class AsyncTerminationRule {
  const AsyncTerminationRule({
    required this.shouldTerminate,
    required this.exception,
    this.beforeThrow,
  });

  final Future<bool> Function() shouldTerminate;
  final Object exception;
  final Future<void> Function()? beforeThrow;

  static Future<void> validateAll(Iterable<AsyncTerminationRule> rules) async {
    for (final rule in rules) {
      if (await rule.shouldTerminate()) {
        await rule.beforeThrow?.call();
        throw rule.exception;
      }
    }
  }
}
