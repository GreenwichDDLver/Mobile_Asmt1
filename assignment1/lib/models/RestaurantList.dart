import 'package:flutter/material.dart';

class RestaurantListModel {
  final String name;
  final String iconPath; 
  final String score;     
  final String duration; 
  final String fee;  
  final Color boxColor;

  RestaurantListModel({
    required this.name,
    required this.iconPath,
    required this.score,
    required this.duration,
    required this.fee,
    required this.boxColor,
  });



  static List<RestaurantListModel> getRestaurantList() {
    return [
      RestaurantListModel(
        name: "Hang Zhou Flavor",
        iconPath: "assets/images/logo4.jpg",
        score: "4.4",
        duration: "40mins",
        fee: "\$1.00",
        boxColor: const Color(0xffC58BF2),
      ),
      RestaurantListModel(
        name: "Mcdonald",
        iconPath: "assets/images/Mcd.jpg",
        score: "4.8",
        duration: "30mins",
        fee: "\$1.00",
        boxColor: const Color(0xff92A3FD),
      ),
      RestaurantListModel(
        name: "Food By K",
        iconPath: "assets/images/logo1.jpg",
        score: "4.6",
        duration: "45mins",
        fee: "\$1.00",
        boxColor: const Color(0xffC58BF2),
      ),
      RestaurantListModel(
        name: "SuanYu House",
        iconPath: "assets/images/logo2.jpg",
        score: "4.5",
        duration: "20mins",
        fee: "\$0.50",
        boxColor: const Color(0xffC58BF2),
      ),
      RestaurantListModel(
        name: "UKIYO RAMEN",
        iconPath: "assets/images/logo3.jpg",
        score: "4.0",
        duration: "60mins",
        fee: "\$1.50",
        boxColor: const Color(0xffC58BF2),
      ),
    ];
  }
}
