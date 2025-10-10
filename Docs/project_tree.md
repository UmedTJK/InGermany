.
├── 0001-add-missing-categories.patch
├── 0001-add-missing-categories.patch.save
├── Core
│   ├── AppContainer.swift
│   ├── ContentView.swift
│   └── InGermanyApp.swift
├── Docs
│   ├── AI_CONTEXT.md
│   ├── AI_CONTEXT_20251006.md
│   ├── ARCHITECTURE_ISSUES.md
│   ├── ARCHITECTURE_ISSUES_old.md
│   ├── CHANGELOG.md
│   ├── CLEAN_CODE_CHECKLIST.md
│   ├── Git_Mini_Guide.md
│   ├── PROMPTS_FOR_AI_AGENTS.md
│   ├── di_refactoring_progress.md
│   ├── git_snapshot.md
│   ├── hooks
│   │   └── pre-push.template
│   ├── locations_README.md
│   ├── next_steps.md
│   └── project_tree.md
├── Formatters
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
│       ├── Modeld
│       ├── New Folder
│       ├── Services
│       └── ViewModels
├── Managers
│   ├── CacheManager.swift
│   ├── CategoryManager.swift
│   ├── FavoritesManager.swift
│   ├── ProtocolConformances.swift
│   ├── RatingManager.swift
│   ├── ReadingHistoryManager.swift
│   ├── ReadingProgressHelper.swift
│   ├── ReadingProgressTracker.swift
│   ├── ReadingStatsManager.swift
│   ├── ReadingTimeCalculator.swift
│   ├── ReadingTimeTracker.swift
│   └── TextSizeManager.swift
├── Models
│   ├── Article.swift
│   ├── Category.swift
│   ├── Location.swift
│   └── ReadingSession.swift
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
│   ├── articles.json
│   ├── burgergeld.pdf
│   ├── categories.json
│   ├── guide.pdf
│   ├── insurance.pdf
│   └── locations.json
├── Screenshots
│   ├── article.png
│   ├── categories.png
│   ├── favorites.png
│   ├── home.png
│   ├── search.png
│   └── settings.png
├── Services
│   ├── ArticleFormatter.swift
│   ├── ArticlesRepositoryImpl.swift
│   ├── AuthService.swift
│   ├── DataService.swift
│   ├── DateFormattingService.swift
│   ├── DefaultsStore.swift
│   ├── ExportToPDF.swift
│   ├── LocalizationManager.swift
│   ├── NetworkService.swift
│   ├── ShareService.swift
│   └── TextAnalysisService.swift
├── UIUtils
│   ├── Animations.swift
│   ├── CardImageStyle.swift
│   ├── CardSize.swift
│   ├── CardStyle.swift
│   ├── Color+Hex.swift
│   ├── Environment+ScreenSize.swift
│   ├── ProgressBar.swift
│   ├── ReadingTimeCalculator.swift
│   ├── RoundedCorner.swift
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
│   ├── SearchView.swift
│   ├── Sections
│   │   ├── AllArticlesSection.swift
│   │   ├── CategorySection.swift
│   │   ├── FavoritesSection.swift
│   │   ├── RecentlyReadSection.swift
│   │   └── UsefulToolsSection.swift
│   └── SettingsView.swift
├── appcontainer_patch.diff
├── check_di_violations.sh
├── di_violations_report.md
├── project_structure.txt
├── scripts
│   ├── release.sh
│   ├── release_v2.sh
│   ├── release_v3.sh
│   ├── release_v4.sh
│   ├── release_v4.sh.save
│   ├── release_v5.sh
│   ├── release_v6.sh
│   ├── release_v7.sh
│   ├── tag_with_date.sh
│   └── update_project_tree.sh
└── update.sh

52 directories, 163 files
