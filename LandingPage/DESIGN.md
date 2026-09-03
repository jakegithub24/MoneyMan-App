---
version: 2.0.0
name: MoneyMan-Landing-Page-Design-System
description: UI/UX reference specification for the MoneyMan open-source Android app landing page. Consolidates brand tokens, component patterns, content architecture, and copy direction into a single build-ready reference.
status: Reference — not implementation. Use this to brief design/dev work, not as a component library itself.

colors:
  # Canvas & Surfaces
  canvas: "#131313"
  canvas-soft: "#171717"
  surface-card: "#1F271C"
  surface-card-elevated: "#273323"
  surface-card-subtle: "#182016"
  surface-dark: "#0D0D0D"

  # Brand Accents
  primary: "#E7C14D"       # Solar Gold
  primary-hover: "#D4AE3A"
  secondary: "#E67E22"     # Tangerine Orange
  secondary-hover: "#CF6D17"

  # Financial Telemetry (semantic, never decorative)
  income: "#6C9C3A"
  income-soft: "#6C9C3A20"
  expense: "#D62B2B"
  expense-soft: "#D62B2B20"

  # Typography & Text
  ink: "#EEE9D9"
  body: "#CCC7B8"
  body-subtle: "#9E9A8E"
  on-primary: "#131313"

  # Hairlines & Borders
  hairline: "#2A3526"
  hairline-strong: "#3E4F39"
  hairline-gold: "#E7C14D40"

  # Ambient Backdrops
  halo-gold: "radial-gradient(circle at 50% 30%, rgba(231,193,77,0.12) 0%, rgba(230,126,34,0.05) 50%, transparent 70%)"

typography:
  display-xl: { font: "'Plus Jakarta Sans'", size: 56px, weight: 700, lh: 1.1, ls: -1.6px }
  display-lg: { font: "'Plus Jakarta Sans'", size: 36px, weight: 700, lh: 1.2, ls: -1.0px }
  display-md: { font: "'Plus Jakarta Sans'", size: 24px, weight: 600, lh: 1.3, ls: -0.5px }
  title-md:   { font: "'Plus Jakarta Sans'", size: 18px, weight: 600, lh: 1.4 }
  body-md:    { font: "'Inter'", size: 16px, weight: 400, lh: 1.6 }
  body-sm:    { font: "'Inter'", size: 14px, weight: 400, lh: 1.5 }
  amount-lg:  { font: "'Plus Jakarta Sans', 'JetBrains Mono'", size: 28px, weight: 700, ls: -0.5px }
  code:       { font: "'JetBrains Mono'", size: 13px, lh: 1.5 }
  caption-badge: { font: "'Plus Jakarta Sans'", size: 11px, weight: 700, ls: 1.0px, transform: uppercase }

rounded:
  sm: 6px
  md: 10px
  lg: 14px
  xl: 18px
  chassis: 36px
  pill: 9999px

spacing:
  xs: 8px
  sm: 12px
  base: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
  section: 88px
---

# MoneyMan — Landing Page Design Reference

MoneyMan is an **offline-first, privacy-hardened personal finance tracker for Android**. Every design decision on the landing page should trace back to that identity: no cloud, no telemetry, no compromises — a financial vault you carry in your pocket, not a SaaS dashboard pretending to be one.

This document is the single source of truth for anyone building the landing page: it defines *what the brand is*, *how it looks*, *what goes on the page and in what order*, and *what to say*. It supersedes ad-hoc component guesses — if a choice isn't here, it should be added here before it's built.

---

## 1. Brand Positioning & Design Thesis

**The subject:** a vault, not a spreadsheet. MoneyMan's entire value proposition — offline, encrypted, DRM-shielded, zero telemetry — is about *containment and control*. The landing page's visual language should feel closer to a secure enclosure (a safe, a ledger, a locked case) than to a typical fintech SaaS dashboard of floating glass cards and gradients.

**Audience:** privacy-conscious Android users, self-hosters, open-source enthusiasts, and developers evaluating the codebase — not enterprise finance teams. Copy and visuals should read as *engineered and trustworthy*, not *corporate and polished*.

**The page's single job:** convince a visitor in under 10 seconds that their financial data will never leave their device, then get them to download the APK or star the repo.

**Signature element:** the **Hero Device Mockup** — an Android phone rendered mid-interaction, wrapped in a soft gold halo, is the one moment of visual richness on the page. Every other section stays disciplined and quiet so this signature has room to land. Do not compete with it elsewhere on the page (e.g., no second glowing halo in Section 5).

