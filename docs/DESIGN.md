# AutoHub Design System

NESEMOS Veteran Auto Hub customer app. Ukrainian-first, iOS-first, phone-only.

Source of truth: `lib/core/theme/*`. The JSON mirror lives at `docs/design-tokens.json`. A self-contained HTML preview lives at `docs/design-preview.html`.

---

## 1. Principles

1. **Flat, not floaty.** No drop shadows. Surfaces stand apart by hairline borders + background contrast, not depth.
2. **Two foreground colors max per surface.** Yellow accents on black hero, near-black on cream. Avoid stacking gradients or mid-tones.
3. **Pills for primary action.** The yellow pill CTA is the unmistakable next-step affordance.
4. **One weight axis.** Inter at 400 / 500 only. Hierarchy comes from size, color, and case — not bold/black/light.
5. **Restraint over motion.** Only essential motion (taps, route transitions). Avoid scroll-triggered or decorative animation.
6. **Phone-first, portrait-only.** Orientation locked in iOS Info.plist and AndroidManifest. Tablet portrait clamps to `contentMaxWidth = 480pt`.

---

## 2. Color

Brand palette is a warm-mustard / cream / near-black trio inherited from `nesemosautohub.com`.

| Token | Hex | Role |
|---|---|---|
| `brand.yellow` | `#F0CC50` | Primary CTA, accents, status overlines on dark cards |
| `brand.yellowDark` | `#E0B940` | Hover / pressed state for yellow |
| `brand.yellowSoft` | `#F0CC50 @ 20%` | Info banner background, soft fill |
| `brand.black` | `#1A1A1A` | Text, dark hero cards, avatar circle |
| `surface.background` | `#FAF9F6` | App background — warm cream |
| `surface.surface` | `#FFFFFF` | Cards, inputs |
| `surface.surfaceVariant` | `#F5F3EE` | Canceled cards, soft fills |
| `text.primary` | `#1A1A1A` | Body, headings |
| `text.secondary` | `#666666` | Captions, subtitles |
| `text.tertiary` | `#888888` | Placeholders |
| `text.disabled` | `#BBBBBB` | Chevrons, disabled labels |
| `border.default` | `#E5E2DD` | Card hairline, dividers |
| `border.strong` | `#C8C5BD` | Focused input border |
| `semantic.error` | `#C04545` | Destructive CTA, canceled status badge |
| `semantic.errorSoft` | `#C04545 @ 10%` | Warning bubble background |
| `semantic.onError` | `#FFFFFF` | Text on destructive button (account delete) |

**Contrast quick-check** (WCAG AA target: 4.5:1 body, 3:1 large):

| Pair | Ratio | Status |
|---|---|---|
| `text.primary` on `surface.surface` | 17.2:1 | ✓ AAA |
| `text.primary` on `surface.background` | 16.5:1 | ✓ AAA |
| `text.secondary` on `surface.background` | 5.5:1 | ✓ AA |
| `text.tertiary` on `surface.background` | 3.9:1 | ✓ AA large |
| `onYellow` (`#1A1A1A`) on `brand.yellow` | 10.7:1 | ✓ AAA |
| `brand.yellow` on `brand.black` (overline) | 11.5:1 | ✓ AAA |
| `onBlack` (white) on `brand.black` | 17.4:1 | ✓ AAA |
| `semantic.error` on `surface.background` | 4.9:1 | ✓ AA |
| `onError` (white) on `semantic.error` | 5.2:1 | ✓ AA |

---

## 3. Typography

**Font:** Inter (via `google_fonts`). If a custom face is added, swap inside `AppTypography._base` only.

**Weights used:** 400 (body), 500 (headings, CTAs, micro-labels).

**Scale:**

| Token | Size | Weight | Line | Letter | Use |
|---|---|---|---|---|---|
| `displayLarge` | 32 | 500 | 1.1 | 0 | OTP digit display |
| `displayMedium` | 28 | 500 | 1.1 | 0 | Hero numerals |
| `headlineLarge` | 24 | 500 | 1.2 | 0 | Page-level "Who are you?" prompts |
| `headlineMedium` | 22 | 500 | 1.2 | 0 | Screen heading |
| `headlineSmall` | 20 | 500 | 1.25 | 0 | Section heading, dialog title |
| `titleLarge` | 16 | 500 | 1.3 | 0 | AppBar title, user name |
| `titleMedium` | 14 | 500 | 1.3 | 0 | Pending card title |
| `titleSmall` | 12 | 500 | 1.3 | 0 | Card titles, settings rows |
| `bodyLarge` | 14 | 400 | 1.5 | 0 | Dialog body, primary copy |
| `bodyMedium` | 12 | 400 | 1.5 | 0 | Default body |
| `bodySmall` | 11 | 400 | 1.5 | 0 | Captions (uses `text.secondary` by default) |
| `labelLarge` | 14 | 500 | 1.2 | 0 | Button labels |
| `labelMedium` | 12 | 500 | 1.2 | 0 | Smaller labels, badges |
| `labelSmall` | 10 | 500 | 1.2 | 1.5 | Micro labels (uses `text.secondary` by default) |
| `overline` | 10 | 500 | 1.2 | 1.8 | UPPERCASE status overlines (`У РЕМОНТІ`) |
| `caption` | 10 | 400 | 1.4 | 0 | Mute metadata (uses `text.tertiary`) |

