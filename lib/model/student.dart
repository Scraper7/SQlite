class Student {
  int? id;
  late String name;

  Student(this.id, this.name);

  // Дополнительный конструктор без id
  Student.withoutId(this.name);

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    return map;
  }

  Student.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
  }
}
