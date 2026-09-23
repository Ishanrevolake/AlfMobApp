import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AlfBrand extends StatelessWidget {
  final bool compact;
  const AlfBrand({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: compact ? 30 : 36,
        height: compact ? 30 : 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          'A',
          style: TextStyle(
            fontFamily: 'AppSans',
            fontSize: compact ? 15 : 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkTextOverRed,
          ),
        ),
      ),
      const SizedBox(width: 10),
      const Text(
        'ALFA LEE',
        style: TextStyle(
          fontFamily: 'AppSans',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    ],
  );
}

class AlfPageTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  const AlfPageTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(letterSpacing: 0.4),
      ),
      const SizedBox(height: 7),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: title),
            const TextSpan(
              text: '.',
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ],
        ),
        style: Theme.of(context).textTheme.displayLarge,
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 7),
        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      ],
    ],
  );
}

class AlfPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  const AlfPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? AppColors.primaryPanel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.subtleBorder),
    ),
    child: child,
  );
}

class AlfSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const AlfSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(letterSpacing: 0.4),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    ),
  );
}

class AlfStatusChip extends StatelessWidget {
  final String label;
  final bool positive;
  final bool muted;
  const AlfStatusChip(
    this.label, {
    super.key,
    this.positive = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.mutedText : AppColors.primaryRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: positive ? AppColors.primaryRed : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: positive
              ? AppColors.primaryRed
              : (muted ? AppColors.strongBorder : AppColors.redBorder),
        ),
      ),
      child: Text(
        label.replaceAll('_', ' ').toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: positive ? AppColors.darkTextOverRed : color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AlfStatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  const AlfStatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => AlfPanel(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) Icon(icon, color: AppColors.primaryRed, size: 18),
        if (icon != null) const SizedBox(height: 12),
        Text(value, style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    ),
  );
}

class AlfAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const AlfAvatar({super.key, required this.initials, this.size = 46});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [AppColors.primaryRed, AppColors.deepRed],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Text(
      initials.isEmpty ? 'A' : initials,
      style: TextStyle(
        fontFamily: 'AppSans',
        fontSize: size * .34,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextOverRed,
      ),
    ),
  );
}

class AlfEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const AlfEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34, color: AppColors.faintText),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class AlfAsyncError extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  const AlfAsyncError({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) => AlfEmptyState(
    icon: Icons.cloud_off_outlined,
    title: 'Unable to load data',
    message: error.toString(),
  );
}
