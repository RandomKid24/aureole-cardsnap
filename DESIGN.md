<div align="center">
  
  # 🎨 Beforth Design System
  ### For CardSnap Application
  
</div>

---

This document outlines the design principles, color tokens, and structural rules used across the CardSnap application to maintain a premium and unified brand aesthetic.

## 🌈 Color Palette

We use a sophisticated palette prioritizing crisp contrast, professional blues, and neutral slates.

| Color Name | Hex Code | Usage |
| :--- | :--- | :--- |
| **Primary Blue** | `![#1A5BFF](https://placehold.co/15x15/1A5BFF/1A5BFF.png) #1A5BFF` | Main CTAs, active states, highlights, floating action buttons |
| **Navy** | `![#0D1117](https://placehold.co/15x15/0D1117/0D1117.png) #0D1117` | Primary text color, ghost button text, dark backgrounds |
| **Deep Navy** | `![#1C2333](https://placehold.co/15x15/1C2333/1C2333.png) #1C2333` | Secondary dark surfaces, dark mode cards |
| **Slate BG** | `![#EDF0F8](https://placehold.co/15x15/EDF0F8/EDF0F8.png) #EDF0F8` | Global application background (Light Mode) |
| **Stone** | `![#6B7280](https://placehold.co/15x15/6B7280/6B7280.png) #6B7280` | Body text, secondary labels, inactive states, icons |
| **Border / Divider** | `![#D1D8E8](https://placehold.co/15x15/D1D8E8/D1D8E8.png) #D1D8E8` | Input borders, list dividers, card outlines |
| **Blue Tint** | `![#EBF0FF](https://placehold.co/15x15/EBF0FF/EBF0FF.png) #EBF0FF` | Subtle highlights, selected states, icon backgrounds |

## 🔤 Typography

Two primary fonts from Google Fonts drive the visual hierarchy:

1. **Bebas Neue** (Headers & Display)
   - *Usage:* App Bars, Section Titles, Hero Text.
   - *Styling:* **ALWAYS UPPERCASE**, generously spaced (`letterSpacing: 1.2` to `2.0`).

2. **Inter** (Body & UI)
   - *Usage:* Descriptions, List Tiles, Buttons, Input Fields.
   - *Weights:* 
     - `w300` (Light) - Subtitles
     - `w400` (Regular) - Body text
     - `w500` (Medium) - Input text, secondary buttons
     - `w600` (SemiBold) - Primary buttons, important labels
     - `w700` (Bold) - Names, critical highlights

## 🧱 UI Components & Geometry

### The Dot Grid Pattern
All root screens feature a signature dotted background to give a subtle "blueprint" or "graph paper" texture.
- **Spacing:** `28.0px`
- **Dot Radius:** `1.5px`
- **Color:** `#C2CEE8`

### Buttons (`BeforthButton`)
Buttons are completely pill-shaped to contrast with the sharp grid backgrounds.
- **Border Radius:** `999px` (Pill)
- **Primary:** Solid `Primary Blue`, White Text.
- **Secondary:** Solid `Navy`, White Text.
- **Ghost Light:** Transparent, White Text, White transparent border (Used over camera feeds).

### Inputs & Cards
- **Cards:** White surface, `16px` border radius, `#D1D8E8` 1px border. Minimal shadow.
- **Inputs:** `12px` border radius, `#EDF0F8` filled background. Blue border on focus.

## 📏 Spacing & Paddings
- Standard horizontal screen padding: `24px`
- Form vertical spacing: `16px`
- Section gap spacing: `24px` to `32px`

---
<div align="center">
  <br/>
  Forged by <span className="font-bebas text-[1.2rem] uppercase leading-[1.05] text-transparent [-webkit-text-stroke:0.5px_rgba(255,255,255,0.3)] hover:[-webkit-text-stroke:0.5px_#e8c14a] transition-all cursor-pointer pt-0.5 tracking-[0.05em]">BEFORTH</span>
</div>
