import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate<String> {
  final cities = ['kolaba', 'mathara', 'nuwara', 'kurunagala', 'jaffna'];

  final sugcities = [
    'kolaba',
    'mathara',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () {})];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon of the left of the app bar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {},
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some results based on the selection
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggList = query.isEmpty ? sugcities : cities;
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.location_city),
        title: Text(suggList[index]),
      ),
      itemCount: suggList.length,
    );
  }
}
