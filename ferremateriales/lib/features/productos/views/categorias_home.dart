import 'package:flutter/material.dart';

class CategoriasHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 10,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.blue[100],
          child: Center(
            child: Text("Categoría $index"),
          ),
        );
      },
    );
  }
}
