import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/config/theme/app_tokens.dart';

import 'magic_link_view_model.dart';

/// Passwordless sign-in. Step one collects the email, step two the 6-digit
/// code from that email. The emailed link also works — it deep-links back into
/// the app and the router picks up the new session.
class MagicLinkPage extends StatefulWidget {
  const MagicLinkPage({super.key, required this.viewModel});

  final MagicLinkViewModel viewModel;

  @override
  State<MagicLinkPage> createState() => _MagicLinkPageState();
}

class _MagicLinkPageState extends State<MagicLinkPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_message(e))));
    }
  }

  /// Validation failures get a localized message; anything else (network,
  /// Supabase rate limiting) falls back to the raw text, as elsewhere in auth.
  String _message(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is FormatException) {
      return widget.viewModel.linkSent
          ? l10n.enterCodeFromEmail
          : l10n.invalidEmailAddress;
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signInWithMagicLink)),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: vm.linkSent
                ? _codeStep(context, vm, l10n)
                : _emailStep(context, vm, l10n),
          );
        },
      ),
    );
  }

  List<Widget> _emailStep(
    BuildContext context,
    MagicLinkViewModel vm,
    AppLocalizations l10n,
  ) {
    return [
      Text(l10n.magicLinkIntro, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: AppSpacing.lg),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        decoration: InputDecoration(labelText: l10n.email),
      ),
      const SizedBox(height: AppSpacing.lg),
      FilledButton(
        onPressed: vm.isBusy
            ? null
            : () => _run(() => vm.sendMagicLink(_emailController.text)),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppTouchTargets.comfortable),
        ),
        child: vm.isBusy ? const _Spinner() : Text(l10n.magicLinkSend),
      ),
    ];
  }

  List<Widget> _codeStep(
    BuildContext context,
    MagicLinkViewModel vm,
    AppLocalizations l10n,
  ) {
    return [
      Text(
        l10n.magicLinkSentTo(vm.email),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: AppSpacing.lg),
      TextField(
        controller: _codeController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 6,
        autofillHints: const [AutofillHints.oneTimeCode],
        decoration: InputDecoration(labelText: l10n.magicLinkCodeLabel),
      ),
      const SizedBox(height: AppSpacing.md),
      FilledButton(
        onPressed: vm.isBusy
            ? null
            : () => _run(() => vm.verifyCode(_codeController.text)),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppTouchTargets.comfortable),
        ),
        child: vm.isBusy ? const _Spinner() : Text(l10n.magicLinkVerify),
      ),
      const SizedBox(height: AppSpacing.sm),
      TextButton(
        onPressed: vm.isBusy
            ? null
            : () {
                _codeController.clear();
                vm.restart();
              },
        child: Text(l10n.magicLinkUseDifferentEmail),
      ),
    ];
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
