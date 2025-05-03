enum UserType { student, faculty, staff, security, visitor }

class User {
  final String id;
  final String name;
  final String email;
  final UserType userType;
  final String? phoneNumber;
  final String? carPlateNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phoneNumber,
    this.carPlateNumber,
  });

  String get userTypeToString {
    switch (userType) {
      case UserType.student:
        return 'Student';
      case UserType.faculty:
        return 'Faculty';
      case UserType.staff:
        return 'Staff';
      case UserType.security:
        return 'Security';
      case UserType.visitor:
        return 'Visitor';
    }
  }
}
