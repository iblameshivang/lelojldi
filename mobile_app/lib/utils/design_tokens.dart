/// Krishi-Saarthi Field OS — Stitch Tactile Pragmatism Design Tokens
/// Single source of truth for all color, typography, and spacing constants.
/// Every screen MUST import this file — NO local color definitions allowed.
library design_tokens;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// COLOR PALETTE (from Stitch Design System)
// ─────────────────────────────────────────

/// Background & Surface
const Color colorBg         = Color(0xFFF8FAF6);
const Color colorSurface    = Color(0xFFFDFBF7);
const Color colorCard       = Color(0xFFFFFFFF);
const Color colorHairline   = Color(0xFFE7E4DC);

/// Primary — Forest Emerald
const Color colorPrimary      = Color(0xFF1B4332);
const Color colorPrimaryDeep  = Color(0xFF0D2B1F);
const Color colorPrimaryLight = Color(0xFF2D6A4F);
const Color colorPrimarySoft  = Color(0xFFE8F0EC);
const Color colorPrimaryMid   = Color(0xFF1E5E3A);
const Color colorPrimaryContainer = Color(0xFF94D5A8);

/// Secondary — Harvest Amber / Warm Earth
const Color colorAmber      = Color(0xFFD97706);
const Color colorEarth      = Color(0xFF8B5A2B);
const Color colorOchre      = Color(0xFFC87D32);
const Color colorOchreLight = Color(0xFFFAF3E8);

/// Tertiary — Soil Terracotta
const Color colorTerracotta = Color(0xFFB45309);
const Color colorEarthAlert = Color(0xFF9B4522);

/// Text
const Color colorStoneText  = Color(0xFF1E2420);
const Color colorInkText    = Color(0xFF111827);
const Color colorStoneMuted = Color(0xFF6E756F);
const Color colorSlate      = Color(0xFF4B5563);

/// Status — Mesh Active
const Color colorMeshActive    = Color(0xFF047857);
const Color colorMeshActiveBg  = Color(0xFFECFDF5);
const Color colorMeshBorder    = Color(0xFFA7F3D0);

/// Status — Local AI Edge
const Color colorAiEdge        = Color(0xFF4338CA);
const Color colorAiEdgeBg      = Color(0xFFEEF2FF);
const Color colorAiEdgeBorder  = Color(0xFFC7D2FE);

/// Status — Critical Field Alert
const Color colorCritical       = Color(0xFFB91C1C);
const Color colorCriticalBg     = Color(0xFFFEE2E2);
const Color colorCriticalBorder = Color(0xFFFCA5A5);

/// Status — Warning
const Color colorWarning       = Color(0xFFD97706);
const Color colorWarningBg     = Color(0xFFFFFBEB);
const Color colorWarningBorder = Color(0xFFFCD34D);

// ─────────────────────────────────────────
// SPACING & RADII
// ─────────────────────────────────────────

const double radiusSm  = 8.0;
const double radiusMd  = 12.0;
const double radiusLg  = 16.0;
const double radiusXl  = 24.0;
const double radiusFull = 100.0;
const double spacingXs = 4.0;
const double spacingSm = 8.0;
const double spacingMd = 16.0;
const double spacingLg = 24.0;
const double spacingXl = 32.0;
const double touchTarget = 48.0;

// ─────────────────────────────────────────
// TYPOGRAPHY
// ─────────────────────────────────────────

const TextStyle tsHeadlineLg = TextStyle(
  fontFamily: 'PlusJakartaSans',
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: colorStoneText,
  letterSpacing: -0.3,
  height: 1.2,
);

const TextStyle tsHeadlineMd = TextStyle(
  fontFamily: 'PlusJakartaSans',
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: colorStoneText,
  letterSpacing: -0.2,
);

const TextStyle tsHeadlineSm = TextStyle(
  fontFamily: 'PlusJakartaSans',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: colorStoneText,
);

const TextStyle tsLabel = TextStyle(
  fontFamily: 'PlusJakartaSans',
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: colorStoneMuted,
  letterSpacing: 0.8,
);

const TextStyle tsBody = TextStyle(
  fontFamily: 'NotoSans',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: colorSlate,
  height: 1.6,
);

const TextStyle tsBodySm = TextStyle(
  fontFamily: 'NotoSans',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: colorStoneMuted,
  height: 1.5,
);

const TextStyle tsDevanagari = TextStyle(
  fontFamily: 'NotoSansDevanagari',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: colorStoneText,
);

const TextStyle tsMono = TextStyle(
  fontFamily: 'JetBrainsMono',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: colorStoneMuted,
  letterSpacing: 0.5,
);

// ─────────────────────────────────────────
// REUSABLE WIDGET BUILDERS
// ─────────────────────────────────────────

PreferredSizeWidget buildKrishiAppBar({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String emoji,
  Color backgroundColor = colorBg,
  List<Widget>? actions,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(64),
    child: Container(
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.97),
        border: const Border(bottom: BorderSide(color: colorHairline, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(radiusFull),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorHairline),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: colorPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: tsHeadlineSm),
                    Text(subtitle, style: tsLabel),
                  ],
                ),
              ),
              if (actions != null) ...actions,
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildCard({
  required Widget child,
  EdgeInsets? padding,
  Color? bgColor,
  Color? borderColor,
  double? radius,
}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(spacingMd),
    decoration: BoxDecoration(
      color: bgColor ?? colorCard,
      borderRadius: BorderRadius.circular(radius ?? radiusMd),
      border: Border.all(color: borderColor ?? colorHairline),
    ),
    child: child,
  );
}

Widget buildStatusPill({
  required String label,
  required Color color,
  required Color bgColor,
  required Color borderColor,
  IconData? icon,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radiusFull),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget buildSectionHeader(String indexLabel, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: spacingSm),
    child: Row(
      children: [
        Text(
          '$indexLabel / ',
          style: tsLabel.copyWith(color: colorAmber),
        ),
        Text(title.toUpperCase(), style: tsLabel),
      ],
    ),
  );
}

Widget buildPrimaryButton({
  required String label,
  required VoidCallback onTap,
  IconData? icon,
  bool isLoading = false,
}) {
  return GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      height: touchTarget,
      decoration: BoxDecoration(
        color: isLoading ? colorPrimaryLight : colorPrimary,
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
                  Text(label, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
      ),
    ),
  );
}

Widget buildAmberButton({
  required String label,
  required VoidCallback onTap,
  IconData? icon,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: touchTarget,
      decoration: BoxDecoration(color: colorAmber, borderRadius: BorderRadius.circular(radiusMd)),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
            Text(label, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    ),
  );
}

Widget buildCriticalAlert(String message) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm + 2),
    decoration: BoxDecoration(
      color: colorCriticalBg,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: colorCriticalBorder),
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: colorCritical, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600, color: colorCritical))),
      ],
    ),
  );
}

Widget buildInfoBanner(String message, {Color? color, Color? bgColor, IconData? icon}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingSm + 2),
    decoration: BoxDecoration(
      color: bgColor ?? colorPrimarySoft,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: colorMeshBorder),
    ),
    child: Row(
      children: [
        Icon(icon ?? Icons.info_outline_rounded, color: color ?? colorPrimary, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w500, color: color ?? colorPrimary))),
      ],
    ),
  );
}
