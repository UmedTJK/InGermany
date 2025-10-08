//
//  LocalizationManager.swift
//  InGermany
//


import SwiftUI

/// Менеджер локализации приложения.
/// Отвечает за хранение выбранного языка и получение переведённых строк из словаря.
final class LocalizationManager: ObservableObject, LocalizationManagerProtocol {
    /// Глобально доступный синглтон-экземпляр.
    static let shared = LocalizationManager()
    
    /// Код выбранного языка (например, `"ru"`, `"en"`).
    /// Сохраняется в `UserDefaults` через `@AppStorage`.
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"
    
    /// Приватный инициализатор, чтобы запретить создание других экземпляров.
    private init() {}
    
    /// Возвращает перевод для указанного ключа и языка.
    /// - Parameters:
    ///   - key: Ключ строки (например, `"Финансы"`, `"settings_language_title"`).
    ///   - language: Код языка (`ru`, `en`, `de`, `tj`, `fa`, `ar`, `uk`).
    /// - Returns: Переведённая строка, если найдена, иначе возвращается сам ключ.
    func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            
            // 🔹 Категории / теги
            "Финансы": [
                "ru": "Финансы",
                "en": "Finance",
                "de": "Finanzen",
                "tj": "Молия",
                "fa": "امور مالی",
                "ar": "المالية",
                "uk": "Фінанси"
            ],
            "Работа": [
                "ru": "Работа",
                "en": "Work",
                "de": "Arbeit",
                "tj": "Кор",
                "fa": "کار",
                "ar": "عمل",
                "uk": "Робота"
            ],
            "Учёба": [
                "ru": "Учёба",
                "en": "Study",
                "de": "Studium",
                "tj": "Хондан",
                "fa": "تحصیل",
                "ar": "دراسة",
                "uk": "Навчання"
            ],
            "Бюрократия": [
                "ru": "Бюрократия",
                "en": "Bureaucracy",
                "de": "Bürokratie",
                "tj": "Бюрократия",
                "fa": "بوروکراسی",
                "ar": "بيروقراطية",
                "uk": "Бюрократія"
            ],
            // 🔹 Tab bar
            "Главная": [
                "ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Саҳифаи асосӣ",
                "fa": "خانه", "ar": "الرئيسية", "uk": "Головна"
            ],
            "Категории": [
                "ru": "Категории", "en": "Categories", "de": "Kategorien", "tj": "Категорияҳо",
                "fa": "دسته‌ها", "ar": "الفئات", "uk": "Категорії"
            ],
            "Поиск": [
                "ru": "Поиск", "en": "Search", "de": "Suche", "tj": "Ҷустуҷӯ",
                "fa": "جستجو", "ar": "بحث", "uk": "Пошук"
            ],
            "Избранное": [
                "ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда",
                "fa": "علاقه‌مندی‌ها", "ar": "المفضلة", "uk": "Вибране"
            ],
            "Настройки": [
                "ru": "Настройки", "en": "Settings", "de": "Einstellungen", "tj": "Танзимот",
                "fa": "تنظیمات", "ar": "الإعدادات", "uk": "Налаштування"
            ],
            
