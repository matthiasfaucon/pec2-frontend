import 'package:flutter/material.dart';

class SearchBarOnlyFlic extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBarOnlyFlic> {
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher quelque chose...',
        prefixIcon: const Icon(Icons.search),
        // suffixIcon: const Icon(Icons.filter_alt_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }
}