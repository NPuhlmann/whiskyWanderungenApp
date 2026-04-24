import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HikeCard extends StatelessWidget {
  const HikeCard({
    super.key,
    required this.id,
    required this.hike,
    required this.isInGeneralList,
    required this.onFavoriteToggle,
  });

  final int id;
  final Hike hike;
  final bool isInGeneralList;
  final Function(Hike) onFavoriteToggle;

  String getDifficultyString(BuildContext context, Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppLocalizations.of(context)!.easy;
      case Difficulty.mid:
        return AppLocalizations.of(context)!.middle;
      case Difficulty.hard:
        return AppLocalizations.of(context)!.hard;
      case Difficulty.veryHard:
        return AppLocalizations.of(context)!.very_hard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle card tap
        final Map<String, dynamic> extraData = {
          'hike': hike,
          'isFromMyHikes': !isInGeneralList,
        };

        // Wenn wir von der MyHikes-Seite kommen, verwenden wir die Unterroute
        if (!isInGeneralList) {
          GoRouter.of(context).go('/myHikes/hikeDetails', extra: extraData);
        } else {
          GoRouter.of(context).go('/hikeDetails', extra: extraData);
        }
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
                  child: hike.thumbnailImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: hike.thumbnailImageUrl!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            // Error loading thumbnail
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.imageLoadError,
                                    style: TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                          // Verbesserte Caching-Strategie
                          memCacheWidth: MediaQuery.of(
                            context,
                          ).size.width.toInt(),
                          maxHeightDiskCache: 500,
                          maxWidthDiskCache: 1000,
                        )
                      : Image.asset(
                          'assets/logo.png',
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                if (isInGeneralList)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        hike.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: hike.isFavorite
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        size: 30,
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      onPressed: () {
                        onFavoriteToggle(hike);
                      },
                    ),
                  ),
              ],
            ),
            ListTile(
              title: Text(
                hike.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.straighten),
                          Text(
                            hike.length.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.kilometers,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(Icons.terrain),
                          Text(
                            getDifficultyString(context, hike.difficulty),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hike.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
