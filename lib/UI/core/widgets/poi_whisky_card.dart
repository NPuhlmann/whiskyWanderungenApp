import 'package:flutter/material.dart';
import '../../../config/theme/app_tokens.dart';
import '../../../domain/models/waypoint.dart';

/// POI / Whisky Card — the storytelling centrepiece of WhiskyHikes.
///
/// ## Screen layout spec (375 pt wide, expandable)
///
/// ┌─────────────────────────────────────────────────┐
/// │  ┌─ Hero image (3:2, full-bleed) ─────────────┐ │
/// │  │  [Distillery landscape photography]        │ │
/// │  │                                            │ │
/// │  │  OVERLINE: "SPEYSIDE • 12 YEARS"  ← amber │ │
/// │  │  DISPLAY: "Glenfarclas 105"        ← serif │ │
/// │  │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░ gradient    │ │
/// │  └────────────────────────────────────────────┘ │
/// │                                                  │
/// │  ┌─ Tasting notes grid ────────────────────────┐ │
/// │  │  [🍯] Honey    [🍫] Chocolate  [🌿] Peat   │ │
/// │  └────────────────────────────────────────────┘ │
/// │                                                  │
/// │  ┌─ Story body ────────────────────────────────┐ │
/// │  │  "You are standing on the ridge above the  │ │
/// │  │   Livet valley. Pour 20 ml and take in the │ │
/// │  │   surroundings before you sip."            │ │
/// │  └────────────────────────────────────────────┘ │
/// │                                                  │
/// │  ┌─ Drink action row ──────────────────────────┐ │
/// │  │  [Überspringen / Skip]  [Probieren / Taste] │ │
/// │  └────────────────────────────────────────────┘ │
/// └─────────────────────────────────────────────────┘
///
/// Photography direction (for WHI-20):
///   • Landscape orientation, golden-hour light preferred
///   • Foreground element: glass / bottle / stone cask
///   • Depth of field to hero the whisky against highland backdrop
///   • Avoid stock "generic whisky on white" imagery
///
/// Accessibility:
///   • All text on gradient overlay must meet WCAG AA (4.5:1 light text)
///   • Taste / Skip buttons are ≥ 48 pt touch targets
///   • Semantic labels on image and note chips
///
/// DE/EN note: [whiskyCta] and [skipCta] accept localised strings from
///             the calling screen; no hardcoded English inside the widget.
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
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.dramatic,
    )..forward();
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
          color: AppColors.white,
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
            ),
            if (widget.tastingNotes.isNotEmpty)
              _TastingNotesGrid(notes: widget.tastingNotes),
            if (widget.storyText != null)
              _StoryBody(text: widget.storyText!),
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
  });

  final String? imageUrl;
  final Waypoint waypoint;

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
            child: _HeroTextOverlay(waypoint: waypoint),
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
      return Image.network(
        url,
        fit: BoxFit.cover,
        semanticLabel: waypointName,
        errorBuilder: (context, error, stack) => _Placeholder(),
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
          semanticLabel: 'Waypoint image placeholder',
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
    return Semantics(
      label: 'Point of interest $number',
      child: Container(
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
      ),
    );
  }
}

class _HeroTextOverlay extends StatelessWidget {
  const _HeroTextOverlay({required this.waypoint});

  final Waypoint waypoint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overline: region / age
        if (waypoint.description.isNotEmpty)
          Text(
            waypoint.description.toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: AppColors.amber100,
            ),
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
    return Semantics(
      label: '${note.label} tasting note',
      child: Container(
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
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.peat700,
          fontStyle: FontStyle.italic,
        ),
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
            child: OutlinedButton(
              onPressed: onSkip,
              child: Text(skipCta),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onTaste,
              child: Text(whiskyCta),
            ),
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

  // Common whisky tasting notes factory
  static const TastingNote honey = TastingNote(emoji: '🍯', label: 'Honey');
  static const TastingNote chocolate = TastingNote(emoji: '🍫', label: 'Chocolate');
  static const TastingNote peat = TastingNote(emoji: '🌿', label: 'Peat');
  static const TastingNote vanilla = TastingNote(emoji: '🍦', label: 'Vanilla');
  static const TastingNote fruit = TastingNote(emoji: '🍎', label: 'Fruit');
  static const TastingNote oak = TastingNote(emoji: '🌳', label: 'Oak');
  static const TastingNote smoke = TastingNote(emoji: '🔥', label: 'Smoke');
  static const TastingNote spice = TastingNote(emoji: '🌶', label: 'Spice');
  static const TastingNote floral = TastingNote(emoji: '🌸', label: 'Floral');
  static const TastingNote citrus = TastingNote(emoji: '🍋', label: 'Citrus');
}
