import 'package:flutter/material.dart';
import '../config/app_colors.dart';

// ── Primary Button ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String   label;
  final VoidCallback? onPressed;
  final bool     loading;
  final IconData? icon;
  final Color?   color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          disabledBackgroundColor: AppColors.textLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

// ── Outlined Button ───────────────────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    ),
  );
}

// ── Custom TextField ──────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String         label;
  final String?        hint;
  final IconData?      prefixIcon;
  final Widget?        suffix;
  final bool           obscure;
  final TextEditingController? controller;
  final String?        Function(String?)? validator;
  final TextInputType? keyboardType;
  final int            maxLines;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscure = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark,
      )),
      const SizedBox(height: 6),
      TextFormField(
        controller:    controller,
        obscureText:   obscure,
        keyboardType:  keyboardType,
        maxLines:      maxLines,
        onChanged:     onChanged,
        validator:     validator,
        decoration: InputDecoration(
          hintText:     hint,
          prefixIcon:   prefixIcon != null ? Icon(prefixIcon, color: AppColors.textGray, size: 20) : null,
          suffixIcon:   suffix,
        ),
      ),
    ],
  );
}

// ── Urgency Badge ─────────────────────────────────────────────────────────────
class UrgencyBadge extends StatelessWidget {
  final String urgency;
  const UrgencyBadge({super.key, required this.urgency});

  Color get color => urgency == 'alta'
      ? AppColors.danger
      : urgency == 'media'
          ? AppColors.warning
          : AppColors.success;

  String get label => urgency == 'alta'
      ? '❗ URGENCIA ALTA'
      : urgency == 'media'
          ? '⚠️ URGENCIA MEDIA'
          : 'ℹ️ URGENCIA BAJA';

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label, style: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700, color: color,
    )),
  );
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark,
      )),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryMid,
          )),
        ),
    ],
  );
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double  radius;

  const UserAvatar({super.key, this.imageUrl, this.radius = 24});

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: AppColors.primaryBg,
    backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
        ? NetworkImage(imageUrl!)
        : null,
    child: (imageUrl == null || imageUrl!.isEmpty)
        ? Icon(Icons.person, size: radius, color: AppColors.primary)
        : null,
  );
}

// ── Star Rating ───────────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final int?   reviews;
  final double size;

  const StarRating({super.key, required this.rating, this.reviews, this.size = 14});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, color: AppColors.star, size: size),
      const SizedBox(width: 3),
      Text('${rating.toStringAsFixed(1)}',
          style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      if (reviews != null) ...[
        const SizedBox(width: 2),
        Text('($reviews)', style: TextStyle(fontSize: size - 1, color: AppColors.textGray)),
      ],
    ],
  );
}

// ── Error / Empty State ───────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String?  subtitle;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMid,
          ), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: const TextStyle(color: AppColors.textGray), textAlign: TextAlign.center),
          ],
        ],
      ),
    ),
  );
}
