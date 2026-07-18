import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/config/theme/app_tokens.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Editorial hike listing card: hero photograph with a difficulty badge,
/// amber category overline, story description, stats and a price row.
///
/// Thumbnails must be landscape photography — no map screenshots.
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

  static const double _heroHeight = 220;

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

  void _openDetails(BuildContext context) {
    final Map<String, dynamic> extraData = {
      'hike': hike,
      'isFromMyHikes': !isInGeneralList,
    };

    // Coming from My Hikes: use the nested sub-route.
    if (!isInGeneralList) {
      GoRouter.of(context).go('/myHikes/hikeDetails', extra: extraData);
    } else {
      GoRouter.of(context).go('/hikeDetails', extra: extraData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${hike.name}, ${hike.length.toStringAsFixed(1)} km, '
          '€${hike.price.toStringAsFixed(2)}',
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppElevation.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(context),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hike.category.toUpperCase(),
                      style: AppTextStyles.overline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      hike.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hike.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        hike.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _buildStatsRow(context),
                    // Price only sells an unowned hike; My Hikes already paid.
                    if (isInGeneralList) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '€${hike.price.toStringAsFixed(2)}',
                        style: AppTextStyles.accentPrice,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: _heroHeight,
          width: double.infinity,
          child: hike.thumbnailImageUrl != null
              ? CachedNetworkImage(
                  imageUrl: hike.thumbnailImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const ColoredBox(color: AppColors.peat100),
                  errorWidget: (context, url, error) => ColoredBox(
                    color: AppColors.peat100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.landscape_outlined,
                            color: AppColors.peat300,
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppLocalizations.of(context)!.imageLoadError,
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tuned disk/memory cache bounds for list scrolling.
                  memCacheWidth: MediaQuery.of(context).size.width.toInt(),
                  maxHeightDiskCache: 500,
                  maxWidthDiskCache: 1000,
                )
              : Image.asset('assets/logo.png', fit: BoxFit.cover),
        ),
        // Difficulty pill sits on the photograph, not in an icon row.
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.peat900.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              getDifficultyString(context, hike.difficulty),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.amber100,
              ),
            ),
          ),
        ),
        if (isInGeneralList)
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: IconButton(
              icon: Icon(
                hike.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: hike.isFavorite ? AppColors.amber700 : AppColors.white,
                size: 30,
                shadows: const [
                  Shadow(blurRadius: 4.0, color: AppColors.peat900),
                ],
              ),
              onPressed: () => onFavoriteToggle(hike),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _Stat(
          icon: Icons.straighten,
          label: '${hike.length.toStringAsFixed(1)} ${l10n.kilometers}',
        ),
        const SizedBox(width: AppSpacing.lg),
        _Stat(icon: Icons.trending_up, label: '${hike.elevation} m'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.peat500),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
