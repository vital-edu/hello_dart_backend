class UserDto {
  final String id;
  final String role;
  final String password;

  UserDto({required this.id, required this.role, required this.password});

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      id: map['id'] as String,
      role: map['role'] as String,
      password: map['password'] as String,
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'role': role,
    };
  }
}
