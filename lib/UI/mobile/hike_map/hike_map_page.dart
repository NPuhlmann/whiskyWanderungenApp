import 'package:flutter/material.dart';
import 'hike_map_screen.dart';

class HikeMapPage extends StatelessWidget {
  final int hikeId;

  const HikeMapPage({super.key, required this.hikeId});

  @override
  Widget build(BuildContext context) {
    return HikeMapScreen(hikeId: hikeId);
  }
}
