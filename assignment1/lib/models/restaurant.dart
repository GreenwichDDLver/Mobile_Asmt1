import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String? id;
  final String name;
  final String iconPath;
  final String score;
  final String duration;
  final String fee;
  final String sales;
  final List<MenuItem> menuItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Restaurant({
    this.id,
    required this.name,
    required this.iconPath,
    required this.score,
    required this.duration,
    required this.fee,
    required this.sales,
    required this.menuItems,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // 从Firestore文档创建Restaurant对象
  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      iconPath: data['iconPath'] ?? '',
      score: data['score'] ?? '',
      duration: data['duration'] ?? '',
      fee: data['fee'] ?? '',
      sales: data['sales'] ?? '',
      menuItems: (data['menuItems'] as List<dynamic>?)
          ?.map((item) => MenuItem.fromMap(item))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // 转换为Map用于Firestore存储
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconPath': iconPath,
      'score': score,
      'duration': duration,
      'fee': fee,
      'sales': sales,
      'menuItems': menuItems.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  // 创建副本
  Restaurant copyWith({
    String? id,
    String? name,
    String? iconPath,
    String? score,
    String? duration,
    String? fee,
    String? sales,
    List<MenuItem>? menuItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      score: score ?? this.score,
      duration: duration ?? this.duration,
      fee: fee ?? this.fee,
      sales: sales ?? this.sales,
      menuItems: menuItems ?? this.menuItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class MenuItem {
  final String name;
  final String description;
  final double price;
  final String category;
  final String imagePath;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
  });

  // 从Map创建MenuItem对象
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] as double?) ?? 0.0,
      category: map['category'] ?? '',
      imagePath: map['imagePath'] ?? '',
    );
  }

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imagePath': imagePath,
    };
  }

  // 创建副本
  MenuItem copyWith({
    String? name,
    String? description,
    double? price,
    String? category,
    String? imagePath,
  }) {
    return MenuItem(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
    );
  }
} 