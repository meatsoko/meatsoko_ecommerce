class SuggestionModel {
  List<Products>? products;

  SuggestionModel({this.products});

  SuggestionModel.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

}

class Products {
  int? id;
  String? name;
  String? slug;

  Products({this.id, this.name, this.slug});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
   slug = json['slug'];
  }

}
