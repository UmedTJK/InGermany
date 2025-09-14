# 🇩🇪 InGermany — SwiftUI iOS App

## 👤 Обо мне

**Автор:** Umed Sabzaev  
**Локация:** Германия, Тюрингия  
**Роль:** iOS Developer / Translator / Content Creator  

### 🔧 Навыки и инструменты
- **Языки программирования:** Swift, SwiftUI, Python, JavaScript  
- **Фреймворки и технологии:** SwiftUI, UIKit (базово), Firebase (в планах), CoreData, Git, GitHub, WordPress  
- **Инструменты:** Xcode, VS Code, Notion, Trello, Figma, Local by Flywheel  
- **Области экспертизы:**  
  - Мобильная разработка (iOS, SwiftUI)  
  - Финансовые и юридические переводы (Tajik ↔ Russian ↔ English)  
  - Веб‑разработка (HTML, CSS, JS)  
  - Финансовая аналитика и личные финансы  
  - Создание контента (YouTube, блог, AI‑графика, SEO‑оптимизация)  

---

## 📱 О проекте: *InGermany – Work, Life and Study*

**Цель:** помочь мигрантам, студентам и семьям, планирующим переезд в Германию, разобраться в бюрократии, работе, учёбе и повседневной жизни.  

Приложение выступает как **справочник и навигатор** по важным темам: от виз и Jobcenter до депозитов, медицины и образования.

---

### ⚡️ Текущий статус (13.09.2025)
- Создан проект **InGermany** в **Xcode (Swift + SwiftUI, iOS 17+)**.  
- Настроена структура папок (см. ниже).  
- Подключены **JSON-данные** (статьи и категории).  
- Реализованы экраны: `Home`, `Categories`, `ArticlesByCategory`, `Search`, `ArticleView`.  
- Поддерживается **мультиязычность**: RU / EN / TJ.  
- Работают:  
  - фильтрация статей по категории,  
  - поиск по заголовкам, содержимому и тегам,  
  - кликабельные теги с фильтрацией,  
  - отображение категории и тегов в статье.  

---

### 📂 Структура проекта

```
InGermany/
├── Core/                # Основные файлы запуска приложения
│   ├── InGermanyApp.swift
│   └── ContentView.swift
│
├── Models/              # Модели данных
│   ├── Article.swift        # Статья (id, LocalizedText, category, tags)
│   └── Category.swift       # Категория (id, CategoryName, icon)
│
├── Views/               # Экраны (SwiftUI)
│   ├── HomeView.swift             # список всех статей
│   ├── CategoriesView.swift       # список категорий
│   ├── ArticlesByCategoryView.swift # статьи по категории
│   ├── ArticleView.swift          # полный текст статьи + теги
│   ├── SearchView.swift           # поиск по статьям и тегам
│   ├── SettingsView.swift         # (планируется) язык, тема, аккаунт
│   └── Components/
│       └── ArticleRow.swift       # UI-компонент для списка статей
│
├── Views/FavoritesView.swift      # (планируется) экран избранных статей
├── Views/FavoritesManager.swift   # (планируется) управление закладками
│
├── Services/
│   ├── DataService.swift          # загрузка данных из JSON
│   └── AuthService.swift          # (планируется) логика входа/регистрации
│
├── Utils/
│   ├── CategoryManager.swift      # работа с категориями
│   ├── LocalizationManager.swift  # мультиязычность
│   └── Theme.swift                # светлая/тёмная тема (в разработке)
│
├── Resources/
│   ├── articles.json              # база статей (RU/EN/TJ)
│   └── categories.json            # список категорий с иконками
│
├── Assets.xcassets/               # иконки и цвета
├── .gitignore                     # исключение лишних файлов (DerivedData, .DS_Store)
└── README.md                      # документация
```

---

### ✅ Текущие функции
- Многоязычные статьи (RU/EN/TJ) через `LocalizedText` и `CategoryName`.  
- `HomeView` — список всех статей.  
- `CategoriesView` — категории с иконками.  
- `ArticlesByCategoryView` — фильтрованные статьи по категориям.  
- `ArticleView` — полный текст статьи + теги + навигация по тегам.  
- `SearchView` — поиск по заголовкам, текстам и тегам, подсветка совпадений.  

---

### 🔮 Планируемые улучшения
- ⭐ **Избранные статьи** (UserData + FavoritesView).  
- 📤 **Поделиться статьёй** (через `ShareLink`).  
- 🎨 **Тёмная / светлая тема** (через `Theme.swift`).  
- 👤 **Аккаунт и профиль** (Email / Google / Apple ID).  
- ☁️ **Синхронизация статей через Firebase или свой backend**.  
- 📶 **Оффлайн-режим с CoreData**.  
- 📊 **Финансовые калькуляторы** (например, расчёт дохода по депозитам).  
- 🎥 **Интеграция с контентом YouTube-канала** (How it works in Germany).  

---

## 🔗 GitHub и работа с репозиторием

### Первичная настройка
1. Создать репозиторий на GitHub.  
2. В Xcode или в терминале инициализировать локальный репозиторий:  
   ```bash
   cd /Users/sumtjk/Desktop/InGermany
   git init
   git add .
   git commit -m "Initial commit"
   ```
3. Подключить удалённый репозиторий:  
   ```bash
   git branch -M main
   git remote add origin https://github.com/UmedTJK/InGermany.git
   git push -u origin main
   ```

> ⚠️ GitHub больше не принимает обычные пароли. Нужно использовать **Personal Access Token (PAT)** вместо пароля.

### Как получить PAT
- Перейди в [GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens).  
- Нажми **Generate new token → Classic**.  
- Выбери срок действия (например, 90 дней).  
- Отметь scope: `repo`.  
- Скопируй токен (он показывается только один раз).  

Когда терминал спросит пароль при `git push`, вставь токен.  

### Дальнейшая работа
- Сохраняешь изменения в коде → коммитишь → пушишь:  
  ```bash
  git add .
  git commit -m "Описание изменений"
  git push
  ```

- Чтобы обновить уже существующую ветку: просто `git push`.  
- Чтобы создать новую ветку:  
  ```bash
  git checkout -b feature/new-feature
  git push -u origin feature/new-feature
  ```

### Почему это важно
- ✅ История изменений всегда под рукой.  
- ✅ Удобно показывать код работодателю.  
- ✅ Можно подключить меня или других разработчиков для код-ревью.  
- ✅ GitHub Actions можно использовать для CI/CD и автосборки.  

---

## 📊 Для ИИ и автоматизации

- Модели (`Article`, `Category`, `LocalizedText`) — строго типизированы, `Codable` + `Identifiable`.  
- Локализация централизована через `LocalizationManager`.  
- Данные отделены в `Resources/` и грузятся через `DataService`.  
- Проект имеет чёткую модульную структуру, что облегчает анализ и автогенерацию кода.  
- `.gitignore` настроен — репозиторий чистый, без лишнего мусора.  

Эта документация даёт полную картину, чтобы любой разработчик или AI‑ассистент быстро понял устройство проекта.

---
