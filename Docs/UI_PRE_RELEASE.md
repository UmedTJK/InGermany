# UI Pre-Release Plan (HIG) — InGermany

Branch: `ui/pre-release-hig-v1`  
Scope: UI/UX + Visual + Content + Accessibility. Architecture (MVVM + DI/AppContainer) unchanged.

## Recent updates (this branch)
- Premium card surface: DS.Elevation (stroke + dual shadow + material) and lighter material tuning (.thinMaterial)
- Press feedback groundwork: DS.Interaction tokens + CardPressStyle (apply via `.cardPressFeedback()`)
- Home: improved rhythm (insets + hidden scroll indicators), UsefulTools promoted as hero (header/subtitle + material)
- Home: DS-driven thin separator after hero
- ArticleKit: stable 16:9 image container (no layout jumps) + premium placeholder + subtle fade-in (Reduce Motion aware)

## Rules of Work
- ✅ Atomic changes: one improvement (or one file) → commit immediately
- ✅ No architectural refactor; only UI layer + reusable components/tokens
- ✅ Prefer reuse: tokens + components, avoid magic numbers
- ✅ Accessibility is a feature: Dynamic Type, VoiceOver, hit targets ≥ 44pt, contrast

---

## Step A — UI Inventory (done / in progress)
- [x] Root: ContentView (TabView, theme, navigation strategy)
- [x] HomeView (sections, loading, refresh)
- [x] ArticleCompactCard (image/badge/tags/meta)
- [x] Sections: CategorySection, AllArticlesSection, FavoritesSection, RecentlyReadSection
- [x] UIUtils: Theme, CardStyle, CardSize, Animations

### Key Findings (A)
- Multiple sources of truth for card styling: `Theme.sectionCardStyle`, `applyCardStyle`, `cardStyle/lightCardStyle`
- Magic numbers across views (spacing/radius/padding)
- NavigationStack inconsistent placement (Home contains its own stack)
- Localization inconsistent (hardcoded strings + multiple translation APIs)
- Animations incorrect: `.animation(..., value: UUID())` causes unstable re-animations
- Card sizing based on screen size (risk in iPad/split view)
- Design System layer introduced (DS + CardContainer + SectionHeader); legacy cardStyle functions deprecated but still present

---

## Step B — Design System v1 (tokens + components)
### Tokens
- [x] DS.Spacing (xs/s/m/l/xl/section/contentInset/carouselItem)
- [x] DS.Radius (card/media/badge/chip)
- [x] DS.Typography (sectionTitle/cardTitle/cardBody/meta/chip/badge)
- [x] DS.Color (background/surface/secondarySurface/textPrimary/textSecondary)
- [ ] DS.Elevation (shadow/stroke/material, light/dark aware)
- [ ] DS.Motion (durations + presets; ensure Reduce Motion coverage)

### Components
- [x] CardContainer modifier (replaces cardStyle/lightCardStyle/applyCardStyle/sectionCardStyle)
- [x] SectionHeader (title + optional action)
- [x] CategoryBadge (contrast-safe, extracted component)
- [x] TagChip (hit target + dynamic type strategy)
- [x] HorizontalCarousel wrapper (padding/spacing unified)

---

## Step C — Apply (priority order)
### C1 Home (completed baseline)
- [x] Home ScrollView VStack → LazyVStack
- [x] Unified contentInset + section spacing via DS tokens
- [x] Replace section headers with SectionHeader
- [x] Apply .buttonStyle(.plain) to all card NavigationLinks
- [x] Normalize carousels using HorizontalCarousel wrapper
- [x] Remove/DEBUG-gate datasource bar (3pt)

### C2 ArticleCompactCard (DS aligned)
- [x] Unify radius/padding via DS
- [x] Replace magic numbers with DS tokens
- [x] Image placeholder consistent + no layout jump
- [x] Category badge: contrast-safe text color logic
- [x] Accessibility: single VO element label/value/hint
- [x] Dynamic Type: adjust line limits for accessibility sizes

### C3 Other tabs
- [x] Categories/Search/Favorites/Settings: unified nav + background + list style
- [x] Empty states & loading states unified

---

## Step D — Pre-Release Checklist
### Accessibility
- [x] Dynamic Type: XXL + accessibility sizes
- [x] VoiceOver: labels, traits, hints
- [x] Hit targets: ≥ 44pt
- [x] Contrast (light/dark)
- [x] Reduce Motion support

### Visual Consistency
- [ ] Spacing grid consistent
- [ ] Card surfaces consistent
- [ ] Press feedback applied on all interactive cards (Buttons/NavigationLinks)
- [ ] Typography consistent
- [ ] Navigation titles/toolbars consistent across tabs

### Performance micro-checks
- [ ] Lazy stacks for long lists
- [ ] Avoid heavy work in `body`
- [ ] Image loading: avoid repeated decoding/lookups
  - Audit: UIImage(named:) usage inside card bodies; prefer cached/resolved images
- [ ] Smooth scrolling on Home
  - Audit: carousels + ArticleCompactCard body cost; confirm LazyVStack + LazyHStack usage

### Definition of Done (UI)
- [ ] No magic numbers in screens/sections (only DS tokens)
- [ ] Single source of truth for card styling (CardContainer only)
- [ ] Stable navigation structure per tab
- [ ] Accessibility pass completed (Dynamic Type + VoiceOver + hit targets)
- [ ] Verified on: iPhone SE / iPhone 15 / iPad split view


---

## Step D — Execution Plan (next)

### D1 Remove legacy UI debt
- [ ] Delete/deprecate legacy card style APIs: `Theme.sectionCardStyle`, `applyCardStyle`, `cardStyle/lightCardStyle` (keep only `cardContainer`)
- [ ] Remove remaining magic numbers (search via `padding(`, `cornerRadius(`, `spacing:`) where DS tokens exist

### D2 Accessibility audit
- [x] Hit targets: verified ≥ 44pt for Home tool cards, article cards, badges/chips, Settings buttons
- [ ] Contrast: verify DS colors + badge contrast in both light/dark (WCAG-ish sanity)
- [x] Reduce Motion: animations respect accessibilityReduceMotion (scale/press/slide)

### D3 Visual consistency audit
- [ ] Navigation titles/toolbars consistent across tabs (inline/large where appropriate)
- [ ] Card surfaces consistent (materials/shadows/strokes) across light/dark
- [ ] Typography consistency pass (titles/body/meta) across list rows + cards

### D4 Performance audit
- [ ] Home: ensure lazy containers everywhere + minimal work in `body`
- [ ] Image rendering: avoid repeated decoding and re-layout; verify placeholder sizes
- [ ] Scrolling sanity on iPhone SE + iPad split view

### D5 Final QA
- [ ] Run through core flows: open article, favorite/unfavorite, search, open category list, open settings
- [ ] Quick VO pass on Home + ArticleDetail + Search results
- [ ] Final screenshot pass (Docs/screenshots) for release notes / store listing
