# 🚀 InGermany – Roadmap Junior+ → Middle

## ✅ Уже реализовано (уровень Junior+)
- MVVM + DI через AppContainer  
- SOLID, чистая архитектура  
- Doc-комментарии ко всему публичному API  
- Локализация (RU/EN/TJ + дополнительные языки)  
- Темная тема, избранное, поиск, фильтры  
- Работа с JSON, статические данные  
- UI-компоненты и секции вынесены в отдельные модули  
- GitHub workflow: feature-ветки, changelog, теги релизов  
- Полный DI-рефакторинг (удалены singletons, чистый Composition Root, DI-pure тесты)


## 🎯 Следующая цель – Middle showcase

### Архитектура и код
- [x] Unit-тесты для Managers, Services, ViewModels (DI-pure, без singletons)  
- [ ] UI-тесты (например, запуск HomeView / SearchView)  
- [x] Dependency Injection через протоколы и мок-реализации (полный отказ от .shared)  
- [x] Асинхронный DataService (`async/await`) + обработка ошибок  
- [x] Strict in-flight deduplication + cancellation-safe retry (F4 stabilization, actors + structured concurrency)  
- [x] Observability foundation (F5 Phase 1): DI-based metrics, DEBUG snapshot logging, Debug overlay)

### Работа с данными
- [ ] SwiftData/CoreData для избранного и истории  
- [x] Кэширование и офлайн-режим (CacheService + offline-first NetworkService)  
- [ ] ArticlesRepository с реальным API (например, GitHub Pages)  

### UI/UX
- [ ] Accessibility (VoiceOver, Dynamic Type, контрастность)  
- [ ] Snapshot-тесты для UI  
- [ ] Кастомные интерактивные переходы  
- [ ] Соответствие Apple Human Interface Guidelines  

### Инфраструктура
- [ ] CI/CD (GitHub Actions): сборка + тесты + линтер  
- [ ] Автогенерация DocC сайта на GitHub Pages  
- [ ] SwiftFormat + SwiftLint автопроверка  
- [ ] Extend metrics coverage to DataService + expose structured metrics export (JSON snapshot)

### Проф. фичи
- [ ] Feature flags / Remote config  
- [ ] Аналитика (Firebase/TelemetryDeck)  
- [ ] Mock-auth (Apple ID, локальный логин)  


📌 **Цель:**  
К концу этой Roadmap проект “InGermany” можно показывать как полноценный showcase уровня Middle iOS Developer.

---

## ⭐ Опционально (движение к Senior)

### Архитектура и платформа
- [ ] Архитектурные паттерны: TCA или Clean Architecture  
- [ ] Продвинутый DI-контейнер (Needle, Resolver)  
- [ ] Multiplatform (iPad + Mac Catalyst)  
- [x] Swift Concurrency best practices (actors, structured concurrency, cancellation-aware retry)  

### Тестирование
- [ ] Покрытие ключевых Managers, Services и ViewModels (>80%)  
- [ ] Тестирование краевых случаев (пустые данные, ошибки парсинга, локализация)  
- [ ] Использование Mocking & Stubs для изоляции зависимостей  
- [ ] Property-based testing (генерация случайных входных данных)  
- [x] Performance-тесты для ресурсоёмких операций (JSON load + parallel stress validation)  
- [ ] End-to-End сценарии (поиск → избранное → статья → экспорт PDF)  
- [ ] Snapshot-тесты для основных экранов (HomeView, SearchView, ArticleDetailView)  
- [ ] Accessibility-тесты (VoiceOver, Dynamic Type)  
- [x] Test Plans в Xcode для разных типов тестов (Unit + TSAN stress suite)  
- [ ] Metrics validation tests (ensure counters fire on retry / dedupe / cancellation paths)  
- [ ] Code coverage reports (например, Slather + GitHub Actions)  

### Инфраструктура
- [ ] CI/CD с автодеплоем на TestFlight  
- [ ] Параллельный запуск тестов на CI  
- [ ] Перфоманс-профилирование (Instruments)  
- [ ] CI integration with TSAN + parallel stress runs
