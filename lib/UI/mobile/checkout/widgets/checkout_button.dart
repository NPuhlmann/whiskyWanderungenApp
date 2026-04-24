import 'package:flutter/material.dart';

/// Primary action button for processing payments in checkout
class CheckoutButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final String? text;

  const CheckoutButton({
    super.key,
    required this.enabled,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.outline.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: theme.colorScheme.outline,
          elevation: enabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 20,
              color: enabled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              text ?? 'Jetzt bezahlen',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: enabled
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
