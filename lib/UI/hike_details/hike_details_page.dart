import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/hike.dart';

class HikeDetailsPage extends StatefulWidget {
  const HikeDetailsPage({super.key, required this.hikeData});

  final Hike hikeData;

  @override
  State<HikeDetailsPage> createState() => _HikeDetailsPageState();
}

class _HikeDetailsPageState extends State<HikeDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hike Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$widget.hikeData.name'),
          ],
        ),
      ),
    );
  }
}
