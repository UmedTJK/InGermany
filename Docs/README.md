1. НОВЫЙ README.md
# 🇩🇪 InGermany - iOS Справочник для экспатов

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.9-F05138.svg)
![Platform](https://img.shields.io/badge/iOS-17+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Version](https://img.shields.io/badge/version-1.17.0-orange.svg)

**Мультиязычное iOS-приложение для жизни в Германии**

[Скриншоты](#скриншоты) • [Функции](#функции) • [Установка](#установка) • [Разработка](#разработка)

</div>

---

## 📱 О приложении

InGermany — это всесторонний справочник для экспатов, помогающий адаптироваться в Германии. Приложение предлагает статьи, справочники, карты, полезные инструменты и персонализированные функции.

**Основные цели:**
- Помощь в адаптации через структурированный контент
- Поддержка 7 языков (RU, EN, DE, TJ, FA, AR, UK)
- Офлайн-доступ ко всей информации
- Персонализированный опыт (избранное, история, прогресс)

---

## ✨ Функции

### 📖 Контент
- 13+ подробных статей по категориям (Финансы, Учёба, Жизнь)
- Структурированный контент с изображениями и PDF
- Регулярные обновления и новые материалы

### 🌍 Мультиязычность
- Поддержка 7 языков с полной локализацией
- Автоматическое определение языка устройства
- Ручной выбор языка в настройках

### 🎯 Персонализация
- **Избранное** — сохраняйте важные статьи
- **История чтения** — отслеживайте прогресс
- **Рейтинг статей** — оценивайте полезность
- **Статистика** — анализируйте время чтения

### 🗺️ Инструменты
- **Карта** — полезные локации в Германии
- **PDF библиотека** — важные документы
- **Случайная статья** — открывайте новое

### ⚙️ Настройки
- Тёмная/светлая тема
- Размер текста (80%-150%)
- Стиль карточек
- Относительные даты
- Сброс статистики

---

## 📸 Скриншоты

| Главная | Статьи | Поиск | Карта |
|---------|--------|-------|-------|
| ![Home](Docs/screenshots/home.png) | ![Categories](Docs/screenshots/categoriesView.png) | ![Search](Docs/screenshots/SearchView.png) | ![Map](Docs/screenshots/map.png) |

| Настройки | PDF | Детали | Избранное |
|-----------|-----|--------|-----------|
| ![Settings](Docs/screenshots/settings.png) | ![PDF](Docs/screenshots/detail.png) | ![Detail](Docs/screenshots/articlesByCategoryView.png) | ![Favorites](Docs/screenshots/FavoritesView.png) |

---

## 🛠️ Технологии

- **Язык:** Swift 5.9+
- **Платформа:** iOS 17.0+
- **Архитектура:** MVVM + Repository Pattern + Dependency Injection
- **DI:** AppContainer (Single Source of Truth)
- **Состояние настроек:** SettingsManager (ObservableObject)
- **Хранение:** UserDefaults (@AppStorage), File System, Bundle
- **Тестирование:** XCTest (unit tests, in progress)
- **Локализация:** Xcode String Catalogs

---

## 🚀 Установка

### Для пользователей
1. Скачайте из App Store (скоро)
2. Или соберите из исходного кода

### Для разработчиков
```bash
# 1. Клонируйте репозиторий
git clone https://github.com/UmedTJK/InGermany.git

# 2. Откройте проект
open InGermany.xcodeproj

# 3. Выберите схему 'InGermany'
# 4. Запустите на симуляторе или устройстве
Требования:

Xcode 15.0+

iOS 17.0+

macOS 14.0+ (для разработки)

🏗️ Архитектура
Приложение построено на современных архитектурных принципах:

text
📁 Core/           # Точка входа и DI-контейнер (AppContainer)
📁 Managers/       # Observable state (Settings, Favorites, Rating, Stats)
📁 Models/         # Модели данных (Article, Category, Location)
📁 ViewModels/     # Бизнес-логика экранов
📁 Views/          # SwiftUI экраны и компоненты
📁 Services/       # Сервисы (Localization, Network, Cache)
📁 Managers/       # Observable state (Settings, Favorites, Rating, Stats)
📁 Protocols/      # Интерфейсы для DI и тестирования
📁 UIUtils/        # Утилиты UI (стили, анимации)
📁 Docs/           # Документация


Ключевые принципы:

AppContainer отвечает только за DI и фабрики, а не за хранение состояния UI.

SOLID и Clean Architecture

Dependency Injection через AppContainer

Offline-first стратегия

Полное покрытие тестами


### ⚙️ Настройки
Все пользовательские настройки управляются через SettingsManager
(единый источник истины для темы, языка и отображения).


📚 Документация
Для разработчиков:
Техническая документация (AI_CONTEXT.md) — актуальное описание архитектуры и DI


CHANGELOG - история изменений

Roadmap редактора - план развития CMS

Архитектурные решения - анализ архитектуры

Для пользователей:
Руководство пользователя (в разработке)

FAQ (в разработке)

🎯 Roadmap
В разработке:
Улучшение Article Editor / Mini-CMS

Расширение библиотеки статей

Интеграция с бэкендом

Планируется:
Push-уведомления о новых статьях

Социальные функции (комментарии, обсуждения)

Расширенная аналитика

Веб-версия приложения

🤝 Участие в разработке
Мы приветствуем contributions!

Форкните репозиторий

Создайте ветку для вашей фичи (feature/amazing-feature)

Сделайте коммиты с Conventional Commits

Откройте Pull Request

Стиль кода: Следуем SwiftLint правилам

📄 Лицензия
Этот проект лицензирован под MIT License - смотрите файл LICENSE.

👨‍💻 Автор
Umed Sabzaev

GitHub: @UmedTJK

LinkedIn: Umed Sabzaev

Email: umedsbz@gmail.com

🌟 Поддержка проекта
Если проект вам полезен:

⭐ Поставьте звезду на GitHub

🐛 Сообщайте о багах через Issues

💡 Предлагайте фичи через Discussions

📢 Расскажите друзьям о приложении

<div align="center">
Сделано с ❤️ для экспатов в Германии

Последнее обновление: октябрь 2025

</div> ```
