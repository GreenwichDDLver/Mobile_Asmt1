class MenuItem {
  final String name;
  final String category;
  final String description;
  final double price;
  final String imagePath;

  MenuItem({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imagePath,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: json['imagePath'] ?? 'assets/images/placeholder.png',
    );
  }
}
