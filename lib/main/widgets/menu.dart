class Menu {
  String description;
  String imageUrl;
  String name;
  int price;

  Menu({
      required this.description,
      required this.imageUrl,
      required this.name,
      required this.price
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: json['price'] ?? 0,
    );
  }
}
