class User {
  int? id;
  String name;
  String email;
  String password;
  String dateOfBirth;
  String country;
  String? avatarPath;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.country,
    this.avatarPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'date_of_birth': dateOfBirth,
      'country': country,
      'avatar_path': avatarPath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      dateOfBirth: map['date_of_birth'],
      country: map['country'],
      avatarPath: map['avatar_path'],
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? dateOfBirth,
    String? country,
    String? avatarPath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}