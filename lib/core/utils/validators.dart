class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    if (value.length < minLength) {
      return fieldName != null
          ? '$fieldName يجب أن يكون على الأقل $minLength أحرف'
          : 'يجب أن يكون على الأقل $minLength أحرف';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return fieldName != null
          ? '$fieldName يجب أن يكون أقل من $maxLength أحرف'
          : 'يجب أن يكون أقل من $maxLength أحرف';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون على الأقل 8 أحرف';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  static String? match(String? value, String? matchValue, String errorMessage) {
    if (value != matchValue) {
      return errorMessage;
    }
    return null;
  }
}

