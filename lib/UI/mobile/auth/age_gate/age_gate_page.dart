import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/config/theme/app_tokens.dart';
import 'package:whisky_hikes/data/services/cache/age_gate_service.dart';

/// First-launch legal drinking age gate.
///
/// One route, two states: the question, and the wall shown to anyone who
/// declared themselves under age. Keeping them on one route means one entry in
/// the router's redirect logic instead of two.
class AgeGatePage extends StatelessWidget {
  const AgeGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AgeGateService>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: service.isBlocked ? const _Blocked() : const _Question(),
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(
          Icons.local_bar_rounded,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.appTitle,
          style: theme.textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.ageGateTitle,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.ageGateBody,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        FilledButton(
          onPressed: () =>
              context.read<AgeGateService>().declare(ofLegalAge: true),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(AppTouchTargets.comfortable),
          ),
          child: Text(l10n.iAmLegalAge),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () =>
              context.read<AgeGateService>().declare(ofLegalAge: false),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppTouchTargets.comfortable),
          ),
          child: Text(l10n.ageGateDeny),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.ageGateDisclaimer,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Blocked extends StatelessWidget {
  const _Blocked();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(
          Icons.no_drinks_outlined,
          size: 80,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.ageBlockedTitle,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.ageBlockedBody,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        // A mis-tap must not brick the install permanently. This re-asks the
        // question rather than flipping the answer — and is deliberately the
        // low-emphasis option.
        TextButton(
          onPressed: () => context.read<AgeGateService>().reset(),
          child: Text(l10n.ageGateChangeAnswer),
        ),
      ],
    );
  }
}
