//
//  LocalizationManager.swift
//  InGermany
//

import SwiftUI

/// Менеджер локализации приложения.
/// Отвечает за хранение выбранного языка и получение переведённых строк из словаря.
public final class LocalizationManager: ObservableObject {

    @AppStorage("selectedLanguage") private var storedLanguage: String = "en"

    @Published public var selectedLanguage: String

    /// Initializes LocalizationManager with reactive language support.
    public init(defaultLanguage: String = Locale.current.language.languageCode?.identifier ?? "en") {
        let initial = UserDefaults.standard.string(forKey: "selectedLanguage") ?? defaultLanguage
        self._selectedLanguage = Published(initialValue: initial)
    }
    
    // MARK: - Словари
    
    private let tabTranslations: [String: [String: String]] = [
        "tab_home": [
            "ru": "Главная", "en": "Home", "de": "Startseite",
            "tj": "Саҳифаи асосӣ", "fa": "خانه", "ar": "الرئيسية", "uk": "Головна"
        ],
        "tab_categories": [
            "ru": "Категории", "en": "Categories", "de": "Kategorien",
            "tj": "Категорияҳо", "fa": "دسته‌ها", "ar": "الفئات", "uk": "Категорії"
        ],
        "tab_search": [
            "ru": "Поиск", "en": "Search", "de": "Suche",
            "tj": "Ҷустуҷӯ", "fa": "جستجو", "ar": "بحث", "uk": "Пошук"
        ],
        "tab_favorites": [
            "ru": "Избранное", "en": "Favorites", "de": "Favoriten",
            "tj": "Интихобшуда", "fa": "علاقه‌мندی‌ها", "ar": "المفضلة", "uk": "Вибране"
        ],
        "tab_settings": [
            "ru": "Настройки", "en": "Settings", "de": "Einstellungen",
            "tj": "Танзимот", "fa": "تنظیمات", "ar": "الإعدادات", "uk": "Налаштування"
        ],
        
        "settings_appearance_title": [
            "ru": "Внешний вид", "en": "Appearance", "de": "Erscheinungsbild",
            "tj": "Намуд", "fa": "ظاهر", "ar": "المظهر", "uk": "Зовнішній вигляд"
        ],
        
        "settings_date_format_title": [
            "ru": "Формат даты", "en": "Date format", "de": "Datumsformat",
            "tj": "Формати сана", "fa": "قالب تاریخ", "ar": "تنسيق التاريخ", "uk": "Формат дати"
        ],
        "settings_articles_read": [
            "ru": "Прочитано статей", "en": "Articles read", "de": "Gelesene Artikel",
            "tj": "Мақолаҳои хондашуда", "fa": "مقالات خوانده شده", "ar": "المقالات المقروءة", "uk": "Прочитано статей"
        ],
        "settings_total_time": [
            "ru": "Общее время", "en": "Total time", "de": "Gesamtzeit",
            "tj": "Вақти умумӣ", "fa": "زمان کل", "ar": "إجمالي الوقت", "uk": "Загальний час"
        ],
        "settings_average_time": [
            "ru": "Среднее время", "en": "Average time", "de": "Durchschnittszeit",
            "tj": "Вақти миёна", "fa": "میانگین زمان", "ar": "متوسط الوقت", "uk": "Середній час"
        ],
        "settings_streak": [
            "ru": "Серия дней", "en": "Reading streak", "de": "Leseserie",
            "tj": "Рӯзҳои пайваста", "fa": "روند مطالعه", "ar": "سلسلة القراءة", "uk": "Серія днів"
        ],
        "settings_stats_title": [
            "ru": "Статистика", "en": "Statistics", "de": "Statistik",
            "tj": "Статистика", "fa": "آمار", "ar": "إحصائيات", "uk": "Статистика"
        ],
        
        "settings_card_style_title": [
            "ru": "Стиль карточек", "en": "Card Style", "de": "Kartenstil",
            "tj": "Услуби корт", "fa": "سبک کارت", "ar": "نمط البطاقات", "uk": "Стиль карток"
        ],
        "settings_card_style_picker": [
            "ru": "Выбор стиля карточек", "en": "Select card style", "de": "Kartendesign auswählen",
            "tj": "Интихоби услуби корт", "fa": "انتخاب سبک کارت", "ar": "اختيار نمط البطاقات", "uk": "Вибір стилю карток"
        ],
        "settings_language_picker": [
            "ru": "Выбор языка", "en": "Select language", "de": "Sprache auswählen",
            "tj": "Интихоби забон", "fa": "انتخاب زبان", "ar": "اختيار اللغة", "uk": "Вибір мови"
        ],
        
        "map_title": [
            "ru": "Карта", "en": "Map", "de": "Karte",
            "tj": "Харита", "fa": "نقشه", "ar": "الخريطة", "uk": "Карта"
        ],
        "map_loading": [
            "ru": "Загрузка карты...", "en": "Loading map...", "de": "Karte wird geladen...",
            "tj": "Боркунии харита...", "fa": "در حال بارگذاری نقشه...", "ar": "جارٍ تحميل الخريطة...", "uk": "Завантаження карти..."
        ],
        
        "app_name": [
            "ru": "InGermany", "en": "InGermany", "de": "InGermany",
            "tj": "InGermany", "fa": "InGermany", "ar": "InGermany", "uk": "InGermany"
        ],
        "about_build_label": [
            "ru": "Сборка", "en": "Build", "de": "Build",
            "tj": "Сохтмон", "fa": "نسخه", "ar": "إصدار", "uk": "Збірка"
        ],



        
        "Загрузка данных...": [
            "ru": "Загрузка данных...", "en": "Loading data...", "de": "Daten werden geladen...",
            "tj": "Маълумот бор мешавад...", "fa": "در حال بارگذاری داده‌ها...", "ar": "جارٍ تحميل البيانات...", "uk": "Завантаження даних..."
        ],
        "Главная": [
            "ru": "Главная", "en": "Home", "de": "Startseite",
            "tj": "Саҳифаи асосӣ", "fa": "خانه", "ar": "الرئيسية", "uk": "Головна"
        ],
        
        "Избранное": [
            "ru": "Избранное", "en": "Favorites", "de": "Favoriten",
            "tj": "Интихобшуда", "fa": "علاقه‌мندی‌ها", "ar": "المفضلة", "uk": "Вибране"
        ],
        "Нет избранных статей": [
            "ru": "Нет избранных статей", "en": "No favorite articles", "de": "Keine Favoriten",
            "tj": "Мақолаҳои интихобшуда нест", "fa": "هیچ مقاله مورد علاقه‌ای وجود ندارد", "ar": "لا توجد مقالات مفضلة", "uk": "Немає вибраних статей"
        ],
        "Поиск в избранном": [
            "ru": "Поиск в избранном", "en": "Search favorites", "de": "Favoriten durchsuchen",
            "tj": "Ҷустуҷӯ дар интихобшудаҳо", "fa": "جستجو در علاقه‌مندی‌ها", "ar": "بحث في المفضلة", "uk": "Пошук у вибраному"
        ],
        "Загрузка избранного...": [
            "ru": "Загрузка избранного...", "en": "Loading favorites...", "de": "Favoriten werden geladen...",
            "tj": "Боркунии интихобшудаҳо...", "fa": "در حال بارگذاری علاقه‌مندی‌ها...", "ar": "جارٍ تحميل المفضلة...", "uk": "Завантаження вибраного..."
        ],
        
        "Поиск": [
            "ru": "Поиск", "en": "Search", "de": "Suche",
            "tj": "Ҷустуҷӯ", "fa": "جستجو", "ar": "بحث", "uk": "Пошук"
        ],
        "Искать по статьям или категориям": [
            "ru": "Искать по статьям или категориям", "en": "Search articles or categories", "de": "Artikel oder Kategorien suchen",
            "tj": "Ҷустуҷӯ дар мақолаҳо ё категорияҳо", "fa": "جستجو در مقالات یا دسته‌ها", "ar": "البحث в المقالات أو الفئات", "uk": "Шукати за статтями чи категоріями"
        ],
        
        "article_rate": [
            "ru": "Оцените статью", "en": "Rate this article", "de": "Artikel bewerten",
            "tj": "Мақоларо баҳогузорӣ кунед", "fa": "این مقاله را ارزیابی کنید", "ar": "قيّم المقال", "uk": "Оцініть статтю"
        ],
        "article_recommendations": [
            "ru": "Рекомендуемые статьи", "en": "Recommended articles", "de": "Empfohlene Artikel",
            "tj": "Мақолаҳои тавсияшуда", "fa": "مقالات پیشنهادی", "ar": "مقالات موصى بها", "uk": "Рекомендовані статті"
        ],
        "article_reading_progress": [
            "ru": "Прогресс чтения", "en": "Reading progress", "de": "Lesefortschritt",
            "tj": "Пешрафти хондан", "fa": "پیشرفت مطالعه", "ar": "تقدم القراءة", "uk": "Прогрес читання"
        ],
        
        "about_description": [
            "ru": "Приложение для адаптации и информации о жизни в Германии.",
            "en": "An app to support integration and provide information about life in Germany.",
            "de": "Eine App zur Unterstützung der Integration und Information über das Leben in Deutschland.",
            "tj": "Барномаи кӯмак ба мутобиқшавӣ ва маълумот дар бораи зиндагӣ дар Олмон.",
            "fa": "برنامه‌ای برای کمک به سازگاری و اطلاعات زندگی در آلمان.",
            "ar": "تطبيق لدعم الاندماج وتقديم معلومات عن الحياة في ألمانيا.",
            "uk": "Додаток для підтримки інтеграції та інформації про життя в Німеччині."
        
        ],
        
        "reading_status": [
            "ru": "Прогресс чтения",
            "en": "Reading progress",
            "de": "Lesefortschritt",
            "tj": "Раванди хондан",
            "fa": "پیشرفت مطالعه",
            "ar": "تقدم القراءة",
            "uk": "Прогрес читання"
        ],

        
        "tab_map": [
            "ru": "Карта", "en": "Map", "de": "Karte",
            "tj": "Харита", "fa": "نقشه", "ar": "الخريطة", "uk": "Карта"
        ],
        "map_my_location": [
            "ru": "Моё местоположение", "en": "My location", "de": "Mein Standort",
            "tj": "Ҷойгиршавии ман", "fa": "موقعیت من", "ar": "موقعي", "uk": "Моє розташування"
        ],
        "map_refresh": [
            "ru": "Обновить", "en": "Refresh", "de": "Aktualisieren",
            "tj": "Нав кардан", "fa": "تازه‌سازی", "ar": "تحديث", "uk": "Оновити"
        ]
    ]

