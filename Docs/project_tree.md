.
├── Adapters
│   └── SharedCore
│       └── ArticlesProviderAdapter.swift
├── Core
│   ├── AppContainer.swift
│   ├── ContentView.swift
│   ├── InGermanyApp.swift
│   ├── Localizable.xcstrings
│   ├── LocalizationSettings.swift
│   ├── Observability
│   │   └── AppLogger.swift
│   └── View+AppEnvironment.swift
├── Docs
│   ├── AI_CONTEXT_20251006.md
│   ├── AI_CONTEXT.md
│   ├── ARCHITECTURE_ISSUES_old.md
│   ├── ARCHITECTURE_ISSUES.md
│   ├── ARCHITECTURE.md
│   ├── ARTICLE_EDITOR_ROADMAP.md
│   ├── AUDIT_2026-02-21_TECHNICAL_PLAN.md
│   ├── CHANGELOG.md
│   ├── CLEAN_CODE_CHECKLIST.md
│   ├── DI_GRAPH.md
│   ├── di_refactoring_progress.md
│   ├── Git_Mini_Guide.md
│   ├── git_snapshot.md
│   ├── hooks
│   │   └── pre-push.template
│   ├── locations_README.md
│   ├── next_steps.md
│   ├── project_tree.md
│   ├── project_tree.txt
│   ├── PROMPTS_FOR_AI_AGENTS.md
│   ├── README.md
│   ├── screenshots
│   │   ├── aboutView.png
│   │   ├── articlesByCategoryView.png
│   │   ├── categoriesView.png
│   │   ├── detail.png
│   │   ├── FavoritesView.png
│   │   ├── home.png
│   │   ├── map.png
│   │   ├── SearchView.png
│   │   └── settings.png
│   ├── UI_PRE_RELEASE.md
│   └── UIUTILS_GUIDE.md
├── Formatters
│   ├── ArticleFormatter.swift
│   ├── DateFormattingService.swift
│   └── ReadingTimeCalculator.swift
├── InGermany
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   ├── AppIcon.appiconset
│   │   ├── Contents.json
│   │   └── Logo.imageset
│   ├── Contents.json
│   ├── LogoDark.png
│   ├── LogoLight.png
│   └── Preview Content
│       └── Preview Assets.xcassets
├── InGermany.xcodeproj
│   ├── project.pbxproj
│   ├── project.xcworkspace
│   │   ├── contents.xcworkspacedata
│   │   ├── xcshareddata
│   │   └── xcuserdata
│   ├── remove-xcstrings.patch
│   ├── xcshareddata
│   │   └── xcschemes
│   └── xcuserdata
│       └── sumtjk.xcuserdatad
├── InGermanyTests
│   ├── Editor
│   │   ├── ArticleEditorImportExportTests.swift
│   │   └── ArticleEditorViewModelTests.swift
│   ├── InGermany.xctestplan
│   ├── InGermanyTests.swift
│   ├── Mocks
│   │   ├── MockArticlesRepository.swift
│   │   ├── MockCategoriesRepository.swift
│   │   └── MockDataService.swift
│   ├── Models
│   │   ├── ArticleTests.swift
│   │   ├── CategoryTests.swift
│   │   └── LocationTests.swift
│   ├── Resources
│   │   ├── sample_articles.json
│   │   └── sample_categories.json
│   ├── UI
│   │   └── AppUITests.swift
│   └── Unit
│       ├── Helpers
│       ├── Managers
│       ├── Models
│       ├── Services
│       └── ViewModels
├── iterm
│   ├── dracula-pro.png
│   ├── Dracula.itermcolors
│   ├── INSTALL.md
│   ├── LICENSE
│   ├── README.md
│   └── screenshot.png
├── Managers
│   ├── FavoritesManager.swift
│   ├── RatingManager.swift
│   ├── ReadingHistoryManager.swift
│   ├── ReadingStatsManager.swift
│   ├── SettingsManager.swift
│   └── TextSizeManager.swift
├── Models
│   ├── Article.swift
│   ├── Category.swift
│   ├── Location.swift
│   ├── ProtocolConformances.swift
│   ├── ReadingHistoryEntry.swift
│   ├── ReadingSession.swift
│   └── ReadingStats.swift
├── Packages
│   ├── ArticleKit
│   │   ├── Package.swift
│   │   ├── Sources
│   │   └── Tests
│   └── SharedKit
│       ├── Package.swift
│       ├── Sources
│       └── Tests
├── Protocols
│   ├── ArticleFormatterProtocol.swift
│   ├── ArticlesRepositoryProtocol.swift
│   ├── CacheServiceProtocol.swift
│   ├── CategoriesRepositoryProtocol.swift
│   ├── DataServiceProtocol.swift
│   ├── FavoritesManagingProtocol.swift
│   ├── FontProviding.swift
│   ├── LocalizationManagerProtocol.swift
│   ├── NetworkServiceProtocol.swift
│   ├── RatingManagerProtocol.swift
│   ├── ReadingProgressTrackerProtocol.swift
│   ├── ReadingStatsManagingProtocol.swift
│   ├── SettingsManagingProtocol.swift
│   └── ShareServiceProtocol.swift
├── README.md
├── Repositories
│   ├── ArticlesRepositoryImpl.swift
│   └── CategoriesRepositoryImpl.swift
├── Resources
│   ├── articles.json
│   ├── burgeramt_registration_base64.json
│   ├── burgeramt_registration.json
│   ├── burgergeld.pdf
│   ├── categories.json
│   ├── guide.pdf
│   ├── Images
│   │   ├── ar.lproj
│   │   ├── Base.lproj
│   │   ├── de.lproj
│   │   ├── en.lproj
│   │   ├── fa.lproj
│   │   ├── germany10.jpg
│   │   ├── germany11.jpg
│   │   ├── germany12.jpg
│   │   ├── germany13.jpg
│   │   ├── germany2.jpg
│   │   ├── germany4.jpg
│   │   ├── germany5.jpg
│   │   ├── germany6.jpg
│   │   ├── germany7.jpg
│   │   ├── germany8.jpg
│   │   ├── germany9.jpg
│   │   ├── ru.lproj
│   │   ├── tg-TJ.lproj
│   │   └── uk.lproj
│   ├── insurance.pdf
│   ├── locations.json
│   ├── Test_Document.pdf
│   ├── test1.pdf
│   ├── test2.pdf
│   └── test3.pdf
├── scripts
│   ├── release_v2.sh
│   ├── release_v3.sh
│   ├── release_v4.sh
│   ├── release_v4.sh.save
│   ├── release_v5.sh
│   ├── release_v6.sh
│   ├── release_v7.sh
│   ├── release.sh
│   ├── tag_with_date.sh
│   └── update_project_tree.sh
├── Services
│   ├── AuthService.swift
│   ├── CacheService.swift
│   ├── DataService.swift
│   ├── DefaultsStore.swift
│   ├── ExportToPDF.swift
│   ├── Network
│   │   ├── NetworkMetrics.swift
│   │   ├── NetworkMetricsCollector.swift
│   │   └── NetworkService.swift
│   ├── ShareService.swift
│   └── TextAnalysisService.swift
├── SharedCore
│   ├── Package.swift
│   └── Sources
│       └── SharedCore
├── Sources
│   ├── ArticleKit
│   │   ├── ArticleKit.swift
│   │   └── Models
│   └── ViewModels
├── UIUtils
│   ├── Accessibility+Extensions.swift
│   ├── Animations.swift
│   ├── CardImageStyle.swift
│   ├── CardSize.swift
│   ├── CardStyle.swift
│   ├── Color+Hex.swift
│   ├── CustomTabBarView.swift
│   ├── DesignSystem
│   │   ├── CardContainerStyle.swift
│   │   └── DS.swift
│   ├── Environment+ScreenSize.swift
│   ├── NSWindow+SwiftUI.swift
│   ├── PDFThumbnailGenerator.swift
│   ├── ProgressBar.swift
│   ├── ReadingProgressHelper.swift
│   ├── RoundedCorner.swift
│   ├── ScaleOnTap.swift
│   ├── ShakeEffect.swift
│   ├── ShimmerEffect.swift
│   └── Theme.swift
├── ViewModels
│   ├── AboutViewModel.swift
│   ├── ArticleCompactCardViewModel.swift
│   ├── ArticleDetailViewModel.swift
│   ├── ArticleRowViewModel.swift
│   ├── CategoriesViewModel.swift
│   ├── FavoritesViewModel.swift
│   ├── HomeViewModel.swift
│   ├── LocationsViewModel.swift
│   ├── PDFLibraryViewModel.swift
│   ├── PDFViewerViewModel.swift
│   ├── SearchViewModel.swift
│   ├── SettingsViewModel.swift
│   └── ViewModels.swift
└── Views
    ├── AboutView.swift
    ├── ArticleDetailView.swift
    ├── ArticlesByCategoryView.swift
    ├── ArticlesByTagView.swift
    ├── Cards
    │   └── ArticleCompactCard.swift
    ├── CategoriesView.swift
    ├── Components
    │   ├── ArticleCardView.swift
    │   ├── ArticleMetaView.swift
    │   ├── ArticleRow.swift
    │   ├── CategoryBadge.swift
    │   ├── Components.swift
    │   ├── FavoriteCard.swift
    │   ├── HorizontalCarousel.swift
    │   ├── LanguagePickerView.swift
    │   ├── PDFViewer.swift
    │   ├── ReadingProgressBar.swift
    │   ├── SectionHeader.swift
    │   ├── StarRatingView.swift
    │   ├── TagChip.swift
    │   ├── TagFilterView.swift
    │   ├── TagsView.swift
    │   └── TextSizeSettingsPanel.swift
    ├── FavoritesView.swift
    ├── HomeDashboardLayout.swift
    ├── HomeView.swift
    ├── MapView.swift
    ├── PDFLibraryView.swift
    ├── SearchView.swift
    ├── Sections
    │   ├── AllArticlesSection.swift
    │   ├── CategorySection.swift
    │   ├── FavoritesSection.swift
    │   ├── RecentlyReadSection.swift
    │   └── UsefulToolsSection.swift
    └── SettingsView.swift

75 directories, 211 files