---

## 2. Design Tokens & Palette

| Token | Hex / Value | Purpose |
|---|---|---|
| `canvas` | `#131313` | Root dark page background |
| `canvas-soft` | `#171717` | Alternate section background for rhythm/contrast |
| `surface-card` | `#1F271C` | Primary component & card background |
| `surface-card-elevated` | `#273323` | Hovered cards & floating surfaces |
| `surface-dark` | `#0D0D0D` | Terminal/code blocks, deepest depth |
| `primary` | `#E7C14D` | Solar Gold — primary CTAs, active states, key figures, focus rings |
| `secondary` | `#E67E22` | Tangerine Orange — secondary accents, GitHub badge, hover accents |
| `income` | `#6C9C3A` | Income indicators, positive balance, green chart line — **never used decoratively** |
| `expense` | `#D62B2B` | Expense indicators, alerts, red chart line — **never used decoratively** |
| `ink` | `#EEE9D9` | Headings, button labels, high-contrast text |
| `body` | `#CCC7B8` | Readable body copy and descriptions |
| `body-subtle` | `#9E9A8E` | Captions, metadata, timestamps |
| `hairline` | `#2A3526` | 1px card borders and subtle dividers |
| `hairline-strong` | `#3E4F39` | Chassis outlines and elevated borders |
| `hairline-gold` | `#E7C14D40` | Focus/active borders on gold-accented elements |

**Rule of semantic color:** `income` green and `expense` red are reserved exclusively for financial polarity (money in vs. money out). Never repurpose them as generic "success/error" UI colors elsewhere on the page — that dilutes the one place they carry real meaning.

### Fonts
- **Headings & Actions:** `Plus Jakarta Sans` (600, 700) — geometric, confident, slightly technical. Used with restraint: display sizes only, never body copy.
- **Body & Captions:** `Inter` (400, 500) — neutral, highly legible at small sizes.
- **Numbers & Code:** `JetBrains Mono` (400, 700) — every currency figure, repo command, and version tag renders in mono. This is deliberate: it signals precision and reads as "financial ledger," reinforcing the vault metaphor.

---

## 3. Component Specifications

### 3.1 Top Navigation
- **Height:** 72px · Sticky · `backdrop-filter: blur(14px)` · Background `rgba(19,19,19,0.85)` · Bottom border `1px solid #2A3526`.
- **Left:** Logo mark in a 36px rounded box (`border: 1.5px solid #E7C14D`) + "MoneyMan" wordmark, `title-md`.
- **Center:** Nav links — *Features · Analytics · Security · Tech Stack*. Default `#CCC7B8`, hover `#E7C14D`, 150ms ease transition.
- **Right:**
  - GitHub pill — outlined, star-count icon, updates live via GitHub API if feasible.
  - "Download APK" — primary gold button, `#131313` text, radius 12px, height 40px.
- **Mobile (<640px):** Center links collapse into a drawer triggered by a hamburger icon; both CTAs remain visible or fold into the drawer footer.

### 3.2 Buttons & Controls
| Variant | Background | Text | Border | Radius | Padding | Shadow |
|---|---|---|---|---|---|---|
| `btn-primary` | `#E7C14D` | `#131313` (600) | — | 14px | `12px 24px` | `0 4px 16px rgba(231,193,77,0.2)` |
| `btn-secondary` | `#1F271C` | `#EEE9D9` | `1px solid #3E4F39` | 14px | `12px 24px` | none |
| `btn-ghost` | transparent | `#CCC7B8` | none | 14px | `12px 24px` | none, underline on hover |
| `badge-pill` | `rgba(231,193,77,0.12)` | `#E7C14D` | `1px solid rgba(231,193,77,0.25)` | 9999px | `6px 14px` | none |

All interactive elements need a visible focus ring (`2px solid #E7C14D`, 2px offset) for keyboard users — this is non-negotiable given the security-conscious audience.

### 3.3 Cards & Containers
- **Feature Card:** `#1F271C` bg, `1px solid #2A3526` border, radius 18px, padding 24px. Hover → border `#3E4F39`, shadow `0 8px 24px rgba(0,0,0,0.4)`, lift `translateY(-2px)`.
- **Security Card:** `#1F271C` bg, `1.5px solid rgba(108,156,58,0.4)` border (a quiet nod to the "vault" green), radius 18px, padding 28px.
- **Code / Terminal Box:** `#0D0D0D` bg, `1px solid #2A3526` border, `JetBrains Mono`, radius 12px, padding 16px. Include a copy-to-clipboard affordance on every command block.