    // ✅ ДОБАВЛЕН: Отдельный словарь для ArticleDetailView
    private let articleDetailTranslations: [String: [String: String]] = [
        "reading_time": [
            "ru": "Время чтения", "en": "Reading time", "de": "Lesezeit",
            "tj": "Вақти хондан", "fa": "زمان مطالعه", "ar": "وقت القراءة", "uk": "Час читання"
        ],
        "published": [
            "ru": "Опубликовано", "en": "Published", "de": "Veröffentlicht",
            "tj": "Нашр шудааст", "fa": "منتشر شده", "ar": "تم النشر", "uk": "Опубліковано"
        ],
        "min": [
            "ru": "мин", "en": "min", "de": "Min",
            "tj": "дақ", "fa": "دقیقه", "ar": "دقيقة", "uk": "хв"
        ],
        "hide": [
            "ru": "Скрыть", "en": "Hide", "de": "Ausblenden",
            "tj": "Пинҳон кардан", "fa": "پنهان کردن", "ar": "إخفاء", "uk": "Приховати"
        ],
        "show": [
            "ru": "Показать", "en": "Show", "de": "Anzeigen",
            "tj": "Намоиш додан", "fa": "نمایش دادن", "ar": "عرض", "uk": "Показати"
        ],
        "you_may_like": [
            "ru": "Вам может понравиться", "en": "You may like", "de": "Das könnte Ihnen gefallen",
            "tj": "Шумо дӯст медоред", "fa": "ممکن است دوست داشته باشید", "ar": "قد يعجبك", "uk": "Вам може сподобатися"
        ]
    ]
    
