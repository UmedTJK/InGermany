.
├── Core
│   ├── AppContainer.swift
│   ├── ContentView.swift
│   └── InGermanyApp.swift
├── Docs
│   ├── AI_CONTEXT.md
│   ├── AI_CONTEXT_20251006.md
│   ├── ARCHITECTURE_ISSUES.md
│   ├── ARCHITECTURE_ISSUES_old.md
│   ├── ARTICLE_EDITOR_ROADMAP.md
│   ├── CHANGELOG.md
│   ├── CLEAN_CODE_CHECKLIST.md
│   ├── Git_Mini_Guide.md
│   ├── PROMPTS_FOR_AI_AGENTS.md
│   ├── README.md
│   ├── UIUTILS_GUIDE.md
│   ├── di_refactoring_progress.md
│   ├── git_snapshot.md
│   ├── hooks
│   │   └── pre-push.template
│   ├── locations_README.md
│   ├── next_steps.md
│   ├── project_tree.md
│   └── screenshots
│       ├── FavoritesView.png
│       ├── SearchView.png
│       ├── aboutView.png
│       ├── articlesByCategoryView.png
│       ├── categoriesView.png
│       ├── detail.png
│       ├── home.png
│       ├── map.png
│       └── settings.png
├── Formatters
│   ├── ArticleFormatter.swift
│   ├── DateFormattingService.swift
│   └── ReadingTimeCalculator.swift
├── InGermany
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   ├── Contents.json
│   │   │   ├── Logo 1.png
│   │   │   └── Logo.png
│   │   ├── Contents.json
│   │   └── Logo.imageset
│   │       ├── Contents.json
│   │       └── Logo.png
│   ├── Contents.json
│   ├── LogoDark.png
│   ├── LogoLight.png
│   ├── Preview Content
│   │   └── Preview Assets.xcassets
│   │       ├── Contents.json
│   │       ├── LogoDark.imageset
│   │       │   ├── Contents.json
│   │       │   └── LogoDark.png
│   │       └── LogoLight.imageset
│   │           ├── Contents.json
│   │           └── LogoLight.png
│   └── Views
├── InGermany.xcodeproj
│   ├── project.pbxproj
│   ├── project.xcworkspace
│   │   ├── contents.xcworkspacedata
│   │   ├── xcshareddata
│   │   │   ├── WorkspaceSettings.xcsettings
│   │   │   └── swiftpm
│   │   │       └── configuration
│   │   └── xcuserdata
│   │       └── sumtjk.xcuserdatad
│   │           ├── UserInterfaceState.xcuserstate
│   │           └── WorkspaceSettings.xcsettings
│   └── xcuserdata
│       └── sumtjk.xcuserdatad
│           ├── xcdebugger
│           │   └── Breakpoints_v2.xcbkptlist
│           └── xcschemes
│               └── xcschememanagement.plist
├── InGermanyCMS
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── ContentView.swift
│   ├── InGermanyCMSApp.swift
│   ├── Item.swift
│   ├── Resources
│   │   └── burgeramt_registration.json
│   └── Views
│       ├── ArticleComponents
│       ├── ArticleEditorView.swift
│       ├── ArticleLibraryView.swift
│       ├── BlockPickerView.swift
│       └── DemoArticleView.swift
├── InGermanyCMSTests
│   └── InGermanyCMSTests.swift
├── InGermanyCMSUITests
│   ├── InGermanyCMSUITests.swift
│   └── InGermanyCMSUITestsLaunchTests.swift
├── InGermanyTests
│   ├── Editor
│   │   ├── ArticleEditorImportExportTests.swift
│   │   └── ArticleEditorViewModelTests.swift
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
│       │   └── ReadingTimeCalculatorTests.swift
│       ├── Managers
│       │   ├── FavoritesManagerTests.swift
│       │   ├── RatingManagerTests.swift
│       │   └── ReadingHistoryManagerTests.swift
│       ├── Models
│       │   └── ArticlesCategoriesConsistencyTests.swift
│       ├── Services
│       │   ├── ArticlesRepositoryImplTests.swift
│       │   ├── DataServiceTests.swift
│       │   ├── LocalizationKeysTests.swift
│       │   └── NetworkServiceTests.swift
│       └── ViewModels
│           ├── AboutViewModelTests.swift
│           ├── ArticleDetailViewModelTests.swift
│           ├── ArticleRowViewModelTests.swift
│           ├── CategoriesViewModelTests.swift
│           ├── FavoritesViewModelTests.swift
│           ├── HomeViewModelTests.swift
│           ├── SearchViewModelTests.swift
│           └── SettingsViewModelTests.swift
├── Managers
│   ├── FavoritesManager.swift
│   ├── RatingManager.swift
│   ├── ReadingHistoryManager.swift
│   ├── ReadingStatsManager.swift
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
│   │   │   └── ArticleKit
│   │   │       ├── ArticleKit.swift
│   │   │       ├── Components
│   │   │       ├── Models
│   │   │       ├── Renderer
│   │   │       └── ViewModels
│   │   └── Tests
│   │       └── ArticleKitTests
│   │           └── ArticleKitTests.swift
│   └── SharedKit
│       ├── Package.swift
│       ├── Sources
│       │   └── SharedKit
│       │       ├── Services
│       │       ├── SharedKit.swift
│       │       └── UI
│       └── Tests
│           └── SharedKitTests
│               └── SharedKitTests.swift
├── Protocols
│   ├── ArticleFormatterProtocol.swift
│   ├── ArticlesRepositoryProtocol.swift
│   ├── CategoriesRepositoryProtocol.swift
│   ├── FavoritesManagingProtocol.swift
│   ├── FontProviding.swift
│   ├── LocalizationManagerProtocol.swift
│   ├── RatingManagerProtocol.swift
│   ├── ReadingProgressTrackerProtocol.swift
│   ├── ReadingStatsManagingProtocol.swift
│   └── ShareServiceProtocol.swift
├── README.md
├── Repositories
│   ├── ArticlesRepositoryImpl.swift
│   └── CategoriesRepositoryImpl.swift
├── Resources
│   ├── Images
│   │   ├── Base.lproj
│   │   │   ├── bank_account.jpg
│   │   │   ├── germany1.jpg
│   │   │   └── germany3.jpg
│   │   ├── ar.lproj
│   │   │   ├── germany1.jpg
│   │   │   └── germany3.jpg
│   │   ├── de.lproj
│   │   │   ├── germany1.jpg
│   │   │   └── germany3.jpg
│   │   ├── en.lproj
│   │   │   ├── bank_account.jpg
│   │   │   ├── germany1.jpg
│   │   │   └── germany3.jpg
│   │   ├── fa.lproj
│   │   │   ├── germany1.jpg
│   │   │   └── germany3.jpg
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
│   │   │   ├── germany1.jpg
│   │   │   └── germany3.jpg
│   │   ├── tg-TJ.lproj
│   │   │   ├── germany1.jpg
│   │   │   └── germany3.jpg
│   │   └── uk.lproj
│   │       ├── germany1.jpg
│   │       └── germany3.jpg
│   ├── Localizable.xcstrings
│   ├── Test_Document.pdf
│   ├── articles
│   ├── articles.json
│   ├── burgeramt_registration.json
│   ├── burgeramt_registration_base64.json
│   ├── burgergeld.pdf
│   ├── categories.json
│   ├── guide.pdf
│   ├── insurance.pdf
│   ├── locations.json
│   ├── test1.pdf
│   ├── test2.pdf
│   └── test3.pdf
├── Services
│   ├── AuthService.swift
│   ├── CacheService.swift
│   ├── DataService.swift
│   ├── DefaultsStore.swift
│   ├── ExportToPDF.swift
│   ├── NetworkService.swift
│   ├── ShareService.swift
│   └── TextAnalysisService.swift
├── Sources
│   ├── ArticleKit
│   │   ├── ArticleKit.swift
│   │   ├── Components
│   │   ├── Models
│   │   │   ├── ArticleBlock.swift
│   │   │   └── ArticleSectionDTO.swift
│   │   ├── Renderer
│   │   └── ViewModels
│   └── ViewModels
│       ├── ArticleEditorViewModel.swift
│       └── ArticleLibraryViewModel.swift
├── UIUtils
│   ├── Accessibility+Extensions.swift
│   ├── Animations.swift
│   ├── CardImageStyle.swift
│   ├── CardSize.swift
│   ├── CardStyle.swift
│   ├── Color+Hex.swift
│   ├── CustomTabBarView.swift
│   ├── Environment+ScreenSize.swift
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
├── Views
│   ├── AboutView.swift
│   ├── ArticleDetailView.swift
│   ├── ArticlesByCategoryView.swift
│   ├── ArticlesByTagView.swift
│   ├── Cards
│   │   └── ArticleCompactCard.swift
│   ├── CategoriesView.swift
│   ├── Components
│   │   ├── ArticleCardView.swift
│   │   ├── ArticleMetaView.swift
│   │   ├── ArticleRow.swift
│   │   ├── Components.swift
│   │   ├── FavoriteCard.swift
│   │   ├── LanguagePickerView.swift
│   │   ├── PDFViewer.swift
│   │   ├── ReadingProgressBar.swift
│   │   ├── StarRatingView.swift
│   │   ├── TagFilterView.swift
│   │   ├── TagsView.swift
│   │   └── TextSizeSettingsPanel.swift
│   ├── FavoritesView.swift
│   ├── HomeView.swift
│   ├── MapView.swift
│   ├── PDFLibraryView.swift
│   ├── SearchView.swift
│   ├── Sections
│   │   ├── AllArticlesSection.swift
│   │   ├── CategorySection.swift
│   │   ├── FavoritesSection.swift
│   │   ├── RecentlyReadSection.swift
│   │   └── UsefulToolsSection.swift
│   └── SettingsView.swift
├── iterm
│   ├── Dracula.itermcolors
│   ├── INSTALL.md
│   ├── LICENSE
│   ├── README.md
│   ├── dracula-pro.png
│   └── screenshot.png
└── scripts
    ├── release.sh
    ├── release_v2.sh
    ├── release_v3.sh
    ├── release_v4.sh
    ├── release_v4.sh.save
    ├── release_v5.sh
    ├── release_v6.sh
    ├── release_v7.sh
    ├── tag_with_date.sh
    └── update_project_tree.sh

96 directories, 257 files
