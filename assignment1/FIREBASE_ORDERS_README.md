# Firebase 订单系统

## 概述

本项目已成功集成了Firebase Firestore数据库来管理订单数据。系统包含完整的订单创建、查询、更新和删除功能。

## 功能特性

### 1. 订单数据模型
- **OrderModel**: 完整的订单数据模型
- **OrderItem**: 订单项目模型
- 支持订单状态跟踪（准备中、配送中、已完成、已取消）
- 包含骑手信息、配送时间、位置信息等

### 2. 订单服务 (OrderService)
- 创建新订单
- 获取当前订单（非完成状态）
- 获取订单历史（完成状态）
- 更新订单状态
- 更新骑手信息
- 删除订单
- 初始化示例订单数据

### 3. 订单页面集成
- 实时显示当前订单和订单历史
- 地图显示配送状态和骑手位置
- 订单卡片显示详细信息
- 支持订单状态更新

### 4. 结账页面集成
- 自动创建新订单到Firebase
- 显示订单创建进度
- 成功/失败提示
- 自动清空购物车

## 文件结构

```
lib/
├── models/
│   └── order.dart                 # 订单数据模型
├── services/
│   └── order_service.dart         # 订单服务
├── providers/
│   └── order_provider.dart        # 订单状态管理
├── pages/
│   ├── order_page.dart           # 订单页面（已更新）
│   └── checkout_page.dart        # 结账页面（已更新）
├── utils/
│   └── firebase_test.dart        # Firebase测试工具
└── main.dart                     # 主应用（已更新）
```

## 数据库结构

### Firestore 集合: `orders`

每个订单文档包含以下字段：

```json
{
  "shopName": "餐厅名称",
  "shopImage": "餐厅图片路径",
  "items": [
    {
      "name": "商品名称",
      "price": 价格,
      "quantity": 数量,
      "imagePath": "商品图片路径"
    }
  ],
  "totalPrice": 总价,
  "status": "订单状态",
  "orderTime": "下单时间",
  "estimatedTime": "预计配送时间",
  "shopLocation": {
    "lat": 纬度,
    "lng": 经度
  },
  "deliveryLocation": {
    "lat": 纬度,
    "lng": 经度
  },
  "customerName": "客户姓名",
  "customerPhone": "客户电话",
  "customerAddress": "配送地址",
  "paymentMethod": "支付方式",
  "canReview": 是否可评价,
  "riderName": "骑手姓名",
  "riderImage": "骑手图片",
  "timeLeft": 剩余时间（分钟）,
  "createdAt": 创建时间戳
}
```

## 使用方法

### 1. 创建新订单

```dart
String orderId = await OrderService.createOrder(
  cart: cartModel,
  customerName: "客户姓名",
  customerPhone: "客户电话",
  customerAddress: "配送地址",
  paymentMethod: "支付方式",
);
```

### 2. 获取订单数据

```dart
// 获取当前订单
Stream<List<OrderModel>> currentOrders = OrderService.getCurrentOrders();

// 获取订单历史
Stream<List<OrderModel>> orderHistory = OrderService.getOrderHistory();

// 获取所有订单
Stream<List<OrderModel>> allOrders = OrderService.getOrders();
```

### 3. 更新订单状态

```dart
await OrderService.updateOrderStatus(orderId, "Out for Delivery");
```

### 4. 更新骑手信息

```dart
await OrderService.updateRiderInfo(
  orderId,
  riderName: "骑手姓名",
  riderImage: "骑手图片路径",
  timeLeft: Duration(minutes: 25),
);
```

## 订单状态

- **Preparing**: 准备中
- **Out for Delivery**: 配送中
- **Completed**: 已完成
- **Cancelled**: 已取消

## 初始化数据

应用启动时会自动初始化示例订单数据，包括：

1. 当前订单（准备中、配送中）
2. 订单历史（已完成、已取消）
3. 骑手信息和位置数据

## 实时更新

订单页面使用StreamBuilder实现实时数据更新：

- 新订单创建后自动显示在订单页面
- 订单状态变化实时反映在UI上
- 骑手位置信息实时更新

## 错误处理

- Firebase连接失败时应用仍可正常运行
- 订单创建失败时显示错误提示
- 数据加载失败时显示友好提示

## 测试

使用 `FirebaseTest` 类可以测试：

```dart
// 测试Firebase连接
bool isConnected = await FirebaseTest.testConnection();

// 测试订单服务
await FirebaseTest.testOrderService();
```

## 注意事项

1. 确保Firebase项目已正确配置
2. 检查Firestore安全规则设置
3. 确保网络连接正常
4. 图片路径需要正确配置在pubspec.yaml中

## 扩展功能

可以进一步扩展的功能：

1. 订单搜索和筛选
2. 订单评价系统
3. 订单通知推送
4. 订单统计分析
5. 多用户订单管理 