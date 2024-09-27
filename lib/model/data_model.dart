class DataModel {
  String? name;
  String? number;

  DataModel({this.name, this.number});

  DataModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    number = json['number'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['number'] = this.number;
    return data;
  }
}
