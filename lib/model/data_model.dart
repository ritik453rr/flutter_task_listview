class DataModel {
  String? name;
  String? number;
  String? id;

  DataModel({this.name, this.number, this.id});

  DataModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    number = json['number'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['number'] = this.number;
    data['id'] = this.id;
    return data;
  }
}