**Case conventions:**
- Sentence case / Title Case for headings — `Коли вам зручно?`
- UPPERCASE with `letterSpacing 1.5–1.8` for micro-labels & status badges — `У РЕМОНТІ`, `ІСТОРІЯ`
- `Text(label.toUpperCase(), style: AppTypography.overline)` — never bake case into the ARB key

---

## 4. Spacing

Base scale (in dp/pt):

| Token | px |
|---|---|
| `xxs` | 4 |
| `xs` | 6 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |
| `xxl` | 24 |
| `xxxl` | 32 |

Component tokens (semantic, used inside `AppTheme`):

| Token | px | Where |
|---|---|---|
| `btnH` | 20 | Button horizontal padding |
| `btnV` | 14 | Button vertical padding |
| `inputH` | 14 | Input horizontal padding |
| `inputV` | 14 | Input vertical padding |
| `chipH` | 14 | Chip horizontal padding |
| `chipV` | 8 | Chip vertical padding |

Layout:

| Token | px | Where |
|---|---|---|
| `contentMaxWidth` | 480 | `AppShell.body` clamp for iPad portrait |

**Rule:** if you reach for a number, you reach for a token. Magic numbers go in design review.

---

## 5. Radii

All radii live in `AppRadii` with pre-built `BorderRadius.all(...)` shortcuts.

| Token | px | Use |
|---|---|---|
| `xs` | 8 | Badges, micro-pills |
| `sm` | 12 | Chips, small list rows |
| `md` | 16 | Default inputs, cards |
| `lg` | 18 | Content cards |
| `xl` | 22 | Hero cards, photo slots |
| `xxl` | 32 | Large hero blocks |
| `pill` | 999 | All primary/secondary CTAs |

**Rule:** every container is rounded. The design language has zero sharp 90° corners.

---

## 6. Sizes (icons & fixed containers)

| Token | px | Use |
|---|---|---|
| `AppIconSize.sm` | 18 | Inline icons, info bubbles |
| `AppIconSize.md` | 20 | Default theme icon, prefix icons |
| `AppIconSize.lg` | 22 | App bar icons, settings-row icons |
| `AppIconSize.xl` | 24 | Service-picker tile icons |
| `AppIconSize.hero` | 36 | Empty-state, error-state, account-delete warning |
| `AppSizes.avatar` | 56 | Round avatar, square car-icon tile |
| `AppSizes.iconBubble` | 72 | Empty-state / warning circle background |
| `AppSizes.otpSlotHeight` | 56 | OTP single-digit slot |
| `AppSizes.ctaMinHeight` | 50 | All pill CTA minimum height |

---

## 7. Components (themed defaults)

### Buttons

All three pill variants share `pillAll` radius, full-width minimum, `btnH × btnV` padding, `labelLarge` text, and 50pt min height:

| Variant | Background | Foreground | Use |
|---|---|---|---|
| `ElevatedButton` | `brand.yellow` | `onYellow` | Primary CTA |
| `FilledButton` | `brand.black` | `onBlack` | Secondary CTA (booking confirm, next-step) |
| `OutlinedButton` | transparent + `border.strong` 0.5 | `text.primary` | Tertiary / cancel-from-detail |

`TextButton` uses `md × sm` padding + `labelMedium`. Disabled state for `ElevatedButton` greys to `surface.surfaceVariant` + `text.disabled`.

### Inputs

`OutlineInputBorder` with `radius.md` and `borderSide: BorderSide.none` — the surface fill (`#FFFFFF`) does the visual lifting. Focused border is `brand.yellow` 1.5px. Error border is `semantic.error` 1px.

### Cards

Always `radius.lg`, `surface.surface` fill, `border.default` 0.5px hairline. No elevation. Hero cards step up to `radius.xl` and `brand.black` background with yellow overlines.

### Chips

`radius.pill`, `chipH × chipV` padding, `labelMedium` text. `surface.surface` default, `brand.yellow` when selected.

### Switches

Thumb: white (off) / black (on). Track: `border.strong` (off) / `brand.yellow` (on). No outline.

### Snackbars

Floating, `radius.md`, `brand.black` background, `onBlack` text, `brand.yellow` action text.

### Dialogs

