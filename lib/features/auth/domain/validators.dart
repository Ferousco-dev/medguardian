abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? email(String? value) {
    final String input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Enter your email address';
    }
    if (!_email.hasMatch(input)) {
      return 'That does not look like a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final String input = value ?? '';
    if (input.isEmpty) {
      return 'Enter a password';
    }
    if (input.length < 8) {
      return 'Use at least 8 characters';
    }
    return null;
  }

  static String? fullName(String? value) {
    final String input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Enter your name';
    }
    if (input.length < 2) {
      return 'That name looks too short';
    }
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if ((value?.trim() ?? '').isEmpty) {
      return '$field is required';
    }
    return null;
  }

  const Validators._();
}
