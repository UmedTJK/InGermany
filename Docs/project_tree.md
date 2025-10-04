.
├── Core
│   ├── AppContainer.swift
│   ├── ContentView.swift
│   └── InGermanyApp.swift
├── Docs
│   ├── AI_CONTEXT.md
│   ├── CHANGELOG.md
│   ├── CLEAN_CODE_CHECKLIST.md
│   ├── Git_Mini_Guide.md
│   ├── PROMPTS_FOR_AI_AGENTS.md
│   ├── git_snapshot.md
│   ├── locations_README.md
│   ├── next_steps.md
│   └── project_tree.md
├── Formatters
├── HomeView_Context.zip
├── InGermany
│   ├── Contents.json
│   ├── LogoDark.png
│   ├── LogoLight.png
│   └── Preview Content
├── InGermanyTests
│   ├── InGermanyTests.swift
│   ├── Mocks
│   │   ├── MockArticlesRepository.swift
│   │   ├── MockCategoriesRepository.swift
│   │   └── MockDataService.swift
│   ├── Resources
│   │   ├── sample_articles.json
│   │   └── sample_categories.json
│   ├── UI
│   │   └── AppUITests.swift
│   └── Unit
│       ├── Managers
│       │   ├── CategoryManagerTests.swift
│       │   └── FavoritesManagerTests.swift
│       ├── Services
│       │   └── DataServiceTests.swift
│       └── ViewModels
│           ├── CategoriesViewModelTests.swift
│           ├── FavoritesViewModelTests.swift
│           └── HomeViewModelTests.swift
├── Managers
│   ├── CategoryManager.swift
│   ├── FavoritesManager.swift
│   ├── RatingManager.swift
│   ├── ReadingHistoryManager.swift
│   ├── ReadingProgressHelper.swift
│   ├── ReadingProgressTracker.swift
│   ├── ReadingTimeCalculator.swift
│   ├── ReadingTimeTracker.swift
│   └── TextSizeManager.swift
├── Models
│   ├── Article.swift
│   ├── Category.swift
│   └── Location.swift
├── Protocols
│   ├── ArticlesRepository.swift
│   └── CategoriesRepository.swift
├── README.md
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
│   ├── ArticlesRepositoryImpl.swift
│   ├── AuthService.swift
│   ├── DataService.swift
│   ├── DefaultsStore.swift
│   ├── ExportToPDF.swift
│   ├── LocalizationManager.swift
│   ├── NetworkService.swift
│   └── ShareService.swift
├── UIUtils
│   ├── Animations.swift
│   ├── CardImageStyle.swift
│   ├── CardSize.swift
│   ├── Color+Hex.swift
│   ├── ProgressBar.swift
│   └── Theme.swift
├── ViewModels
│   ├── AboutViewModel.swift
│   ├── ArticleDetailViewModel.swift
│   ├── ArticleRowViewModel.swift
│   ├── CategoriesViewModel.swift
│   ├── FavoritesViewModel.swift
│   ├── HomeViewModel.swift
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
├── project_structure.txt
└── update.sh

35 directories, 139 files