`radius.xl`, `surface.surface` fill, `headlineSmall` title, `bodyLarge` (`text.secondary`) body.

### Bottom navigation

`background` fill, no elevation, selected `text.primary`, unselected `text.disabled`, labels hidden — icons only. Tooltip + semantic label per tab.

### ButtonSpinner

`core/widgets/button_spinner.dart`: inline 16pt CircularProgressIndicator sized for pill CTAs. Use as the `child` of an `ElevatedButton`/`FilledButton` whose `onPressed` is in-flight — replaces the label text without resizing the button. Stroke colour follows the active button foreground (`onYellow` / `onBlack` / `onError`).

### showConfirmDialog

`core/widgets/confirm_dialog.dart`: `Future<bool> showConfirmDialog(context, {required title, body, confirmLabel, cancelLabel, destructive = false})`. Wraps an `AlertDialog` with the project's `radius.xl` + typography defaults. `destructive: true` flips the confirm button to the `error` palette with `onError` foreground. Used by Order cancel + Account delete.

---

## 8. Patterns

### Status hero (in-progress order)

Black `brandBlack` card, `radius.xl`. Yellow `overline` status (`У РЕМОНТІ`). Progress bar 4pt with `border.strong @ 40%` track + `brand.yellow` fill. ETA in yellow `labelMedium`.

### Status card (pending)

White card, `radius.lg`, `border.default` hairline. Status as plain `bodySmall`. Trailing chevron in `text.disabled`.

### Status card (canceled)

`surface.surfaceVariant` fill — visually muted. Status in `semantic.error` `bodySmall`. No chevron.

### Empty state

`AppSizes.iconBubble` round container in `brand.yellowSoft`, `AppIconSize.hero` icon in `brand.black`, `headlineSmall` title, `bodyMedium` (`text.secondary`) subtitle, optional yellow pill CTA.

### Error state

Same shape as Empty, but bubble flipped: black background, yellow icon.

### Form field row

`titleSmall` label inside the field; placeholder text `bodyMedium` with `text.tertiary`. Required-error string below in `bodySmall` `semantic.error`.

---

## 9. Accessibility checklist

- ✅ All interactive icons have `semanticLabel` or tooltip
- ✅ `_SettingsRow`, `_OrderCard`, photo slots all wrapped in `Semantics(button: true, label: ...)`
- ✅ `MergeSemantics` / `ExcludeSemantics` used around decorative timeline rails and avatar initials
- ✅ Contrast ratios pass WCAG AA across the table in §2
- ✅ Tappable targets ≥ 44pt (CTAs are 50pt; card tap targets cover full card)
- ⚠ **Open:** dark mode (intentionally deferred)
- ⚠ **Open:** dynamic type — text scales with system font but hasn't been audited at extreme settings (`UIContentSizeCategoryAccessibilityXXXL`)

---

## 10. Out of scope (deferred follow-ups)

| Item | Reason |
|---|---|
| Dark theme | Brand reference is light-first; revisit after launch |
| Tablet/desktop layouts | Phone-only target; clamp at 480pt is the placeholder |
| Custom font face | Inter is the working stand-in; brand custom can swap in `_base()` |
| Cupertino route transitions | Material slides are the framework default; no project-wide override yet |

**Landed since the previous audit:**

- Shared-element `Hero` on in-progress, pending, and canceled order cards → matching detail blocks.
- `Skeletonizer` loading shimmer on OrderDetail + History (replaces the previous spinner).
- ARB-based localization (`uk`, `en`) — `context.l10n` extension wired into every screen.
- Sentry telemetry (`bootstrapSentry`) — no-op when `SENTRY_DSN` is unset.

---

## 11. Drift prevention

`flutter analyze` will not catch theme drift; an audit pass is the only safety net. To re-run:

```bash
# 1. Confirm no raw hex outside the theme:
grep -rE "Color\(0x" lib/ --include='*.dart' | grep -v "/theme/"

# 2. Confirm no raw TextStyle outside the theme:
grep -rE "TextStyle\(" lib/ --include='*.dart' | grep -v "/theme/"

# 3. Confirm no magic spacing or sizing in screens:
grep -rE "(padding|margin|width|height|size):\s+(const\s+)?\d" lib/ --include='*.dart' \
  | grep -vE "AppSpacing\.|AppIconSize\.|AppSizes\.|/theme/|/widgets/(states|theme)_showcase"
```

If any of the above prints results — there's drift; fix or add a token.

---

## 12. References

- Brand site: `nesemosautohub.com`
- Mockup screens: `mockup/Screenshot 2026-05-11 at *.png` (18 designs)
- Live tokens (Dart): `lib/core/theme/*`
- JSON mirror: `docs/design-tokens.json`
- Interactive preview: `docs/design-preview.html` (open in any browser)