    private let textSettingsTranslations: [String: [String: String]] = [
        "settings_text_title": [
            "ru": "Настройки текста", "en": "Text settings", "de": "Texteinstellungen",
            "tj": "Танзимоти матн", "fa": "تنظیمات متن", "ar": "إعدادات النص", "uk": "Налаштування тексту"
        ],
        
        "settings_text_preview": [
            "ru": "Пример текста", "en": "Sample text", "de": "Beispieltext",
            "tj": "Матни намунавӣ", "fa": "متن نمونه", "ar": "نص تجريبي", "uk": "Приклад тексту"
        ],
        "common_reset": [
            "ru": "Сбросить", "en": "Reset", "de": "Zurücksetzen",
            "tj": "Сбош кардан", "fa": "بازنشانی", "ar": "إعادة ضبط", "uk": "Скинути"
        ],
        "common_done": [
            "ru": "Готово", "en": "Done", "de": "Fertig",
            "tj": "Тайёр", "fa": "انجام شد", "ar": "تم", "uk": "Готово"
        ]
    ]

    
    private let settingsTranslations: [String: [String: String]] = [
        "settings_title": [
            "ru": "Настройки", "en": "Settings", "de": "Einstellungen",
            "tj": "Танзимот", "fa": "تنظیمات", "ar": "الإعدادات", "uk": "Налаштування"
        ],
        "settings_language_section": [
            "ru": "Язык интерфейса", "en": "Language", "de": "Sprache",
            "tj": "Забон", "fa": "زبان", "ar": "اللغة", "uk": "Мова"
        ],
        "settings_dark_mode": [
            "ru": "Тёмная тема", "en": "Dark Mode", "de": "Dunkelmodus",
            "tj": "Ҳолати торик", "fa": "حالت تاریک", "ar": "الوضع الداكن", "uk": "Темний режим"
        ],


        "settings_relative_dates": [
            "ru": "Относительные даты", "en": "Relative dates", "de": "Relative Daten",
            "tj": "Санаҳои нисбӣ", "fa": "تاریخ نسبی", "ar": "تواريخ نسبية", "uk": "Відносні дати"
        ],
        "settings_clear_history": [
            "ru": "Очистить историю", "en": "Clear history", "de": "Verlauf löschen",
            "tj": "Пок кардани таърих", "fa": "پاک کردن تاریخچه", "ar": "مسح السجل", "uk": "Очистити історію"
        ],
        "settings_reset_defaults": [
            "ru": "Сбросить настройки", "en": "Reset settings", "de": "Einstellungen zurücksetzen",
            "tj": "Барқарорсозии танзимот", "fa": "بازنشانی تنظیمات", "ar": "إعادة تعيين الإعدادات", "uk": "Скинути налаштування"
        ],
        "settings_about_title": [
            "ru": "О приложении", "en": "About", "de": "Über",
            "tj": "Дар бораи", "fa": "درباره", "ar": "حول", "uk": "Про застосунок"
        ],
        // новые строки в словарь translations
        "tab_about": [
            "ru": "О приложении",
            "en": "About",
            "de": "Über",
            "tj": "Дар бораи барнома",
            "fa": "درباره برنامه",
            "ar": "حول التطبيق",
            "uk": "Про застосунок"
        ],
        // В translations добавить:
        "demo_article_title": [
            "ru": "Демо статья",
            "en": "Demo Article",
            "de": "Demo Artikel",
            "tj": "Мақолаи намунавӣ",
            "fa": "مقاله دمو",
            "ar": "مقالة تجريبية",
            "uk": "Демо стаття"
        ],
        
        "settings_history_cleared": [
            "ru": "История очищена",
            "en": "History cleared",
            "de": "Verlauf gelöscht",
            "tj": "Таърих пок шуд",
            "fa": "سابقه پاک شد",
            "ar": "تم مسح السجل",
            "uk": "Історію очищено"
      
        ],
        "about_version": [
            "ru": "Версия",
            "en": "Version",
            "de": "Version",
            "tj": "Силсила",
            "fa": "نسخه",
            "ar": "الإصدار",
            "uk": "Версія"
        ],
        "about_build": [
            "ru": "Сборка",
            "en": "Build",
            "de": "Build",
            "tj": "Сохтмон",
            "fa": "بیلد",
            "ar": "البناء",
            "uk": "Збірка"
        ],

        

        
        // 🔹 SettingsView — accessibility
        "settings_dark_mode_accessibility": [
            "ru": "Переключить тёмную тему",
            "en": "Toggle dark mode",
            "de": "Dunkelmodus umschalten",
            "tj": "Ҳолати торикро иваз кунед",
            "fa": "حالت تاریک را تغییر دهید",
            "ar": "تبديل الوضع الداكن",
            "uk": "Увімкнути/вимкнути темну тему"
        ],
        "settings_card_style_accessibility": [
            "ru": "Выбор стиля карточек",
            "en": "Select card style",
            "de": "Kartendesign auswählen",
            "tj": "Интихоби услуби корт",
            "fa": "انتخاب سبک کارت",
            "ar": "اختيار نمط البطاقات",
            "uk": "Вибір стилю карток"
        ],
        "settings_relative_dates_accessibility": [
            "ru": "Использовать относительные даты",
            "en": "Use relative dates",
            "de": "Relative Daten verwenden",
            "tj": "Истифодаи санаҳои нисбӣ",
            "fa": "استفاده از تاریخ‌های نسبی",
            "ar": "استخدام التواريخ النسبية",
            "uk": "Використовувати відносні дати"
        ],
        "settings_clear_history_accessibility": [
            "ru": "Очистить историю чтения",
            "en": "Clear reading history",
            "de": "Leseverlauf löschen",
            "tj": "Таърихи хонданро пок кунед",
            "fa": "پاک کردن تاریخچه مطالعه",
            "ar": "مسح سجل القراءة",
            "uk": "Очистити історію читання"
        ],
        "settings_reset_defaults_accessibility": [
            "ru": "Сбросить настройки приложения",
            "en": "Reset app settings",
            "de": "App-Einstellungen zurücksetzen",
            "tj": "Танзимоти барнома барқарор карда шавад",
            "fa": "بازنشانی تنظیمات برنامه",
            "ar": "إعادة تعيين إعدادات التطبيق",
            "uk": "Скинути налаштування застосунку"
        ],

        // 🔹 SettingsViewModel
        "settings_language_title": [
            "ru": "Язык",
            "en": "Language",
            "de": "Sprache",
            "tj": "Забон",
            "fa": "زبان",
            "ar": "اللغة",
            "uk": "Мова"
        ],

        // 🔹 Common
        "settings_done": [
            "ru": "Готово", "en": "Done", "de": "Fertig",
            "tj": "Тайёр", "fa": "انجام شد", "ar": "تم", "uk": "Готово"
        ],

    ]
    