### 3.4 Hero Android Device Mockup
- **Chassis:** outer radius 36px, `3px solid #3E4F39` border, shadow `0 20px 60px rgba(0,0,0,0.6), 0 0 60px rgba(231,193,77,0.1)`.
- **On-screen UI (reflects actual app, not a generic dashboard):**
  1. Top app bar — "Hello, User! 👋"
  2. Filter chips — *Today · Week · Month (active, gold) · Year · All*
  3. Metric 4-grid — Income `↓ $4,850.00` (`#6C9C3A`) · Expense `↑ $1,620.00` (`#D62B2B`) · Balance `✦ $3,230.00` (`#E7C14D`) · Records `28 entries` (`#EEE9D9`)
  4. Monthly budget bar — `$1,620 / $3,000`, 54% filled in gold
  5. Chart preview — donut + legend (*Food 38% · Rent 28% · Utilities 14% · Shopping 12%*)
  6. Center FAB — circular gold `+`
- **Motion:** a single slow ambient float (translateY ±6px, 6s ease-in-out loop) on the chassis is enough. Do not animate every element inside the screen — one orchestrated moment beats five competing micro-interactions. Respect `prefers-reduced-motion`.

### 3.5 Security Interaction Mockup (Section 5)
- Compact phone-frame or card-frame widget showing: PIN keypad with masked dots, a biometric fingerprint prompt, and a DRM toggle in the "on" state (small `#6C9C3A` indicator dot + "Screen Protection Active" label).
- This mockup should feel *quieter* than the hero — smaller scale, no halo — so the hero remains the page's one visual centerpiece.

---

## 4. Landing Page Structure & Content Blueprint

Content below is grounded in the actual README feature set — do not invent capabilities the app doesn't have.

### Section 1 — Header
Logo + wordmark · nav (*Features, Analytics, Security, Architecture*) · "Download APK" + GitHub link.

### Section 2 — Hero
- **Badge:** `🛡️ 100% OFFLINE · ZERO TRACKING · HARDWARE DRM PROTECTION`
- **Headline:** "Master Your Money. **Own Your Privacy.**" (second clause in `#E7C14D`)
- **Subheadline:** Modern, offline-first income and expense tracker for Android — deep cashflow charts, monthly budget ceilings, a biometric vault, and hardware-backed screen protection.
- **CTAs:** `Download Release APK v1.0.0` (primary) · `Star on GitHub` (secondary outlined)
- **Visual:** centered device mockup (§3.4) with `halo-gold` radial backdrop behind it.

### Section 3 — Value Strip
Five-pillar horizontal trust ribbon, icon + label, no elaboration needed here (detail lives in Section 4):
1. 100% Offline — zero network calls, local Hive storage
2. Zero Telemetry — no trackers, no ads, no analytics
3. DRM Screen Shield — `FLAG_SECURE` blocks recording/screenshots
4. Biometric Vault — fingerprint + 4-digit PIN
5. Full CSV Portability — instant export & import

### Section 4 — Core Feature Grid (6 cards, 3-col desktop / 2-col tablet / 1-col mobile)
1. **Dual-Mode Interactive Charts** — pie distribution and multi-series income/expense trend lines, down to 10-year intervals.
2. **Fort Knox Privacy** — native `FLAG_SECURE` screen-capture blocking, PIN lock, biometrics, auto-lock timers.
3. **Monthly Target Budgeting** — live progress bar with 80% threshold warnings.
4. **Custom Categories** — 15+ presets, custom icons and colors, 2-tap entry.
5. **Smart Currency Engine** — INR Lakhs/Crores and Western Millions notation, custom symbols.
6. **Complete Data Ownership** — on-device Hive database, full CSV backup/restore.

### Section 5 — Security & DRM Deep Dive (2-column)
- **Left:** interactive security mockup (§3.5).
- **Right:** three short proof points — *No cloud dependency* (data never leaves device) · *Native WindowManager protection* (blocks capture in background/recents) · *Guarded database reset* (explicit PIN-gated confirmation).

### Section 6 — Tech Stack & Architecture
Badge row: `Flutter 3.x` · `Dart 3.x` · `BLoC/Cubit` · `Hive NoSQL` · `fl_chart` · `local_auth`.
One line on Clean Architecture (Domain / Application / Data / Presentation) with zero framework lock-in in core logic — this is the credibility section for developer visitors; keep it factual, not salesy.

