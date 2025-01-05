import 'package:flutter/material.dart';

class HikeCard extends StatelessWidget {
  const HikeCard({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      elevation: 5,
      borderOnForeground: true,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Image.asset('assets/logo.png', height: 250, width: 250),
          ListTile(
            title: Text(title),
            subtitle: Text(description, maxLines: 3, overflow: TextOverflow.ellipsis,),
          ),
        ],
      ),
    );
  }
}
