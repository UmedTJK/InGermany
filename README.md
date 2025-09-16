# 🇩🇪 InGermany

Многоязычное iOS-приложение-путеводитель по жизни в Германии: статьи, категории, избранное, карта, PDF-документы и тёмная тема.

---

## ⚙️ Технологии

- `SwiftUI` + `MVVM`
- `AppStorage` для настроек
- `ObservableObject` и `EnvironmentObject` для состояния
- `JSON`-данные локально
- `ShareLink`, `NavigationStack`, `TabView`, `List`, `ToolbarItem`
- Полностью поддерживает `Dark Mode`
- Адаптирован под `iOS 17`

---

## 🌍 Локализация

- 🇷🇺 Русский
- 🇺🇸 Английский
- 🇹🇯 Таджикский

---

## 🗂 Структура

- `/Views/` — все основные экраны (`HomeView`, `SearchView`, `ArticleView` и др.)
- `/Models/` — модели данных: `Article`, `Category`, `Location`
- `/Services/` — `DataService`, `FavoritesManager`, `RatingManager`
- `/Utils/` — менеджеры локализации, темы, анимации
- `/Resources/` — иконки, JSON-файлы, карты
- `/Core/` — `InGermanyApp.swift`, `ContentView.swift`

---

## ⚡️ Текущий статус (v1.4.2-related)

- Список всех статей
- Категории статей с иконками
- Поиск по названию, содержанию, категории и тегам
- Избранное с сохранением в память
- Отображение тегов
- Тёмная тема
- Навигация по категориям
- Счётчик прочтений
- 💛 Рейтинг статьи (1–5 звёзд)
- 📄 Просмотр PDF внутри приложения
- 🗺 Карта с локациями по JSON
- 📤 Поделиться статьёй через `ShareLink`
- 🔗 Похожие статьи из той же категории (макс. 3)

---

## 🧠 Roadmap

- [x] 🌐 Мультиязычность (RU/EN/TJ)
- [x] 💾 Локальные JSON-файлы
- [x] 📥 Экран с избранными статьями
- [x] 🗃 Категории с фильтрацией
- [x] 🔍 Поиск по статьям и тегам
- [x] 📚 Теги и фильтрация по ним
- [x] ⭐️ Оценка статьи
- [x] 📤 Поделиться статьёй (`ShareLink`)
- [x] 🔗 Похожие статьи из той же категории (`ArticleView`)
- [x] 🗺 Добавить карту (`MapKit`)
- [ ] 🗂 Загрузка из Firebase/Supabase
- [ ] 📈 Unit-тесты для моделей и логики
- [ ] 📝 Админка для редактирования статей
- [ ] 💬 Комментарии под статьями
- [ ] 🧩 Архитектура Plug-in
- [ ] 🪪 Авторизация пользователя (OAuth)
- [ ] 💼 Добавить раздел “Работа в Германии”
- [ ] 🧾 Подключение к API Jobcenter / BAMF

---

## 📊 Для ИИ и автоматизации

- Все ключевые данные локализованы через `LocalizationManager`
- Категории управляются `CategoryManager.shared`
- Избранное — через `FavoritesManager`
- JSON-парсинг реализован вручную
- Статья содержит: ID, Title, Content, Tags, CategoryID
- Похожие статьи определяются по `categoryId`
- Рейтинг хранится в `UserDefaults` через `RatingManager`

---

## 📦 Установка

```
git clone https://github.com/UmedTJK/InGermany.git
cd InGermany
open InGermany.xcodeproj
```

---

## 🧑‍💻 Автор

Umed Sabzaev  
📧 umedsbz@gmail.com  
📍 Germany  
🔗 [GitHub](https://github.com/UmedTJK) | [LinkedIn](https://www.linkedin.com/in/umed-sabzaev)

---

## 📄 Лицензия

MIT — свободно используйте, модифицируйте и распространяйте с указанием авторства.