            // 🔹 SettingsView
            "settings_language_title": [
                "ru": "Язык", "en": "Language", "de": "Sprache", "tj": "Забон",
                "fa": "زبان", "ar": "اللغة", "uk": "Мова"
            ],
            "settings_appearance_title": [
                "ru": "Оформление", "en": "Appearance", "de": "Darstellung", "tj": "Намуди зоҳирӣ",
                "fa": "ظاهر", "ar": "المظهر", "uk": "Вигляд"
            ],
            "settings_dark_mode": [
                "ru": "Тёмная тема", "en": "Dark Mode", "de": "Dunkelmodus", "tj": "Ҳолати торик",
                "fa": "حالت تاریک", "ar": "الوضع الداكن", "uk": "Темний режим"
            ],
            "settings_text_size": [
                "ru": "Размер текста", "en": "Text size", "de": "Textgröße", "tj": "Андозаи матн",
                "fa": "اندازه متن", "ar": "حجم النص", "uk": "Розмір тексту"
            ],
            "settings_date_format": [
                "ru": "Формат даты", "en": "Date format", "de": "Datumsformat", "tj": "Формати сана",
                "fa": "قالب تاریخ", "ar": "تنسيق التاريخ", "uk": "Формат дати"
            ],
            "settings_reading_stats": [
                "ru": "Статистика чтения", "en": "Reading stats", "de": "Lesestatistik", "tj": "Оморҳои хондан",
                "fa": "آمار مطالعه", "ar": "إحصائيات القراءة", "uk": "Статистика читання"
            ],
            
            
            "settings_about": [
                "ru": "О приложении", "en": "About", "de": "Über", "tj": "Дар бораи",
                "fa": "درباره", "ar": "حول", "uk": "Про застосунок"
            ],
            // 🔹 SettingsView (добавить недостающие ключи)
            "settings_title": [
                "ru": "Настройки", "en": "Settings", "de": "Einstellungen", "tj": "Танзимот",
                "fa": "تنظیمات", "ar": "الإعدادات", "uk": "Налаштування"
            ],
            "settings_card_style": [
                "ru": "Стиль карточек", "en": "Card style", "de": "Kartenstil", "tj": "Услуби кортҳо",
                "fa": "سبک کارت", "ar": "نمط البطاقات", "uk": "Стиль карток"
            ],
            "settings_card_style_photo": [
                "ru": "Фото", "en": "Photo", "de": "Foto", "tj": "Акс",
                "fa": "عکس", "ar": "صورة", "uk": "Фото"
            ],
            /*"settings_date_format_title": [
                "ru": "Формат даты", "en": "Date format", "de": "Datumsformat", "tj": "Формати сана",
                "fa": "قالب تاریخ", "ar": "تنسيق التاريخ", "uk": "Формат дати"
            ], */
            "settings_coming_soon": [
                "ru": "Скоро будет…", "en": "Coming soon…", "de": "Bald verfügbar…", "tj": "Ба зудӣ…",
                "fa": "به‌زودی…", "ar": "قريبًا…", "uk": "Незабаром…"
            ],
            "settings_stats_title": [
                "ru": "Статистика чтения", "en": "Reading stats", "de": "Lesestatistik", "tj": "Оморҳои хондан",
                "fa": "آمار مطالعه", "ar": "إحصائيات القراءة", "uk": "Статистика читання"
            ],
            "settings_in_development": [
                "ru": "В разработке…", "en": "In development…", "de": "In Entwicklung…", "tj": "Дар таҳия…",
                "fa": "در حال توسعه…", "ar": "قيد التطوير…", "uk": "У розробці…"
            ],
            "settings_about_title": [
                "ru": "О приложении", "en": "About", "de": "Über", "tj": "Дар бораи",
                "fa": "درباره", "ar": "حول", "uk": "Про застосунок"
            ],
            "settings_relative_dates": [
                "ru": "Относительные даты",
                "en": "Relative dates",
                "de": "Relative Daten",
                "tj": "Санаҳои нисбӣ",
                "fa": "تاریخ نسبی",
                "ar": "تواريخ نسبية",
                "uk": "Відносні дати"
            ],
            "settings_articles_read": [
                "ru": "Прочитано статей",
                "en": "Articles read",
                "de": "Artikel gelesen",
                "tj": "Мақолаҳои хондашуда",
                "fa": "مقالات خوانده‌شده",
                "ar": "المقالات المقروءة",
                "uk": "Прочитано статей"
            ],
            "settings_total_time": [
                "ru": "Общее время",
                "en": "Total time",
                "de": "Gesamtzeit",
                "tj": "Вақти умумӣ",
                "fa": "زمان کل",
                "ar": "الوقت الإجمالي",
                "uk": "Загальний час"
            ],
            "settings_average_time": [
                "ru": "Среднее время",
                "en": "Average time",
                "de": "Durchschnittszeit",
                "tj": "Вақти миёна",
                "fa": "زمان متوسط",
                "ar": "الوقت المتوسط",
                "uk": "Середній час"
            ],
            "settings_streak": [
                "ru": "Серия",
                "en": "Streak",
                "de": "Serie",
                "tj": "Силсила",
                "fa": "رکورد پیاپی",
                "ar": "سلسلة متتالية",
                "uk": "Серія"
            ],
            "settings_clear_history": [
                "ru": "Очистить историю",
                "en": "Clear history",
                "de": "Verlauf löschen",
                "tj": "Пок кардани таърих",
                "fa": "پاک کردن تاریخچه",
                "ar": "مسح السجل",
                "uk": "Очистити історію"
            ],
            "settings_minutes": [
              "ru": "мин",
              "en": "min",
              "de": "Min.",
              "tj": "дақ",
              "fa": "دقیقه",
              "ar": "دقيقة",
              "uk": "хв"
            ],
            
