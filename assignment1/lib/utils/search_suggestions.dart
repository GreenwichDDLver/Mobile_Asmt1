class SearchSuggestions {
  // Hot search keywords
  static const List<String> hotSearches = [
    'Burger', 'Sushi', 'Ramen', 'Pizza', 'Fried Chicken', 'Noodles', 'Rice', 'Soup',
    'Mcdonald', 'Hangzhou Flavor', 'Food by K', 'SuanYu House', 'UKIYO RAMEN'
  ];

  // Dish categories
  static const List<String> categories = [
    'Burger', 'Sushi', 'Ramen', 'Noodles', 'Rice', 'Soup', 'Snacks', 'Drinks', 'Desserts',
    'Best Sales', 'Burger', 'Snacks', 'Drinks', 'Desserts', 'Noodles', 'Rice', 'Soup'
  ];

  // Taste preferences
  static const List<String> tastes = [
    'Spicy', 'Sweet', 'Sour', 'Salty', 'Aromatic', 'Fresh', 'Numbing', 'Bitter'
  ];

  // Cuisine types
  static const List<String> cuisines = [
    'Chinese', 'Japanese', 'Western', 'Korean', 'Thai', 'Indian', 'American', 'Italian'
  ];

  // Get search suggestions
  static List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    List<String> suggestions = [];
    
    // Search from hot searches
    for (String hot in hotSearches) {
      if (hot.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(hot);
      }
    }
    
    // Search from categories
    for (String category in categories) {
      if (category.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(category);
      }
    }
    
    // Search from tastes
    for (String taste in tastes) {
      if (taste.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(taste);
      }
    }
    
    // Search from cuisines
    for (String cuisine in cuisines) {
      if (cuisine.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(cuisine);
      }
    }
    
    // Remove duplicates and limit count
    suggestions = suggestions.toSet().toList();
    return suggestions.take(8).toList();
  }

  // Get search tips
  static List<Map<String, String>> getSearchTips() {
    return [
      {
        'icon': '🍔',
        'title': 'Search by dish name',
        'description': 'e.g., Burger, Sushi, Ramen'
      },
      {
        'icon': '🏪',
        'title': 'Search by restaurant name',
        'description': 'e.g., Mcdonald, Hangzhou Flavor'
      },
      {
        'icon': '🌶️',
        'title': 'Search by taste preference',
        'description': 'e.g., Spicy, Sweet, Sour'
      },
      {
        'icon': '🍕',
        'title': 'Search by cuisine type',
        'description': 'e.g., Chinese, Japanese, Western'
      },
    ];
  }

  // Get example searches
  static List<String> getExampleSearches() {
    return [
      'Big Mac',
      'Sushi',
      'Ramen',
      'Fried Chicken',
      'Burger',
      'Noodles',
      'Soup',
      'Drinks'
    ];
  }
} 