    private let categoryTranslations: [String: [String: String]] = [
        "Финансы": [
            "ru": "Финансы", "en": "Finance", "de": "Finanzen",
            "tj": "Молия", "fa": "امور مالی", "ar": "المالية", "uk": "Фінанси"
        ],
        "Работа": [
            "ru": "Работа", "en": "Work", "de": "Arbeit",
            "tj": "Кор", "fa": "کار", "ar": "عمل", "uk": "Робота"
        ],
        "Учёба": [
            "ru": "Учёба", "en": "Study", "de": "Studium",
            "tj": "Хондан", "fa": "تحصیل", "ar": "دراسة", "uk": "Навчання"
        ],
        
        "category_none": [
            "ru": "Без категории",
            "en": "No category",
            "de": "Ohne Kategorie",
            "tj": "Бе категория",
            "fa": "بدون دسته‌بندی",
            "ar": "بدون فئة",
            "uk": "Без категорії"
        ],
        

    ]
    
    private let sectionTranslations: [String: [String: String]] = [
        "Недавно прочитанное": [
            "ru": "Недавно прочитанное", "en": "Recently read", "de": "Kürzlich gelesen",
            "tj": "Мақолаҳои охир хондашуда", "fa": "اخیراً خوانده شده", "ar": "تمت قراءته مؤخراً", "uk": "Нещодавно прочитане"
        ],
        "Все статьи": [
            "ru": "Все статьи", "en": "All articles", "de": "Alle Artikel",
            "tj": "Ҳамаи мақолаҳо", "fa": "همه مقالات", "ar": "جميع المقالات", "uk": "Усі статті"
        ],
        "Полезные инструменты": [
            "ru": "Полезные инструменты", "en": "Useful tools", "de": "Nützliche Werkzeuge",
            "tj": "Асбобҳои муфид", "fa": "ابزارهای مفید", "ar": "أدوات مفيدة", "uk": "Корисні інструменти"
        ],
        
        "section_all_articles": [
            "ru": "Все статьи", "en": "All Articles", "de": "Alle Artikel",
            "tj": "Ҳамаи мақолаҳо", "fa": "تمام مقالات", "ar": "جميع المقالات", "uk": "Усі статті"
        ],
        "section_favorites": [
            "ru": "Избранное", "en": "Favorites", "de": "Favoriten",
            "tj": "Дӯстдоштаҳо", "fa": "علاقه‌مندی‌ها", "ar": "المفضلة", "uk": "Обране"
        ],
        "section_recently_read": [
            "ru": "Недавно прочитанное", "en": "Recently Read", "de": "Kürzlich gelesen",
            "tj": "Хондашудаи охирин", "fa": "اخیراً خوانده‌شده", "ar": "قُرئ مؤخرًا", "uk": "Нещодавно прочитане"
        ],
        "section_useful_tools": [
            "ru": "Полезные инструменты", "en": "Useful Tools", "de": "Nützliche Werkzeuge",
            "tj": "Асбобҳои муфид", "fa": "ابزارهای مفید", "ar": "أدوات مفيدة", "uk": "Корисні інструменти"
        ],
        "tool_map": [
            "ru": "Карта", "en": "Map", "de": "Karte",
            "tj": "Харита", "fa": "نقشه", "ar": "خريطة", "uk": "Карта"
        ],
        "tool_pdf_docs": [
            "ru": "PDF Документы", "en": "PDF Documents", "de": "PDF-Dokumente",
            "tj": "Ҳуҷҷатҳои PDF", "fa": "اسناد PDF", "ar": "مستندات PDF", "uk": "PDF документи",
            
            
        ],
        
        // Внутри sectionTranslations или отдельного словаря
        "pdf_title_test1": [
            "ru": "Руководство по регистрации",
            "en": "Registration guide",
            "de": "Anmelde-Leitfaden",
            "tj": "Дастури бақайдгирӣ",
            "fa": "راهنمای ثبت‌نام",
            "ar": "دليل التسجيل",
            "uk": "Посібник з реєстрації"
        ],
        "pdf_desc_test1": [
            "ru": "Пошаговое руководство по Anmeldung в Германии",
            "en": "Step-by-step guide for Anmeldung in Germany",
            "de": "Schritt-für-Schritt-Anleitung für die Anmeldung in Deutschland",
            "tj": "Дастури қадам ба қадам барои Anmeldung дар Олмон",
            "fa": "راهنمای گام به گام برای Anmeldung در آلمان",
            "ar": "دليل خطوة بخطوة لـ Anmeldung في ألمانيا",
            "uk": "Покроковий посібник з Anmeldung у Німеччині"
        ],
        "pdf_title_test2": [
            "ru": "Список документов для Bürgeramt",
            "en": "Bürgeramt documents list",
            "de": "Dokumentenliste fürs Bürgeramt",
            "tj": "Рӯйхати ҳуҷҷатҳо барои Bürgeramt",
            "fa": "لیست مدارک برای Bürgeramt",
            "ar": "قائمة المستندات لمكتب Bürgeramt",
            "uk": "Список документів для Bürgeramt"
        ],
        "pdf_desc_test2": [
            "ru": "Актуальный перечень бумаг и справок для визитов",
            "en": "Up-to-date list of papers and certificates for visits",
            "de": "Aktuelle Liste von Unterlagen und Bescheinigungen für Termine",
            "tj": "Рӯйхати навшудаи ҳуҷҷатҳо ва шаҳодатномаҳо барои вохӯриҳо",
            "fa": "فهرست به‌روز مدارک و گواهی‌ها برای ملاقات‌ها",
            "ar": "قائمة محدثة بالأوراق والشهادات للزيارات",
            "uk": "Актуальний перелік документів і довідок для візитів"
        ],
        "pdf_title_test3": [
            "ru": "Памятка новоприбывшего",
            "en": "Newcomer checklist",
            "de": "Checkliste für Neuankömmlinge",
            "tj": "Рӯйхати корҳои навомадагон",
            "fa": "چک‌لیست تازه‌واردان",
            "ar": "قائمة المراجعة للوافدين الجدد",
            "uk": "Пам’ятка новоприбулого"
        ],
        "pdf_desc_test3": [
            "ru": "Краткое руководство по первым шагам в Германии",
            "en": "Quick guide to first steps in Germany",
            "de": "Kurzanleitung für die ersten Schritte in Deutschland",
            "tj": "Дастури кӯтоҳ барои қадамҳои аввал дар Олмон",
            "fa": "راهنمای سریع برای اولین قدم‌ها در آلمان",
            "ar": "دليل سريع للخطوات الأولى في ألمانيا",
            "uk": "Короткий посібник для перших кроків у Німеччині"
        ],

        
        "tool_random_article": [
            "ru": "Случайная статья", "en": "Random Article", "de": "Zufälliger Artikel",
            "tj": "Мақолаи тасодуфӣ", "fa": "مقاله تصادفی", "ar": "مقالة عشوائية", "uk": "Випадкова стаття"
        ]
    ]
    