            "card_style_all": [
              "ru": "Все углы",
              "en": "All corners",
              "de": "Alle Ecken",
              "tj": "Ҳама гӯшаҳо",
              "fa": "همه گوشه‌ها",
              "ar": "كل الزوايا",
              "uk": "Усі кути"
            ],
            "card_style_bottom": [
              "ru": "Снизу",
              "en": "Bottom only",
              "de": "Unten",
              "tj": "Аз поён",
              "fa": "پایین",
              "ar": "في الأسفل",
              "uk": "Знизу"
            ],
            "card_style_full": [
              "ru": "Во всю ширину",
              "en": "Full width",
              "de": "Volle Breite",
              "tj": "Ба пуррагӣ",
              "fa": "تمام عرض",
              "ar": "العرض الكامل",
              "uk": "На всю ширину"
            ],

            
            // 🔹 AboutView
            "about_description": [
                "ru": "InGermany — справочник для жизни в Германии.",
                "en": "InGermany — a guide to life in Germany.",
                "de": "InGermany — ein Leitfaden für das Leben in Deutschland.",
                "tj": "InGermany — роҳнамо барои зиндагӣ дар Олмон.",
                "fa": "InGermany — راهنمای زندگی در آلمان.",
                "ar": "InGermany — دليل للحياة في ألمانيا.",
                "uk": "InGermany — довідник для життя в Німеччині."
            ],
            "tab_about": [
                "ru": "О проекте", "en": "About", "de": "Über das Projekt", "tj": "Дар бораи лоиҳа",
                "fa": "درباره پروژه", "ar": "حول المشروع", "uk": "Проєкт"
            ],
            
            // 🔹 ArticleView
            "Оцените статью": [
                "ru": "Оцените статью", "en": "Rate this article", "de": "Artikel bewerten",
                "tj": "Мақоларо баҳогузорӣ кунед", "fa": "به این مقاله امتیاز دهید",
                "ar": "قيّم هذه المقالة", "uk": "Оцініть статтю"
            ],
            "Поделитесь этой статьёй": [
                "ru": "Поделитесь этой статьёй", "en": "Share this article", "de": "Artikel teilen",
                "tj": "Ин мақоларо мубодила кунед", "fa": "این مقاله را به اشتراک بگذارید",
                "ar": "شارك هذه المقالة", "uk": "Поділіться цією статтею"
            ],
            "Поделиться статьёй": [
                "ru": "Поделиться статьёй", "en": "Share article", "de": "Artikel teilen",
                "tj": "Мақоларо мубодила кунед", "fa": "اشتراک‌گذاری مقاله",
                "ar": "مشاركة المقالة", "uk": "Поділитися статтею"
            ],
            "Похожие статьи": [
                "ru": "Похожие статьи", "en": "Related articles", "de": "Ähnliche Artikel",
                "tj": "Мақолаҳои монанд", "fa": "مقالات مشابه",
                "ar": "مقالات مشابهة", "uk": "Схожі статті"
            ],
            
            // 🔹 HomeView
            "Полезные инструменты": [
                "ru": "Полезные инструменты", "en": "Useful tools", "de": "Nützliche Werkzeuge",
                "tj": "Асбобҳои муфид", "fa": "ابزارهای مفید",
                "ar": "أدوات مفيدة", "uk": "Корисні інструменти"
            ],
            "PDF Документы": [
                "ru": "PDF Документы", "en": "PDF Documents", "de": "PDF-Dokumente",
                "tj": "Ҳуҷҷатҳои PDF", "fa": "اسناد PDF",
                "ar": "مستندات PDF", "uk": "PDF документи"
            ],
            "Случайная статья": [
                "ru": "Случайная статья", "en": "Random article", "de": "Zufälliger Artikel",
                "tj": "Мақолаи тасодуфӣ", "fa": "مقاله تصادفی",
                "ar": "مقالة عشوائية", "uk": "Випадкова стаття"
            ],
            "Недавно прочитанное": [
                "ru": "Недавно прочитанное", "en": "Recently read", "de": "Kürzlich gelesen",
                "tj": "Мақолаҳои охир хондашуда", "fa": "اخیراً خوانده شده",
                "ar": "تمت قراءته مؤخراً", "uk": "Нещодавно прочитане"
            ],
            "Все статьи": [
                "ru": "Все статьи", "en": "All articles", "de": "Alle Artikel",
                "tj": "Ҳамаи мақолаҳо", "fa": "همه مقالات",
                "ar": "جميع المقالات", "uk": "Усі статті"
            ],
            "Загрузка данных...": [
                "ru": "Загрузка данных...", "en": "Loading data...", "de": "Daten werden geladen...",
                "tj": "Боркунии маълумот...", "fa": "در حال بارگذاری داده‌ها...",
                "ar": "جارٍ تحميل البيانات...", "uk": "Завантаження даних..."
            ],
            
