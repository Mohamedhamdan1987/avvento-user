enum UserType {
  client, // العميل
  driver, // السائق
}

extension UserTypeExtension on UserType {
  String get name {
    switch (this) {
      case UserType.client:
        return 'عميل';
      case UserType.driver:
        return 'سائق';
    }
  }
}

