class Category {
  int? id;
  String name;
  int color;
  int? userId;

  Category({this.id, required this.name, required this.color, this.userId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'color': color, 'userId': userId};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      userId: map['userId'],
    );
  }
}