            // 🔹 MapView
            "Загрузка карты...": [
                "ru": "Загрузка карты...", "en": "Loading map...", "de": "Karte wird geladen...",
                "tj": "Боркунии харита...", "fa": "در حال بارگذاری نقشه...",
                "ar": "جارٍ تحميل الخريطة...", "uk": "Завантаження карти..."
            ],
            "Моё местоположение": [
                "ru": "Моё местоположение", "en": "My location", "de": "Mein Standort",
                "tj": "Ҷойгиршавии ман", "fa": "مکان من",
                "ar": "موقعي", "uk": "Моє місцезнаходження"
            ],
            "Обновить": [
                "ru": "Обновить", "en": "Refresh", "de": "Aktualisieren",
                "tj": "Навсозӣ", "fa": "به‌روزرسانی",
                "ar": "تحديث", "uk": "Оновити"
            ],
            
            // 🔹 SearchView
            "Искать по статьям или категориям": [
                "ru": "Искать по статьям или категориям", "en": "Search articles or categories",
                "de": "Artikel oder Kategorien suchen", "tj": "Ҷустуҷӯ аз рӯи мақолаҳо ё категорияҳо",
                "fa": "جستجو در مقالات یا دسته‌ها", "ar": "ابحث في المقالات أو الفئات",
                "uk": "Шукати за статтями чи категоріями"
            ],
            
            // 🔹 ArticleDetailView
            "Статья": [
                "ru": "Статья", "en": "Article", "de": "Artikel",
                "tj": "Мақола", "fa": "مقاله", "ar": "مقالة", "uk": "Стаття"
            ],
            "Экспорт в PDF": [
                "ru": "Экспорт в PDF", "en": "Export to PDF", "de": "Als PDF exportieren",
                "tj": "Содирот ба PDF", "fa": "خروجی به PDF", "ar": "تصدير إلى PDF", "uk": "Експорт у PDF"
            ],
            "Открыть PDF": [
                "ru": "Открыть PDF", "en": "Open PDF", "de": "PDF öffnen",
                "tj": "Кушодани PDF", "fa": "باز کردن PDF", "ar": "فتح ملف PDF", "uk": "Відкрити PDF"
            ],
            
            // 🔹 PDFViewer
            "PDF": [
                "ru": "PDF", "en": "PDF", "de": "PDF",
                "tj": "PDF", "fa": "PDF", "ar": "PDF", "uk": "PDF"
            ],
            "PDF не найден.": [
                "ru": "PDF не найден.", "en": "PDF not found.", "de": "PDF nicht gefunden.",
                "tj": "PDF ёфт нашуд.", "fa": "PDF پیدا نشد.", "ar": "ملف PDF غير موجود.", "uk": "PDF не знайдено."
            ],
            
            // 🔹 Components / EmptyFavoritesView
            "Ничего не найдено": [
                "ru": "Ничего не найдено", "en": "Nothing found", "de": "Nichts gefunden",
                "tj": "Ҳеҷ чиз ёфт нашуд", "fa": "چیزی پیدا نشد", "ar": "لم يتم العثور على شيء", "uk": "Нічого не знайдено"
            ],
            "Нет избранного": [
                "ru": "Нет избранного", "en": "No favorites", "de": "Keine Favoriten",
                "tj": "Интихобшуда нест", "fa": "مورد علاقه‌ای وجود ندارد", "ar": "لا مفضلة", "uk": "Немає вибраного"
            ],
            "Попробуйте другой запрос или категорию": [
                "ru": "Попробуйте другой запрос или категорию", "en": "Try another query or category", "de": "Versuchen Sie eine andere Anfrage oder Kategorie",
                "tj": "Дархост ё категорияи дигарро санҷед", "fa": "عبارت یا دسته دیگری را امتحان کنید", "ar": "جرّب استعلامًا أو فئة أخرى", "uk": "Спробуйте інший запит чи категорію"
            ],
            
