---
name: Crimson Matrix
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#20201f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353535'
  on-surface: '#e5e2e1'
  on-surface-variant: '#e8bcb6'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#ae8782'
  outline-variant: '#5e3f3b'
  surface-tint: '#ffb4aa'
  primary: '#ffb4aa'
  on-primary: '#690003'
  primary-container: '#e61919'
  on-primary-container: '#fffbff'
  inverse-primary: '#c0000b'
  secondary: '#c9c6c5'
  on-secondary: '#313030'
  secondary-container: '#4a4949'
  on-secondary-container: '#bab8b7'
  tertiary: '#c6c6c7'
  on-tertiary: '#2f3131'
  tertiary-container: '#737575'
  on-tertiary-container: '#fdfdfd'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdad5'
  primary-fixed-dim: '#ffb4aa'
  on-primary-fixed: '#410001'
  on-primary-fixed-variant: '#930006'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c9c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474646'
  tertiary-fixed: '#e2e2e2'
  tertiary-fixed-dim: '#c6c6c7'
  on-tertiary-fixed: '#1a1c1c'
  on-tertiary-fixed-variant: '#454747'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353535'
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
  container-margin: 24px
  gutter: 16px
  section-gap: 64px
---

## Brand & Style

This design system is built on a foundation of high-contrast minimalism and technical precision. It is designed for high-performance tech applications that need to feel authoritative, innovative, and slightly provocative. The aesthetic leverages the tension between deep obsidian voids and vibrant, energetic red accents to create a sense of focused power.

The brand personality is **Precise, Bold, and Sophisticated**. It targets a tech-savvy audience that values efficiency and modern engineering. The UI should evoke an emotional response of confidence and "cutting-edge" reliability, utilizing sharp contrasts and intentional whitespace to guide the user's attention.

## Colors

The palette is derived directly from the core branding: a vibrant, high-saturation red set against a spectrum of deep blacks and technical grays.

- **Primary (#E61919):** Used sparingly for critical actions, branding elements, and active states. It represents the "pulse" of the application.
- **Secondary (#0D0D0D):** The deep black used for primary backgrounds and surfaces to create depth.
- **Tertiary (#F2F2F2):** A crisp off-white used primarily for high-readability text and icons on dark backgrounds.
- **Surface Neutrals:** A range of deep grays (#1A1A1A, #262626) are used to differentiate containers and UI layers without breaking the monochromatic intensity.

The default experience is **Dark Mode**, which best communicates the technical and premium nature of the brand.

## Typography

The typographic system utilizes **Geist** for its developer-centric, technical precision in headlines and labels, paired with **Hanken Grotesk** for body text to ensure modern, clean readability.

- **Headlines:** Use tight letter spacing and heavier weights to create a sense of impact.
- **Body Text:** Optimized for long-form legibility with generous line heights.
- **Labels:** Small caps or uppercase transformations are encouraged for technical metadata and category tags to reinforce the "instrument panel" aesthetic.

## Layout & Spacing

The layout follows a **fluid grid** model based on an 8px base unit. 

- **Desktop:** 12-column grid with 24px margins and 16px gutters.
- **Mobile:** 4-column grid with 16px margins.
- **Philosophy:** Use "intentional emptiness." Large gaps between sections (64px+) should be used to separate distinct functional areas, mimicking the high-end editorial feel of the reference branding. Alignment should be strict and mathematical.

## Elevation & Depth

This design system avoids traditional soft shadows in favor of **Tonal Layering** and **Low-Contrast Outlines**.

- **Surfaces:** Depth is achieved by lightening the background hex by 3-5% for each successive layer (e.g., Background #0D0D0D -> Card #1A1A1A -> Popover #262626).
- **Outlines:** Subtle 1px borders using #FFFFFF at 10% opacity are used to define boundaries on dark surfaces.
- **Glow:** For high-priority elements, a very subtle red "inner-glow" or "drop-shadow" (#E61919 at 15% opacity, 20px blur) can be used to simulate an illuminated hardware interface.

## Shapes

The shape language is **Soft (Level 1)**. While the brand is technical, the slight 4px - 8px radius on components prevents the UI from feeling "sharp" or "hostile," mirroring the rounded terminals of the logo.

- **Standard Elements:** 4px (0.25rem) radius for inputs, buttons, and small cards.
- **Large Containers:** 12px (0.75rem) radius for primary application sections.
- **Interactive States:** Maintain consistent radii; do not fluctuate roundedness on hover.

## Components

- **Buttons:** Primary buttons use a solid #E61919 fill with #F2F2F2 text. Secondary buttons are outlined with a 1px border. No gradients.
- **Input Fields:** Dark backgrounds (#1A1A1A) with a bottom-only border for a "terminal" feel, or a full 1px subtle outline. The focus state uses the primary red for the border.
- **Cards:** Flat surfaces with tonal differentiation. High-importance cards may feature a 2px vertical "accent stripe" of primary red on the left edge.
- **Chips/Tags:** Use the Label-md typography style. Backgrounds should be low-opacity versions of the primary color (e.g., #E61919 at 10% opacity) with solid red text.
- **Status Indicators:** Use the primary red for "Alert" or "Active," and a neutral mid-gray for "Inactive." Avoid green unless absolutely necessary for safety, opting for white or gray for "Success" to maintain the brand's specific color story.