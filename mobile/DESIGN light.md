---
name: Crimson Matrix Light
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f4'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#5e3f3b'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f0f1f1'
  outline: '#936e69'
  outline-variant: '#e8bcb6'
  surface-tint: '#c0000b'
  primary: '#bc000a'
  on-primary: '#ffffff'
  primary-container: '#e61919'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb4aa'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e5e2e1'
  on-secondary-container: '#656464'
  tertiary: '#5b5c5d'
  on-tertiary: '#ffffff'
  tertiary-container: '#737575'
  on-tertiary-container: '#fdfdfd'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad5'
  primary-fixed-dim: '#ffb4aa'
  on-primary-fixed: '#410001'
  on-primary-fixed-variant: '#930006'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474646'
  tertiary-fixed: '#e2e2e2'
  tertiary-fixed-dim: '#c6c6c7'
  on-tertiary-fixed: '#1a1c1c'
  on-tertiary-fixed-variant: '#454747'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
  surface-snow: '#FFFFFF'
  surface-mist: '#F9F9F9'
  deep-onyx: '#131313'
  electric-crimson: '#E61919'
  border-subtle: '#E5E5E5'
typography:
  display-lg:
    fontFamily: Geist
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Geist
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  margin-container: 24px
  gutter: 16px
  section-gap: 64px
---

## Brand & Style
The design system transitions from its original dark, obsidian-based aesthetic into a high-precision, technical light mode. The brand personality remains **Precise, Bold, and Sophisticated**, but shifts from an "underground terminal" feel to a "clinical, high-performance dashboard" aesthetic. 

The design style is a blend of **Minimalism** and **Modern Corporate**, utilizing expansive white space to emphasize technical clarity. By using Snow White as the primary canvas, the Electric Crimson accents become more surgical and urgent. The target audience remains tech-savvy professionals who value efficiency, but the light mode provides better accessibility and reduced cognitive load for long-form data analysis and daytime productivity. The emotional response should be one of "total clarity" and "high-fidelity engineering."

## Colors
The palette is inverted to prioritize legibility and a clean, laboratory-like environment.

- **Primary (#E61919):** Electric Crimson is the singular brand anchor. In this light context, it is used for primary actions, focus states, and critical data points. It provides a sharp, energetic contrast against the white background.
- **Secondary (#131313):** Deep Onyx is reserved strictly for high-contrast typography and iconography to ensure maximum readability.
- **Neutral/Surface (#FFFFFF):** Snow White serves as the base layer, creating a "breathable" interface that minimizes visual noise.
- **Tonal Accents (#F5F5F5 / #F9F9F9):** Light grays are used to define container boundaries and subtle depth without the weight of heavy shadows.

The default experience is **Light Mode**, optimized for high-brightness environments and professional productivity.

## Typography
The system pairs **Geist** for technical precision and **Hanken Grotesk** for approachable, modern legibility.

- **Headlines:** Set in Deep Onyx (#131313) to anchor the page. The tight letter spacing in Geist creates an authoritative, "engineered" look for displays and section headers.
- **Body Text:** Hanken Grotesk provides a humanist touch to the technical system, ensuring that long-form content is easy on the eyes against the white surface.
- **Labels:** Use the "instrument panel" aesthetic with Geist. All labels should be crisp, utilizing the 0.05em letter spacing for a metadata-heavy, professional appearance.

## Layout & Spacing
The layout follows a **fluid grid** model governed by an 8px base unit. 

- **Grid:** Use a 12-column grid for desktop and 4-column for mobile.
- **Margins:** Maintain 24px container margins on desktop and 16px on mobile to ensure content doesn't feel cramped against the screen edges.
- **Philosophy:** In this light system, space is a functional element. Use the "section-gap" (64px) to clearly demarcate different modules without needing heavy horizontal rules. The alignment must be mathematically precise, reinforcing the "Matrix" aspect of the design narrative.

## Elevation & Depth
In the light version of this design system, depth is conveyed through **Tonal Layers** and **Low-Contrast Outlines** rather than traditional drop shadows.

- **Surface Tiers:** Use Snow White (#FFFFFF) for the primary background. Secondary containers (cards, sidebars) should use Surface Mist (#F9F9F9).
- **Outlines:** Define all interactive containers with a subtle 1px border (#E5E5E5). This replaces the "glow" of the dark mode with a crisp, physical boundary.
- **Interactivity:** On hover or active states, the primary red (#E61919) can be used as a 1px or 2px border to pull the element forward visually, signifying focus without using depth-based elevation.

## Shapes
The shape language is **Soft (Level 1)**, utilizing a 4px (0.25rem) standard radius. This subtle rounding softens the clinical nature of the white-and-red palette, making the software feel modern and accessible rather than strictly "brutalist."

- **Standard Radius (4px):** Applied to buttons, input fields, and small UI components.
- **Large Radius (12px):** Applied to modal containers and primary card layouts to differentiate them from smaller utility elements.

## Components
- **Buttons:** Primary buttons feature a solid Electric Crimson (#E61919) fill with Snow White (#FFFFFF) text. Secondary buttons are Ghost-style: Deep Onyx text with a 1px border (#E5E5E5).
- **Input Fields:** Use a Snow White background with a 1px Border Subtle (#E5E5E5). Upon focus, the border transitions to a 2px Electric Crimson stroke. Placeholder text is a soft gray (#A0A0A0).
- **Cards:** Use Surface Mist (#F9F9F9) for the background to separate them from the Snow White page. High-priority cards include a 3px vertical "accent stripe" of Electric Crimson on the left edge.
- **Chips/Tags:** Backgrounds use Electric Crimson at 8% opacity with solid Electric Crimson text. This ensures the brand color is present without being overwhelming.
- **Checkboxes & Radios:** When selected, these are filled with Electric Crimson with a white checkmark/dot. The unselected state is a 1px Onyx outline.
- **Data Lists:** Use thin horizontal rules (#F0F0F0) between items. Hover states for list items should use a subtle shift to Surface Mist (#F9F9F9).