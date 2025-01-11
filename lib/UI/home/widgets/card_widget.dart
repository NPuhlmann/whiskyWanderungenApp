import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HikeCard extends StatelessWidget {
  const HikeCard(
      {super.key, required this.id, required this.hike});

  final int id;
  final Hike hike;

  String getDifficultyString(BuildContext context, Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppLocalizations.of(context)!.easy;
      case Difficulty.mid:
        return AppLocalizations.of(context)!.middle;
      case Difficulty.hard:
        return AppLocalizations.of(context)!.hard;
      case Difficulty.very_hard:
        return AppLocalizations.of(context)!.very_hard;
      default:
        return AppLocalizations.of(context)!.middle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle card tap
        GoRouter.of(context).go('/hikeDetails', extra: hike);
      },
      child: Card.outlined(
        elevation: 5,
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: hike.thumbnail_image_url != null
                      ? Image.network(hike.thumbnail_image_url!, height: 250, width: double.infinity, fit: BoxFit.cover)
                      : Image.asset('assets/logo.png', height: 250, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.white, size: 30, shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black,
                        offset: Offset(0, 0),
                      ),
                    ],),
                    onPressed: () {
                      // Handle favorite button press
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title: Row(
                children: [
                  Text(hike.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.straighten),
                      Text(hike.length.toString(), style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(' km', style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Icon(Icons.terrain),
                      Text(getDifficultyString(context, hike.difficulty),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              subtitle: Text(
                hike.description, maxLines: 3, overflow: TextOverflow.ellipsis,),
            ),
          ],
        ),
      ),
    );
  }
}