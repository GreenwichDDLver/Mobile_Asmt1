import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String shopName;
  final String shopImage;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final String orderTime;
  final String estimatedTime;
  final Map<String, double> shopLocation;
  final Map<String, double> deliveryLocation;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String paymentMethod;
  final bool canReview;
  final String? riderName;
  final String? riderImage;
  final Duration? timeLeft;
  final double? subtotal;
  final double? tax;
  final double? deliveryFee;
  final double? discount;
  final double? finalTotal;
  final int? reviewRating;
  final String? reviewText;
  final String? reviewTime;

  OrderModel({
    required this.id,
    required this.shopName,
    required this.shopImage,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.orderTime,
    required this.estimatedTime,
    required this.shopLocation,
    required this.deliveryLocation,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.paymentMethod,
    this.canReview = false,
    this.riderName,
    this.riderImage,
    this.timeLeft,
    this.subtotal,
    this.tax,
    this.deliveryFee,
    this.discount,
    this.finalTotal,
    this.reviewRating,
    this.reviewText,
    this.reviewTime,
  });

  // 从Firestore文档创建OrderModel对象
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      shopName: data['shopName'] ?? '',
      shopImage: data['shopImage'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      status: data['status'] ?? '',
      orderTime: data['orderTime'] ?? '',
      estimatedTime: data['estimatedTime'] ?? '',
      shopLocation: Map<String, double>.from(data['shopLocation'] ?? {}),
      deliveryLocation: Map<String, double>.from(
        data['deliveryLocation'] ?? {},
      ),
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      canReview: data['canReview'] ?? false,
      riderName: data['riderName'],
      riderImage: data['riderImage'],
      timeLeft:
          data['timeLeft'] != null ? Duration(minutes: data['timeLeft']) : null,
      subtotal:
          data['subtotal'] != null
              ? (data['subtotal'] as num).toDouble()
              : null,
      tax: data['tax'] != null ? (data['tax'] as num).toDouble() : null,
      deliveryFee:
          data['deliveryFee'] != null
              ? (data['deliveryFee'] as num).toDouble()
              : null,
      discount:
          data['discount'] != null
              ? (data['discount'] as num).toDouble()
              : null,
      finalTotal:
          data['finalTotal'] != null
              ? (data['finalTotal'] as num).toDouble()
              : null,
      reviewRating: data['reviewRating'],
      reviewText: data['reviewText'],
      reviewTime: data['reviewTime'],
    );
  }

  // 转换为Firestore文档
  Map<String, dynamic> toFirestore() {
    return {
      'shopName': shopName,
      'shopImage': shopImage,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'orderTime': orderTime,
      'estimatedTime': estimatedTime,
      'shopLocation': shopLocation,
      'deliveryLocation': deliveryLocation,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'paymentMethod': paymentMethod,
      'canReview': canReview,
      'riderName': riderName,
      'riderImage': riderImage,
      'timeLeft': timeLeft?.inMinutes,
      'createdAt': FieldValue.serverTimestamp(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'finalTotal': finalTotal,
      'reviewRating': reviewRating,
      'reviewText': reviewText,
      'reviewTime': reviewTime,
    };
  }

  // 复制并更新字段
  OrderModel copyWith({
    String? id,
    String? shopName,
    String? shopImage,
    List<OrderItem>? items,
    double? totalPrice,
    String? status,
    String? orderTime,
    String? estimatedTime,
    Map<String, double>? shopLocation,
    Map<String, double>? deliveryLocation,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? paymentMethod,
    bool? canReview,
    String? riderName,
    String? riderImage,
    Duration? timeLeft,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? discount,
    double? finalTotal,
    int? reviewRating,
    String? reviewText,
    String? reviewTime,
  }) {
    return OrderModel(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      shopImage: shopImage ?? this.shopImage,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      orderTime: orderTime ?? this.orderTime,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      shopLocation: shopLocation ?? this.shopLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      canReview: canReview ?? this.canReview,
      riderName: riderName ?? this.riderName,
      riderImage: riderImage ?? this.riderImage,
      timeLeft: timeLeft ?? this.timeLeft,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      finalTotal: finalTotal ?? this.finalTotal,
      reviewRating: reviewRating ?? this.reviewRating,
      reviewText: reviewText ?? this.reviewText,
      reviewTime: reviewTime ?? this.reviewTime,
    );
  }
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final String imagePath;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.imagePath,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      imagePath: map['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
    };
  }
}
