import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_tokens.dart';
import '../../../domain/models/waypoint.dart';
import '../../core/widgets/poi_whisky_card.dart';
import 'poi_details_view_model.dart';

class PoiDetailsPage extends StatelessWidget {
  const PoiDetailsPage({super.key, required this.waypoint});

  final Waypoint waypoint;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PoiDetailsViewModel(waypoint: waypoint),
      child: const _PoiDetailsView(),
    );
  }
}

class _PoiDetailsView extends StatelessWidget {
  const _PoiDetailsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PoiDetailsViewModel>();
    final waypoint = vm.waypoint;
    final imageUrl =
        waypoint.images.isNotEmpty ? waypoint.images.first : null;

    return Scaffold(
      backgroundColor: AppColors.peat100,
      appBar: AppBar(
        title: Text(
          waypoint.name,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.peat900),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.peat900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PoiWhiskyCard(
              waypoint: waypoint,
              whiskyCta: vm.isAddedToOrder
                  ? 'Zur Bestellung hinzugefügt ✓'
                  : 'Zur Bestellung hinzufügen',
              skipCta: 'Schließen',
              imageUrl: imageUrl,
              tastingNotes: _defaultNotes,
              storyText: waypoint.description.isNotEmpty
                  ? waypoint.description
                  : null,
              onTaste: vm.isAddedToOrder
                  ? null
                  : () => _onAddToOrder(context, vm),
              onSkip: () => Navigator.of(context).pop(),
            ),
            _WhiskyMetadataCard(waypoint: waypoint),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _onAddToOrder(BuildContext context, PoiDetailsViewModel vm) {
    vm.addToOrder();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Zur Bestellung hinzugefügt!'),
        backgroundColor: AppColors.green700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  static const List<TastingNote> _defaultNotes = [
    TastingNote.honey,
    TastingNote.vanilla,
    TastingNote.oak,
  ];
}

class _WhiskyMetadataCard extends StatelessWidget {
  const _WhiskyMetadataCard({required this.waypoint});

  final Waypoint waypoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppElevation.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Whisky-Profil',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _MetaRow(
            label: 'Probe Nr.',
            value: '${waypoint.orderIndex + 1}',
          ),
          _MetaRow(
            label: 'Region',
            value: _extractRegion(waypoint.description),
          ),
          const _MetaRow(label: 'Brennerei', value: '—'),
          const _MetaRow(label: 'ABV', value: '—'),
          const _MetaRow(label: 'Reifung', value: '—'),
          const SizedBox(height: AppSpacing.md),
          _TastingStructure(description: waypoint.description),
        ],
      ),
    );
  }

  String _extractRegion(String description) {
    if (description.isEmpty) return '—';
    // Description used as "REGION • AGE" overline in seed data
    final parts = description.split('•');
    return parts.first.trim().isNotEmpty ? parts.first.trim() : description;
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.peat500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.titleMedium),
          ),
        ],
      ),
    );
  }
}

class _TastingStructure extends StatelessWidget {
  const _TastingStructure({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final sections = _parseSections(description);
    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.peat100, height: AppSpacing.lg),
        Text('Verkostungsnotizen', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        ...sections.entries.map(
          (e) => _TastingSection(label: e.key, text: e.value),
        ),
      ],
    );
  }

  Map<String, String> _parseSections(String text) {
    final result = <String, String>{};
    final lower = text.toLowerCase();

    for (final key in ['nose', 'palate', 'finish']) {
      final idx = lower.indexOf('$key:');
      if (idx == -1) continue;
      final start = idx + key.length + 1;
      final nextKeys = ['nose', 'palate', 'finish']
          .where((k) => k != key)
          .map((k) => lower.indexOf('$k:', start))
          .where((i) => i > start)
          .toList()
        ..sort();
      final end = nextKeys.isNotEmpty ? nextKeys.first : text.length;
      final value = text.substring(start, end).trim();
      if (value.isNotEmpty) {
        result[_labelFor(key)] = value;
      }
    }
    return result;
  }

  String _labelFor(String key) => switch (key) {
        'nose' => 'Nase',
        'palate' => 'Gaumen',
        'finish' => 'Abgang',
        _ => key,
      };
}

class _TastingSection extends StatelessWidget {
  const _TastingSection({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: AppColors.amber700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.peat700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