    private let mapTranslations: [String: [String: String]] = [
        "Загрузка карты...": [
            "ru": "Загрузка карты...", "en": "Loading map...", "de": "Karte wird geladen...",
            "tj": "Боркунии харита...", "fa": "در حال بارگذاری نقشه...", "ar": "جارٍ تحميل الخريطة...", "uk": "Завантаження карти..."
        ]
    ]
    
    private let componentTranslations: [String: [String: String]] = [
        "Готово": [
            "ru": "Готово", "en": "Done", "de": "Fertig",
            "tj": "Тайёр", "fa": "انجام شد", "ar": "تم", "uk": "Готово"
        ],
        "Сбросить": [
            "ru": "Сбросить", "en": "Reset", "de": "Zurücksetzen",
            "tj": "Барқарор кардан", "fa": "بازنشانی", "ar": "إعادة تعيين", "uk": "Скинути"
        ],
        
        // 🔹 SearchView empty state
        "search_no_results_title": [
            "ru": "Ничего не найдено",
            "en": "No Results",
            "de": "Keine Ergebnisse",
            "tj": "Ҳеҷ чиз ёфт нашуд",
            "fa": "نتیجه‌ای پیدا نشد",
            "ar": "لا توجد نتائج",
            "uk": "Нічого не знайдено"
        ],
        "search_no_results_desc": [
            "ru": "Попробуйте изменить запрос или выбрать другой тег.",
            "en": "Try changing your query or selecting another tag.",
            "de": "Ändern Sie Ihre Suche oder wählen Sie einen anderen Tag.",
            "tj": "Кӯшиш кунед дархостро дигар кунед ё тегро иваз кунед.",
            "fa": "عبارت جستجو را تغییر دهید یا برچسب دیگری انتخاب کنید.",
            "ar": "جرّب تعديل البحث أو اختيار وسم آخر.",
            "uk": "Спробуйте змінити запит або вибрати інший тег."
        ],

        // 🔹 Generic accessibility hints
        "a11y_open_article_hint": [
            "ru": "Откроет статью.",
            "en": "Opens the article.",
            "de": "Öffnet den Artikel.",
            "tj": "Мақоларо мекушояд.",
            "fa": "مقاله را باز می‌کند.",
            "ar": "يفتح المقال.",
            "uk": "Відкриє статтю."
        ],

        // 🔹 Home tools accessibility hints
        "a11y_open_map_hint": [
            "ru": "Откроет карту.",
            "en": "Opens the map.",
            "de": "Öffnet die Karte.",
            "tj": "Харитаро мекушояд.",
            "fa": "نقشه را باز می‌کند.",
            "ar": "يفتح الخريطة.",
            "uk": "Відкриє карту."
        ],
        "a11y_open_pdf_library_hint": [
            "ru": "Откроет библиотеку PDF.",
            "en": "Opens the PDF library.",
            "de": "Öffnet die PDF-Bibliothek.",
            "tj": "Китобхонаи PDF-ро мекушояд.",
            "fa": "کتابخانه PDF را باز می‌کند.",
            "ar": "يفتح مكتبة PDF.",
            "uk": "Відкриє бібліотеку PDF."
        ],
        "a11y_open_random_article_hint": [
            "ru": "Откроет случайную статью.",
            "en": "Opens a random article.",
            "de": "Öffnet einen zufälligen Artikel.",
            "tj": "Мақолаи тасодуфиро мекушояд.",
            "fa": "یک مقاله تصادفی را باز می‌کند.",
            "ar": "يفتح مقالاً عشوائياً.",
            "uk": "Відкриє випадкову статтю."
        ],
        "common_all": [
            "ru": "Все", "en": "All", "de": "Alle",
            "tj": "Ҳама", "fa": "همه", "ar": "الكل", "uk": "Усі"
        ],
        "home_today": [
            "ru": "Сегодня", "en": "Today", "de": "Heute",
            "tj": "Имрӯз", "fa": "امروز", "ar": "اليوم", "uk": "Сьогодні"
        ],
        "home_random_short": [
            "ru": "Случайная", "en": "Random", "de": "Zufällig",
            "tj": "Тасодуфӣ", "fa": "تصادفی", "ar": "عشوائي", "uk": "Випадкова"
        ],
        "home_no_articles_title": [
            "ru": "Пока нет статей", "en": "No articles yet", "de": "Noch keine Artikel",
            "tj": "Ҳоло мақола нест", "fa": "فعلاً مقاله‌ای نیست", "ar": "لا توجد مقالات بعد", "uk": "Поки немає статей"
        ],
        "home_no_articles_subtitle": [
            "ru": "Данные загружаются или пока недоступны.",
            "en": "Data is loading or unavailable.",
            "de": "Daten werden geladen oder sind nicht verfügbar.",
            "tj": "Маълумот бор мешавад ё дастнорас аст.",
            "fa": "داده‌ها در حال بارگذاری است یا در دسترس نیست.",
            "ar": "يتم تحميل البيانات أو أنها غير متاحة.",
            "uk": "Дані завантажуються або недоступні."
        ],
        "home_quick_actions_title": [
            "ru": "Быстрые действия", "en": "Quick actions", "de": "Schnellaktionen",
            "tj": "Амалиёти зуд", "fa": "اقدام‌های سریع", "ar": "إجراءات سريعة", "uk": "Швидкі дії"
        ],
        "home_quick_actions_subtitle": [
            "ru": "Открой нужный раздел в один тап",
            "en": "Open what you need in one tap",
            "de": "Öffnen Sie den Bereich mit einem Tipp",
            "tj": "Қисми лозимро бо як ламс кушоед",
            "fa": "با یک لمس بخش موردنیاز را باز کنید",
            "ar": "افتح القسم المطلوب بنقرة واحدة",
            "uk": "Відкрий потрібний розділ одним натиском"
        ],
        "home_article": [
            "ru": "Статья", "en": "Article", "de": "Artikel",
            "tj": "Мақола", "fa": "مقاله", "ar": "مقال", "uk": "Стаття"
        ],
        "home_pdf_library": [
            "ru": "Библиотека", "en": "Library", "de": "Bibliothek",
            "tj": "Китобхона", "fa": "کتابخانه", "ar": "مكتبة", "uk": "Бібліотека"
        ],
        "home_places": [
            "ru": "Места", "en": "Places", "de": "Orte",
            "tj": "Ҷойҳо", "fa": "مکان‌ها", "ar": "أماكن", "uk": "Місця"
        ],
        "home_full_list": [
            "ru": "Полный список", "en": "Full list", "de": "Vollständige Liste",
            "tj": "Рӯйхати пурра", "fa": "فهرست کامل", "ar": "القائمة الكاملة", "uk": "Повний список"
        ]
    ]
    