### Section 7 — Download CTA Band
- **Headline:** "Take Control of Your Financial Privacy."
- **Compatibility line:** Android 5.0 (API 21+) · `arm64-v8a`, `armeabi-v7a`, `x86_64`
- **Actions:** `Download MoneyMan-release-v1.0.0.apk` button · quick-copy clone command in a `code` block (§3.3).

### Section 8 — Footer
Logo + tagline + MIT license badge · links (Releases, Repository, Architecture Docs, Feature Requests) · credit line: "Developed with ❤️ by JakeGithub24 using Flutter & Dart."

---

## 5. Voice & Copy Direction

- **Say what it does, not what it sells.** "Your data never leaves your device" beats "Enterprise-grade security you can trust."
- **Active voice, present tense.** Buttons say what happens: "Download APK," never "Get Started" (too generic for a direct binary download).
- **No manufactured urgency.** This is an open-source tool, not a growth-hacked SaaS — skip countdown timers, fake scarcity, or "join 10,000 users" style social proof unless the numbers are real and verifiable (e.g., actual GitHub star count).
- **Numbers are real or omitted.** Every currency figure or stat shown must come from the actual app or repo — the hero mockup's `$4,850.00` is illustrative sample data, label it as such in code comments for future maintainers, not as marketing copy on the page itself.
- **Technical credibility for the dev audience.** Section 6 can use precise terms (`FLAG_SECURE`, `Clean Architecture`, `Hive NoSQL`) without dumbing down — this audience wants proof of engineering rigor.

---

## 6. Motion Guidelines

- One orchestrated hero moment (ambient float, §3.4) — not scattered effects.
- Feature cards: subtle lift + border-brighten on hover only, 150–200ms ease.
- Scroll-triggered fade/slide-up on section entry is acceptable if restrained (8–12px translate, 400ms), but skip it entirely before adding a second animated element to any single viewport.
- Always respect `prefers-reduced-motion: reduce` — disable ambient float and scroll reveals, keep only opacity fades.

---

## 7. Responsive Rules

| Breakpoint | Layout |
|---|---|
| **Mobile** (`< 640px`) | Single column · Hero H1 scales to 34px · CTAs full-width stacked · mockup width 300px · nav collapses to drawer |
| **Tablet** (`640–1024px`) | 2-column feature grid · metric cards 2×2 · Hero H1 44px · mockup width 350px |
| **Desktop** (`> 1024px`) | 3-column feature grid · 4-column metric layout · full horizontal nav · max container 1200px |

---

## 8. Accessibility Floor

- Color contrast: `body` (`#CCC7B8`) on `canvas` (`#131313`) and `ink` (`#EEE9D9`) on `surface-card` both meet WCAG AA for body text — verify any new token pairing before shipping.
- Visible keyboard focus on every interactive element (see §3.2).
- All icons paired with text labels or `aria-label`s — icon-only buttons (e.g., GitHub star) need accessible names.
- `prefers-reduced-motion` respected everywhere motion is used (§6).
- Never convey income/expense polarity by color alone — pair with `↓`/`↑` glyphs or explicit labels, as the existing mockup spec already does.

---

## 9. Do's & Don'ts

**Do:**
- Use `#131313` canvas with `#1F271C` card surfaces for the authentic dark-vault look.
- Reserve `#E7C14D` gold for primary actions and active/key states only.
- Use `#6C9C3A` strictly for income and `#D62B2B` strictly for expenses — no exceptions.
- Render every currency figure and code snippet in `JetBrains Mono`.
- Keep the hero device mockup as the page's single visual centerpiece.

**Don't:**
- Convert the theme to light mode or introduce arbitrary primary button colors.
- Use iOS or desktop device frames — MoneyMan is Android-only.
- Add a second glowing/halo effect anywhere outside the hero.
- Invent features, stats, or testimonials not present in the README.
- Use `income`/`expense` green/red as generic success/error colors elsewhere in the UI.

---

## 10. Open Questions for the Next Design Pass

- Is there a real, current GitHub star count to surface live in the nav pill, or should it stay a static link?
- Confirm final logo asset (`Logo/MoneyMan-Logo.jpg`) resolution is sufficient for the 36px nav mark and any larger footer/OG-image use.
- Decide whether Section 5's security mockup is a static SVG illustration or a lightly interactive widget (toggle actually flips state) — the latter better supports the "vault" thesis but costs more build time.