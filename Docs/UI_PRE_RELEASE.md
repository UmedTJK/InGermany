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

---

## Step B — Design System v1 (tokens + components)
### Tokens
- [ ] DS.Spacing (xs/s/m/l/xl/section/contentInset/carouselItem)
- [ ] DS.Radius (card/media/badge/chip)
- [ ] DS.Typography (sectionTitle/cardTitle/body/meta/chip)
- [ ] DS.Colors (background/surface/secondarySurface/text/separator/accent)
- [ ] DS.Elevation (shadow/stroke/material, light/dark aware)
- [ ] DS.Motion (durations, spring presets; reduce motion)

### Components
- [ ] CardContainer modifier (replaces cardStyle/lightCardStyle/applyCardStyle/sectionCardStyle)
- [ ] SectionHeader (title + optional action)
- [ ] CategoryBadge (contrast-safe)
- [ ] TagChip (hit target + dynamic type strategy)
- [ ] HorizontalCarousel wrapper (padding/spacing unified)

---

## Step C — Apply (priority order)
### C1 Home (first)
- [ ] Replace Home ScrollView VStack → LazyVStack
- [ ] Unified contentInset + section spacing via DS tokens
- [ ] Replace section headers with SectionHeader
- [ ] Normalize carousels using HorizontalCarousel
- [ ] Remove/DEBUG-gate datasource bar (3pt)

### C2 ArticleCompactCard
- [ ] Unify radius/padding via DS
- [ ] Image placeholder consistent + no layout jump
- [ ] Category badge: contrast-safe text color
- [ ] Accessibility: single VO element label/value/hint
- [ ] Dynamic Type: adjust line limits for accessibility sizes

### C3 Other tabs
- [ ] Categories/Search/Favorites/Settings: unified nav + background + list style
- [ ] Empty states & loading states unified

---

## Step D — Pre-Release Checklist
### Accessibility
- [ ] Dynamic Type: XXL + accessibility sizes
- [ ] VoiceOver: labels, traits, hints
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
- [ ] Single source of truth for card styling
- [ ] Stable navigation structure per tab
- [ ] Verified on: iPhone SE / iPhone 15 / iPad split view