    // MARK: - Объединение словарей
    
    private lazy var translations: [String: [String: String]] = {
        tabTranslations
            .merging(settingsTranslations) { $1 }
            .merging(categoryTranslations) { $1 }
            .merging(sectionTranslations) { $1 }
            .merging(mapTranslations) { $1 }
            .merging(componentTranslations) { $1 }
            .merging(textSettingsTranslations) { $1 }
            .merging(articleDetailTranslations) { $1 } // ✅ ДОБАВЛЕНО: articleDetailTranslations
    }()
    
    // MARK: - API
    
    func getTranslation(key: String, language: String) -> String {
        translations[key]?[language] ?? translations[key]?["en"] ?? key
    }
    
    public func t(_ key: String, language: String? = nil) -> String {
        let lang = language ?? selectedLanguage
        return getTranslation(key: key, language: lang)
    }
    
    /// Проверяет, существует ли ключ в словаре
    func hasKey(_ key: String) -> Bool {
        translations[key] != nil
    }
    
    // ✅ preload должен быть тут, внутри класса
    private static var didPreload = false
    func preload() {
        if !Self.didPreload {
            _ = translations   // форсируем инициализацию lazy
            _ = t("app_name")  // делаем первый вызов
            Self.didPreload = true
        }
    }
} // <-- закрываем класс здесь

// MARK: - Шорткат для SwiftUI
extension View {
    /// Avoids global singleton access; pass the LocalizationManager from DI / Environment.
    public func t(_ key: String, using localizationManager: LocalizationManager, language: String) -> String {
        localizationManager.t(key, language: language)
    }
}

