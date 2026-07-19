import 'package:flutter/material.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/config/theme/app_tokens.dart';

import 'age_gate_view_model.dart';

/// Size of the single hero icon on each of the gate's two states.
const _heroIconSize = 80.0;

/// First-launch legal drinking age gate.
///
/// One route, two states: the question, and the wall shown to anyone who
/// declared themselves under age. Keeping them on one route means one entry in
/// the router's redirect logic instead of two.
///
/// The wall is deliberately final — there is no in-app way back out of it.
/// Softening that is a compliance decision (JuSchG/HWG), not a UI one.
class AgeGatePage extends StatelessWidget {
  const AgeGatePage({super.key, required this.viewModel});

  final AgeGateViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => viewModel.isBlocked
                ? const _Blocked()
                : _Question(viewModel: viewModel),
          ),
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.viewModel});

  final AgeGateViewModel viewModel;

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
          size: _heroIconSize,
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
          onPressed: () => viewModel.declare(ofLegalAge: true),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(AppTouchTargets.comfortable),
          ),
          child: Text(l10n.iAmLegalAge),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () => viewModel.declare(ofLegalAge: false),
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
          size: _heroIconSize,
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
      ],
    );
  }
}
