import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Column(
        children: [1, 2, 3, 4]
            .map(
              (v) => ListTile(
                leading: const Icon(Icons.favorite),
                title: Text('Favorite book $v'),
              ),
            )
            .toList(),
      ),
    );
  }
}
