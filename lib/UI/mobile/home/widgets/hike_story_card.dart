import 'package:flutter/material.dart';
import '../../../../config/theme/app_tokens.dart';
import '../../../../domain/models/hike.dart';

/// Hike Story Card — story-driven listing card for the home feed.
///
/// ## Screen layout spec (375 pt wide)
///
/// ┌──────────────────────────────────────────────────┐
/// │  ┌─ Thumbnail (16:9, rounded top) ─────────────┐ │
/// │  │  [Highland landscape photograph]           │ │
/// │  │                                            │ │
/// │  │  ┌─ Difficulty badge (top-right) ─────────┐│ │
/// │  │  │  ⬥ Mittel / Medium                    ││ │
/// │  │  └────────────────────────────────────────┘│ │
/// │  └────────────────────────────────────────────┘ │
/// │                                                  │
/// │  ┌─ Content area ──────────────────────────────┐ │
/// │  │  [Region tag — amber overline]              │ │
/// │  │  Hike name — bold headline                  │ │
/// │  │  One-liner description (2 lines max)        │ │
/// │  │                                             │ │
/// │  │  ├─ Stats row ──────────────────────────────│ │
/// │  │  │  🥾 8.4 km   ↑ 340 m   🥃 5 whiskies   │ │
/// │  │  │                                          │ │
/// │  │  ├─ Price row ──────────────────────────────│ │
/// │  │  │  €49.00            [Buchen / Book →]     │ │
/// │  └────────────────────────────────────────────┘ │
/// └──────────────────────────────────────────────────┘
///
/// Design notes:
///   • No star ratings, no Yelp-style grid. Each card reads as editorial.
///   • Thumbnail must be landscape photography — no map screenshots.
///   • Difficulty badge uses a coloured pill on the image, not an icon row.
///   • Max 2 lines on description; truncated with ellipsis.
///   • Price row is the last thing the eye lands on — it anchors the CTA.
///
/// Accessibility:
///   • Card is one tappable Semantics node with a merged label.
///   • Contrast on image badges: amber text on peat overlay meets AA.
///
/// DE/EN: [waypointLabel] and [bookCta] accept localised strings.
///        Difficulty display string is resolved via [_difficultyLabel].
class HikeStoryCard extends StatelessWidget {
  const HikeStoryCard({
    super.key,
    required this.hike,
    required this.waypointCount,
    required this.bookCta,
    required this.waypointLabel,
    this.onTap,
    this.onBook,
  });

  final Hike hike;

  /// Number of whisky waypoints on this hike (from WaypointRepository).
  final int waypointCount;

  /// e.g. "Buchen" (DE) / "Book" (EN)
  final String bookCta;

  /// e.g. "Whiskies" (DE+EN)
  final String waypointLabel;

  final VoidCallback? onTap;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${hike.name}, ${hike.length.toStringAsFixed(1)} km, €${hike.price.toStringAsFixed(2)}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppElevation.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ThumbnailSection(hike: hike),
              _ContentSection(
                hike: hike,
                waypointCount: waypointCount,
                bookCta: bookCta,
                waypointLabel: waypointLabel,
                onBook: onBook,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ThumbnailSection extends StatelessWidget {
  const _ThumbnailSection({required this.hike});

  final Hike hike;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ThumbnailImage(
            url: hike.thumbnailImageUrl,
            alt: hike.name,
          ),
          // Top-right difficulty badge
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: _DifficultyBadge(difficulty: hike.difficulty),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.url, required this.alt});

  final String? url;
  final String alt;

  @override
  Widget build(BuildContext context) {
    final resolved = url;
    if (resolved != null && resolved.isNotEmpty) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        semanticLabel: alt,
        errorBuilder: (context, error, stack) => _PlaceholderImage(),
      );
    }
    return _PlaceholderImage();
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.peat100,
      child: const Center(
        child: Icon(Icons.landscape, size: 48, color: AppColors.peat300),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _difficultyLabel(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.peat900.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  static (String, Color) _difficultyLabel(Difficulty d) => switch (d) {
    Difficulty.easy => ('Easy', AppColors.success),
    Difficulty.mid => ('Medium', AppColors.amber700),
    Difficulty.hard => ('Hard', AppColors.warning),
    Difficulty.veryHard => ('Very Hard', AppColors.error),
  };
}

// ---------------------------------------------------------------------------

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.hike,
    required this.waypointCount,
    required this.bookCta,
    required this.waypointLabel,
    this.onBook,
  });

  final Hike hike;
  final int waypointCount;
  final String bookCta;
  final String waypointLabel;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Region overline
          if (hike.tags.isNotEmpty)
            Text(
              hike.tags.first.toUpperCase(),
              style: AppTextStyles.overline,
            ),
          const SizedBox(height: AppSpacing.xs),
          // Hike name headline
          Text(
            hike.name,
            style: AppTextStyles.headlineMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Description
          Text(
            hike.description,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          // Stats row
          _StatsRow(
            hike: hike,
            waypointCount: waypointCount,
            waypointLabel: waypointLabel,
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.peat100),
          const SizedBox(height: AppSpacing.md),
          // Price + CTA
          _PriceRow(hike: hike, bookCta: bookCta, onBook: onBook),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.hike,
    required this.waypointCount,
    required this.waypointLabel,
  });

  final Hike hike;
  final int waypointCount;
  final String waypointLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.directions_walk,
          label: '${hike.length.toStringAsFixed(1)} km',
        ),
        const SizedBox(width: AppSpacing.md),
        _StatChip(
          icon: Icons.terrain,
          label: '↑ ${hike.elevation} m',
        ),
        const SizedBox(width: AppSpacing.md),
        _StatChip(
          icon: Icons.local_bar,
          label: '$waypointCount $waypointLabel',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.peat500),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.hike,
    required this.bookCta,
    this.onBook,
  });

  final Hike hike;
  final String bookCta;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '€${hike.price.toStringAsFixed(2)}',
          style: AppTextStyles.accentPrice,
        ),
        const Spacer(),
        SizedBox(
          height: AppTouchTargets.minimum,
          child: ElevatedButton.icon(
            onPressed: onBook,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(bookCta),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}
