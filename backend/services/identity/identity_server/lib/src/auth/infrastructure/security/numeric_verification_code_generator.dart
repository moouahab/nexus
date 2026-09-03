import 'dart:math';

import '../../application/interfaces/verification_code_generator.dart';

class NumericVerificationCodeGenerator implements VerificationCodeGenerator {
  NumericVerificationCodeGenerator({
    Random? random,
    this.length = 8,
  }) : _random = random ?? Random.secure();

  static const _characters = '123456789';

  final Random _random;
  final int length;

  @override
  String generate() {
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _characters.codeUnitAt(_random.nextInt(_characters.length)),
      ),
    );
  }
}
