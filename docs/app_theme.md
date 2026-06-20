# Pigeon Planet — App Theme

## Typography

- **Font:** Cairo (Google Fonts)
- **Direction:** RTL (Arabic locale)

---

## Color Palette

### Green (Primary Brand)

| Token | Hex | Preview | Usage |
|---|---|---|---|
| `primary` | `#3DB54A` | 🟢 | Main brand color, AppBar, buttons, active states, links |
| `primaryDark` | `#2B8A3E` | 🟩 | Pressed/hover state of primary |
| `primaryLight` | `#EBF9EE` | 🌿 | Light green backgrounds, chips, highlights |

### Status Green

| Token | Hex | Usage |
|---|---|---|
| `success` | `#43A047` | Success states, checkmarks |

### Orange (Service Provider Accent)

| Token | Hex | Usage |
|---|---|---|
| `orange` | `#F57C20` | Service provider accent |
| `orangeLight` | `#FEF4EC` | Orange tint backgrounds |

### Text

| Token | Hex | Usage |
|---|---|---|
| `textPrimary` | `#1C1C1C` | Body text, headings |
| `textSecondary` | `#7A7A7A` | Captions, subtitles |
| `textHint` | `#B0B0B0` | Input placeholders |
| `textLink` | `#3DB54A` | Hyperlinks (same as primary) |

### Backgrounds

| Token | Hex | Usage |
|---|---|---|
| `white` | `#FFFFFF` | Cards, surfaces |
| `scaffoldBg` | `#FFFFFF` | Page background |
| `inputBg` | `#F5F5F5` | Text field fill |
| `pageBackground` | `#F5F5F7` | Section/list page background |

### Borders & Dividers

| Token | Hex | Usage |
|---|---|---|
| `border` | `#E5E5E5` | Input borders, card outlines |
| `divider` | `#EEEEEE` | List separators |

### Status

| Token | Hex | Usage |
|---|---|---|
| `error` | `#E53935` | Error borders, error text |
| `success` | `#43A047` | Success indicators |

### Extra

| Token | Hex | Usage |
|---|---|---|
| `purple` | `#7C3AED` | — |
| `purpleLight` | `#F3EEFE` | — |
| `blue` | `#1565C0` | — |
| `blueLight` | `#E3F2FD` | — |
| `red` | `#D32F2F` | — |
| `redLight` | `#FFEBEE` | — |

---

## Theme Components

### AppBar
- Background: `primary` (`#3DB54A`)
- Foreground / icons / title: white
- Elevation: 0
- Title font: Cairo 18px Bold

### ElevatedButton
- Background: `primary`
- Text: white, Cairo 16px Bold
- Min size: full width × 52px
- Border radius: 12px

### InputDecoration
- Fill: `inputBg` (`#F5F5F5`)
- Border radius: 10px
- No border in default / enabled states
- Focused border: `primary` 1.5px
- Error border: `error` 1px / 1.5px focused
- Hint style: Cairo 14px, `textHint`
- Error style: Cairo 12px, `error`
- Padding: 16px horizontal, 14px vertical

### Checkbox
- Checked fill: `primary`
- Check color: white
- Unchecked border: `border` 1.5px
- Shape: rounded 4px

---

## Files

| File | Path |
|---|---|
| Theme definition | `lib/core/theme/app_theme.dart` |
| Color constants | `lib/core/constants/app_colors.dart` |
