# UI Pre-Release Plan (HIG) — InGermany

Branch: `ui/pre-release-hig-v1`  
Scope: UI/UX + Visual + Content + Accessibility. Architecture (MVVM + DI/AppContainer) unchanged.

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
- [ ] DS.Motion (durations, spring presets; reduce motion)

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
- [ ] Categories/Search/Favorites/Settings: unified nav + background + list style
- [ ] Empty states & loading states unified

---

## Step D — Pre-Release Checklist
### Accessibility
- [x] Dynamic Type: XXL + accessibility sizes
- [x] VoiceOver: labels, traits, hints
- [ ] Hit targets: ≥ 44pt
- [ ] Contrast (light/dark)
- [ ] Reduce Motion support

### Visual Consistency
- [ ] Spacing grid consistent
- [ ] Card surfaces consistent
- [ ] Typography consistent
- [ ] Navigation titles/toolbars consistent across tabs

### Performance micro-checks
- [ ] Lazy stacks for long lists
- [ ] Avoid heavy work in `body`
- [ ] Image loading: avoid repeated decoding/lookups
- [ ] Smooth scrolling on Home

### Definition of Done (UI)
- [ ] No magic numbers in screens/sections (only DS tokens)
- [ ] Single source of truth for card styling (CardContainer only)
- [ ] Stable navigation structure per tab
- [ ] Accessibility pass completed (Dynamic Type + VoiceOver + hit targets)
- [ ] Verified on: iPhone SE / iPhone 15 / iPad split view
