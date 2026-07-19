import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme/app_tokens.dart';
import '../../../domain/models/waypoint.dart';

/// POI / Whisky card: hero image, tasting-note chips, story body, CTA row.
///
/// Photography direction: landscape, golden-hour, whisky in the foreground
/// against a highland backdrop — no "generic whisky on white" stock.
///
/// CTA strings are passed in localised; the widget hardcodes no copy.
class PoiWhiskyCard extends StatefulWidget {
  const PoiWhiskyCard({
    super.key,
    required this.waypoint,
    required this.whiskyCta,
    required this.skipCta,
    this.onTaste,
    this.onSkip,
    this.imageUrl,
    this.tastingNotes = const [],
    this.storyText,
    this.overline,
  });

  final Waypoint waypoint;

  /// e.g. "Probieren" (DE) / "Taste" (EN)
  final String whiskyCta;

  /// e.g. "Überspringen" (DE) / "Skip" (EN)
  final String skipCta;

  final VoidCallback? onTaste;
  final VoidCallback? onSkip;
  final String? imageUrl;
  final List<TastingNote> tastingNotes;

  /// Localised story paragraph shown beneath the tasting notes.
  final String? storyText;

  /// Short localised kicker over the headline, e.g. "SPEYSIDE • 12 YEARS".
  final String? overline;

  @override
  State<PoiWhiskyCard> createState() => _PoiWhiskyCardState();
}

class _PoiWhiskyCardState extends State<PoiWhiskyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.dramatic)
      ..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: AppMotion.enter);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppElevation.heroShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroImageSection(
              imageUrl: widget.imageUrl,
              waypoint: widget.waypoint,
              overline: widget.overline,
            ),
            if (widget.tastingNotes.isNotEmpty)
              _TastingNotesGrid(notes: widget.tastingNotes),
            if (widget.storyText != null) _StoryBody(text: widget.storyText!),
            _ActionRow(
              whiskyCta: widget.whiskyCta,
              skipCta: widget.skipCta,
              onTaste: widget.onTaste,
              onSkip: widget.onSkip,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _HeroImageSection extends StatelessWidget {
  const _HeroImageSection({
    required this.imageUrl,
    required this.waypoint,
    this.overline,
  });

  final String? imageUrl;
  final Waypoint waypoint;
  final String? overline;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero photograph
          _HeroImage(imageUrl: imageUrl, waypointName: waypoint.name),

          // Bottom gradient overlay for text legibility
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    AppColors.peat900.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // POI index badge (top-left)
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: _PoiBadge(number: waypoint.orderIndex + 1),
          ),

          // Text overlay (bottom)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: _HeroTextOverlay(waypoint: waypoint, overline: overline),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl, required this.waypointName});

  final String? imageUrl;
  final String waypointName;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null) {
      return Semantics(
        label: waypointName,
        image: true,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => _Placeholder(),
          errorWidget: (context, url, error) => _Placeholder(),
        ),
      );
    }
    return _Placeholder();
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.peat100,
      child: const Center(
        child: Icon(
          Icons.landscape_outlined,
          size: 56,
          color: AppColors.peat300,
        ),
      ),
    );
  }
}

class _PoiBadge extends StatelessWidget {
  const _PoiBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTouchTargets.minimum,
      height: AppTouchTargets.minimum,
      decoration: const BoxDecoration(
        color: AppColors.amber700,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _HeroTextOverlay extends StatelessWidget {
  const _HeroTextOverlay({required this.waypoint, this.overline});

  final Waypoint waypoint;
  final String? overline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overline: region / age. Waypoint carries no region yet, so callers
        // pass it in; the description belongs in the story body, not here.
        if (overline != null)
          Text(
            overline!.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: AppColors.amber100),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: AppSpacing.xs),
        // Headline: waypoint / whisky name
        Text(
          waypoint.name,
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.white,
            shadows: [
              Shadow(
                color: AppColors.peat900.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TastingNotesGrid extends StatelessWidget {
  const _TastingNotesGrid({required this.notes});

  final List<TastingNote> notes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: notes.map((note) => _NoteChip(note: note)).toList(),
      ),
    );
  }
}

class _NoteChip extends StatelessWidget {
  const _NoteChip({required this.note});

  final TastingNote note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.amber100, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(note.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.xs),
          Text(note.label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

class _StoryBody extends StatelessWidget {
  const _StoryBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.whiskyCta,
    required this.skipCta,
    this.onTaste,
    this.onSkip,
  });

  final String whiskyCta;
  final String skipCta;
  final VoidCallback? onTaste;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(onPressed: onSkip, child: Text(skipCta)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton(onPressed: onTaste, child: Text(whiskyCta)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting data model for tasting notes (lightweight, not Freezed)
// ---------------------------------------------------------------------------

class TastingNote {
  const TastingNote({required this.emoji, required this.label});

  final String emoji;
  final String label;
}
