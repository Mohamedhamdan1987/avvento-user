class Validators {
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

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 5) {
      return 'كلمة المرور يجب أن تكون 5 أحرف على الأقل';
    }
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    if (value.length < min) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $min أحرف على الأقل';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > max) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $max أحرف على الأكثر';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'اسم المستخدم مطلوب';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    if (!usernameRegex.hasMatch(value)) {
      return 'اسم المستخدم غير صحيح (3-20 حرف، أرقام أو _ فقط)';
    }
    return null;
  }
}

