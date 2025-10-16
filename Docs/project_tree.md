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
│   └── DateFormattingService.swift
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
│   └── xcuserdata
│       └── sumtjk.xcuserdatad
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
│       ├── Managers
│       ├── Models
│       ├── Services
│       └── ViewModels
├── Managers
│   ├── CacheManager.swift
│   ├── CategoryManager.swift
│   ├── FavoritesManager.swift
│   ├── RatingManager.swift
│   ├── ReadingHistoryManager.swift
│   ├── ReadingProgressHelper.swift
│   ├── ReadingStatsManager.swift
│   ├── ReadingTimeCalculator.swift
│   └── TextSizeManager.swift
├── Models
│   ├── Article.swift
│   ├── Category.swift
│   ├── Location.swift
│   ├── ProtocolConformances.swift
│   ├── ReadingHistoryEntry.swift
│   ├── ReadingSession.swift
│   └── ReadingStats.swift
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
│   └── ArticlesRepositoryImpl.swift
├── Resources
│   ├── Images
│   │   ├── Base.lproj
│   │   ├── ar.lproj
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
│   ├── ArticleRenderer.swift
│   ├── AuthService.swift
│   ├── DataService.swift
│   ├── DefaultsStore.swift
│   ├── ExportToPDF.swift
│   ├── LocalizationManager.swift
│   ├── NetworkService.swift
│   ├── ShareService.swift
│   └── TextAnalysisService.swift
├── Shared
│   ├── Models
│   │   ├── ArticleBlock.swift
│   │   └── ArticleSectionDTO.swift
│   └── ViewModels
│       ├── ArticleEditorViewModel.swift
│       └── ArticleLibraryViewModel.swift
├── UIUtils
│   ├── Accessibility+Extensions.swift
│   ├── Animations.swift
│   ├── ArticleComponents
│   │   ├── ArticleBlockView.swift
│   │   ├── ChecklistCardView.swift
│   │   └── FAQBlockView.swift
│   ├── CardImageStyle.swift
│   ├── CardSize.swift
│   ├── CardStyle.swift
│   ├── Color+Hex.swift
│   ├── CustomTabBarView.swift
│   ├── Environment+ScreenSize.swift
│   ├── LoadingView.swift
│   ├── PDFThumbnailGenerator.swift
│   ├── ProgressBar.swift
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
│   ├── DemoArticleView.swift
│   ├── Editor
│   │   ├── ArticleEditorView.swift
│   │   ├── ArticleLibraryView.swift
│   │   └── BlockPickerView.swift
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

60 directories, 195 files
