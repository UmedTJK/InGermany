🇩🇪 InGermany

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-15-blue?logo=xcode)](https://developer.apple.com/xcode/)
[![Platform](https://img.shields.io/badge/iOS-16+-lightgrey?logo=apple)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> 📱 Мобильное приложение для новых жителей Германии: справочник, статьи, карта, избранное и мультиязычная поддержка.
> Построено на **SwiftUI**, с упором на **чистую архитектуру (MVVM + DI)** и **отличный UX**.


## ✨ Features

* 📚 **Справочник статей** — жизнь, работа, учёба и адаптация в Германии
* 🌙 **Тёмная / светлая тема**
* 🌍 **Мультиязычность** (RU, EN, DE, TJ, FA, AR, UK)
* ⭐ **Избранное** — сохраняй важные статьи
* 📖 **История чтения** и оценка времени чтения
* 🗺 **Карта** с важными локациями
* 📄 **Экспорт в PDF**
* 🎨 **UI Utils** — анимации, shimmer, скелетоны, доступность

---

## 📸 Скриншоты

| HomeView | ArticleDetail | Settings | Map |
|----------|---------------|----------|-----|
| ![Home](Docs/screenshots/home.png) | ![Detail](Docs/screenshots/detail.png) | ![Settings](Docs/screenshots/settings.png) | ![Map](Docs/screenshots/map.png) |

| Categories | Search | Favorites | About |
|------------|--------|-----------|-------|
| ![Categories](Docs/screenshots/categoriesView.png) | ![Search](Docs/screenshots/search.png) | ![Favorites](Docs/screenshots/favorites.png) | ![About](Docs/screenshots/article.png) |


## 🛠 Технологии

* **Swift 5.9 / Xcode 15**
* **SwiftUI** + **MVVM** + **Dependency Injection (AppContainer)**
* **Unit Tests** (репозитории, менеджеры)
* **GitHub Pages** как источник JSON-данных
* **UI Utils**: Shimmer, Shake, ScaleOnTap, Loading Overlay, Accessibility

---

## 📚 Документация

* [AI_CONTEXT.md](Docs/AI_CONTEXT.md) — архитектура и roadmap
* [CHANGELOG.md](Docs/CHANGELOG.md) — список изменений
* [CLEAN_CODE_CHECKLIST.md](Docs/CLEAN_CODE_CHECKLIST.md) — стандарты кода
* [UIUTILS_GUIDE.md](Docs/UIUTILS_GUIDE.md) — все UI утилиты и сценарии их использования

---

## 🚀 Запуск проекта

```bash
git clone https://github.com/UmedTJK/InGermany.git
cd InGermany
open InGermany.xcodeproj
```


## 🎯 Roadmap (v1.0 → v2.0)

* [x] Мультиязычность (RU, EN, DE, TJ, FA, AR, UK)
* [x] Темы (Dark / Light)
* [x] Избранное + История чтения
* [ ] Улучшенные карты (Apple Maps + локации)
* [ ] Интеграция Supabase / Firebase
* [ ] UI-тесты и Snapshot-тестирование
* [ ] Публикация в **App Store**



## 👨‍💻 Автор

**Umed Sabzaev**

* 📧 [umedsbz@gmail.com](mailto:umedsbz@gmail.com)
* 🌐 [LinkedIn](https://www.linkedin.com/in/umed-sabzaev)
* 💻 iOS Developer (Junior → Middle)



## 📄 Лицензия

Проект распространяется под лицензией **MIT**.
См. файл [LICENSE](LICENSE) для подробностей.

