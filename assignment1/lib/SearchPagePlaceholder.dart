import 'package:flutter/material.dart';

class SearchPagePlaceholder extends StatelessWidget {
  const SearchPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Page")),
      body: const Center(child: Text("This is the Search Page Placeholder")),
    );
  }
}
