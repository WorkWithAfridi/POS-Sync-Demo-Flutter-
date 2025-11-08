class User {
  final int? id;
  final String name;
  final String createdAt;

  User({this.id, required this.name, required this.createdAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        name: map['name'],
        createdAt: map['created_at'],
      );
}