            // 🔹 ReadingProgressBar
            "Прогресс чтения": [
                "ru": "Прогресс чтения", "en": "Reading progress", "de": "Lesefortschritt",
                "tj": "Пешрафти хондан", "fa": "پیشرفت مطالعه", "ar": "تقدم القراءة", "uk": "Прогрес читання"
            ],
            "Читаете": [
                "ru": "Читаете", "en": "Reading", "de": "Am Lesen",
                "tj": "Дар ҳолати хондан", "fa": "در حال مطالعه", "ar": "تقرأ", "uk": "Читаєте"
            ],
            // Добавьте в словарь translations:
            "Вам может понравиться": [
                "ru": "Вам может понравиться",
                "en": "You might like",
                "de": "Das könnte Ihnen gefallen",
                "tj": "Шумо инро дӯст медоред",
                "fa": "ممکن است دوست داشته باشید",
                "ar": "قد يعجبك",
                "uk": "Вам може сподобатися"
            ],
            "Показать": [
                "ru": "Показать", "en": "Show", "de": "Zeigen",
                "tj": "Нишон диҳед", "fa": "نمایش", "ar": "عرض", "uk": "Показати"
            ],
            "Скрыть": [
                "ru": "Скрыть", "en": "Hide", "de": "Ausblenden",
                "tj": "Пинҳон кардан", "fa": "پنهان", "ar": "إخفاء", "uk": "Приховати"
            ],
            "Время чтения": [
                "ru": "Время чтения", "en": "Reading time", "de": "Lesezeit",
                "tj": "Вақти хондан", "fa": "زمان مطالعه", "ar": "وقت القراءة", "uk": "Час читання"
            ],
            "Опубликовано": [
                "ru": "Опубликовано", "en": "Published", "de": "Veröffentlicht",
                "tj": "Нашр шуд", "fa": "منتشر شده", "ar": "نشر", "uk": "Опубліковано"
            ],
            "Обновлено": [
                "ru": "Обновлено", "en": "Updated", "de": "Aktualisiert",
                "tj": "Навсозӣ шуд", "fa": "به روز شده", "ar": "تم التحديث", "uk": "Оновлено"
            ],
            "Новое": [
                "ru": "Новое", "en": "New", "de": "Neu",
                "tj": "Нав", "fa": "جدید", "ar": "جديد", "uk": "Нове"
            ],
            "Прочитано": [
                "ru": "Прочитано", "en": "Read", "de": "Gelesen",
                "tj": "Хонда шуд", "fa": "خوانده شده", "ar": "مقروء", "uk": "Прочитано"
            ],
            
            // 🔹 TextSizeSettingsPanel
            "Размер текста": [
                "ru": "Размер текста", "en": "Text size", "de": "Textgröße",
                "tj": "Андозаи матн", "fa": "اندازه متن", "ar": "حجم النص", "uk": "Розмір тексту"
            ],
            "Настройки текста": [
                "ru": "Настройки текста", "en": "Text settings", "de": "Texteinstellungen",
                "tj": "Танзимоти матн", "fa": "تنظیمات متن", "ar": "إعدادات النص", "uk": "Налаштування тексту"
            ],
            "Сбросить": [
                "ru": "Сбросить", "en": "Reset", "de": "Zurücksetzen",
                "tj": "Барқарор кардан", "fa": "بازنشانی", "ar": "إعادة تعيين", "uk": "Скинути"
            ],
            "Пример текста": [
                "ru": "Пример текста", "en": "Sample text", "de": "Beispieltext",
                "tj": "Намунаи матн", "fa": "نمونه متن", "ar": "نص تجريبي", "uk": "Приклад тексту"
            ],
            "Пользовательский размер": [
                "ru": "Пользовательский размер", "en": "Custom size", "de": "Benutzerdefinierte Größe",
                "tj": "Андозаи фармоишӣ", "fa": "اندازه سفارشی", "ar": "حجم مخصص", "uk": "Користувацький розмір"
            ],
            "Готово": [
                "ru": "Готово", "en": "Done", "de": "Fertig",
                "tj": "Тайёр", "fa": "انجام شد", "ar": "تم", "uk": "Готово"
            ]
        ]
        return translations[key]?[language] ?? key
        
        
    }
    
    /// Упрощённый доступ к переводу с автоопределением текущего языка.
    /// - Parameters:
    ///   - key: Ключ строки для перевода.
    ///   - language: Необязательный параметр языка; если `nil`, используется выбранный язык.
    /// - Returns: Переведённая строка или сам ключ, если перевода нет.
    func t(_ key: String, language: String? = nil) -> String {
        let lang = language ?? selectedLanguage
        return getTranslation(key: key, language: lang)
    }
}

// MARK: - Шорткат для SwiftUI
extension View {
    /// Удобный шорткат для перевода строк прямо во `View`.
    /// - Parameter key: Ключ для перевода.
    /// - Returns: Переведённая строка.
    func t(_ key: String) -> String {
        LocalizationManager.shared.t(key)
    }

}
