import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final String iconPath;
  final Color boxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
  });

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];
    categories.add(
      CategoryModel(
        name: "Rice & Noodle",
        iconPath: "assets/icons/rice & noodle.svg",
        boxColor: const Color(0xFFACFEFF),
      ),
    );

    categories.add(
      CategoryModel(
        name: "Burger",
        iconPath: "assets/icons/fast food.svg",
        boxColor: const Color(0xFFACFEFF),
      ),
    );

    categories.add(
      CategoryModel(
        name: "Soup",
        iconPath: "assets/icons/soup.svg",
        boxColor: const Color(0xFFACFEFF),
      ),
    );



    categories.add(
      CategoryModel(
        name: "Salad",
        iconPath: "assets/icons/salad.svg",
        boxColor: const Color(0xFFACFEFF),
      ),
    );

    categories.add(
      CategoryModel(
        name: "Drinks",
        iconPath: "assets/icons/beverages.svg",
        boxColor: const Color(0xFFACFEFF),
      ),
    );

    categories.add(
      CategoryModel(
        name: "Desserts",
        iconPath: "assets/icons/pudding.svg",
        boxColor: const Color(0xFFACFEFF),
      ),
    );

    return categories;
  }
}
