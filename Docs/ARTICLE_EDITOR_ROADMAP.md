📄 Article Editor / Mini-CMS Roadmap

## 🎯 Цель
Создать полноценный **визуальный редактор статей** для приложения InGermany, который со временем превратится в **мини-CMS** (content management system) и отдельное **Admin-приложение для MacOS**.  

Редактор должен позволять:
- ✍️ создавать новые статьи (title + структурированные блоки),  
- 👀 видеть Live Preview,  
- 📤 экспортировать JSON в совместимом формате,  
- 📥 импортировать JSON обратно в редактор,  
- 📚 управлять библиотекой статей.  

## 🏗️ ТЕКУЩАЯ АРХИТЕКТУРА (ОБНОВЛЕНО)

### 📦 Модульная структура проекта
```
InGermany/
├── InGermany.xcodeproj/                 # Основное iOS приложение
├── InGermanyCMS/                        # Отдельное macOS CMS приложение
│   ├── Resources/                       # Ресурсы CMS
│   │   └── burgeramt_registration.json  # Демо статьи
│   └── Views/                           # Views CMS приложения
│       ├── ArticleLibraryView.swift
│       ├── DemoArticleView.swift
│       └── ArticleEditorView.swift
└── Packages/                            # Swift Packages
    ├── ArticleKit/                      # Основной пакет редактора
    │   ├── Sources/ArticleKit/
    │   │   ├── Models/                  # Модели данных
    │   │   │   ├── ArticleBlock.swift
    │   │   │   ├── ArticleDocument.swift
    │   │   │   └── ArticleSectionDTO.swift
    │   │   ├── ViewModels/              # Бизнес-логика
    │   │   │   ├── ArticleEditorViewModel.swift
    │   │   │   └── ArticleLibraryViewModel.swift
    │   │   └── Renderer/                # Рендеринг статей
    │   │       └── ArticleRenderer.swift
    │   └── Package.swift
    └── SharedKit/                       # Общие компоненты
        └── Sources/SharedKit/
            ├── Services/
            │   └── LocalizationManager.swift
            └── UI/
                └── LoadingView.swift
```

### 🔄 Поток данных
```
ArticleLibraryView (InGermanyCMS)
    ↓
ArticleLibraryViewModel (ArticleKit) 
    ↓  
FileManager (Documents/) ←→ ArticleDocument
    ↓
ArticleEditorView ←→ ArticleEditorViewModel
    ↓  
ArticleRenderer (Live Preview) ←→ ArticleSectionDTO
```

## 📊 СТАТУС РЕАЛИЗАЦИИ (ОБНОВЛЕНО)

### ✅ **ВЫПОЛНЕНО - МОДУЛЬНАЯ АРХИТЕКТУРА**

#### 🔹 Созданы Swift Packages
- [x] **ArticleKit** - полный пакет для работы со статьями
- [x] **SharedKit** - общие сервисы и UI компоненты
- [x] **Настроены зависимости** между пакетами и приложениями

#### 🔹 Кросс-платформенная поддержка
- [x] **Единый код** для iOS и macOS
- [x] **ArticleKit** работает в обоих приложениях
- [x] **InGermanyCMS** - отдельное macOS приложение

#### 🔹 Функциональность редактора
- [x] **ArticleLibraryView** - библиотека статей с файловой системой
- [x] **Создание статей** - генерация новых ArticleDocument
- [x] **Управление статьями** - удаление, обновление метаданных
- [x] **Навигация** между библиотекой и демо-просмотром

#### 🔹 Рендеринг статей
- [x] **ArticleRenderer** - полная поддержка всех типов блоков
- [x] **DemoArticleView** - работающее демо с JSON статьями
- [x] **Совместимость форматов** - единый ArticleSectionDTO

### 🚧 **В РАЗРАБОТКЕ**

#### 🔹 ArticleEditorView
- [ ] **Визуальный редактор** блоков в реальном времени
- [ ] **Drag & Drop** сортировка блоков
- [ ] **Live Preview** синхронизация с редактором

#### 🔹 Управление блоками
- [ ] **Добавление/удаление** блоков разных типов
- [ ] **Редактирование контента** для каждого типа блока
- [ ] **BlockPickerView** интеграция

### 📋 **ПЛАНИРУЕТСЯ**

#### 🔹 Расширение функциональности
- [ ] **Экспорт/Импорт JSON** с файловым диалогом
- [ ] **Undo/Redo** поддержка
- [ ] **Автосохранение** черновиков
- [ ] **Горячие клавиши** для macOS

#### 🔹 Git интеграция
- [ ] **GitPublisher** сервис для автоматических коммитов
- [ ] **Publish функциональность** - push в удаленный репозиторий
- [ ] **Статус синхронизации** в UI

---

## 🎯 БЛИЖАЙШИЕ ЗАДАЧИ

### 1. **Завершить ArticleEditorView** (ВЫСОКИЙ ПРИОРИТЕТ)
- Реализовать основной интерфейс редактора
- Настроить связь ArticleEditorView ↔ ArticleEditorViewModel
- Добавить панель инструментов для управления блоками

### 2. **Интеграция BlockPicker** (ВЫСОКИЙ ПРИОРИТЕТ) 
- Подключить существующий BlockPickerView
- Реализовать добавление новых блоков в статью
- Настроить редактирование свойств блоков

### 3. **Live Preview система** (СРЕДНИЙ ПРИОРИТЕТ)
- Синхронизация изменений между редактором и превью
- Split-view интерфейс для macOS
- Оптимизация производительности рендеринга

### 4. **Функциональность файловых операций** (СРЕДНИЙ ПРИОРИТЕТ)
- Диалоги сохранения/загрузки для macOS
- Поддержка drag & drop файлов
- Автоопределение изменений в файловой системе

---

## 🔧 ТЕХНИЧЕСКИЕ ДЕТАЛИ РЕАЛИЗАЦИИ

### 📁 Формат хранения статей
```swift
// ArticleDocument - основная модель статьи
public struct ArticleDocument: Codable {
    public let title: String
    public let sections: [ArticleSectionDTO]
}
```

### 🔄 Преобразование моделей
```swift
// ArticleBlock (редактор) ↔ ArticleSectionDTO (рендерер)
ArticleBlock.fromSection(_:)    // DTO → Editor model
ArticleBlock.toSectionDTO()     // Editor model → DTO
```

### 🎨 Поддерживаемые типы блоков
```swift
public enum BlockType: String, CaseIterable {
    case paragraph, info, warning, tip, quote
    case checklist, faq, list, links, image
}
```

---

## 🚀 ИНСТРУКЦИЯ ДЛЯ ПРОДОЛЖЕНИЯ РАЗРАБОТКИ

### 📌 Текущий фокус
**Завершение базового редактора статей** с последующей интеграцией Git-публикации.

### 🔄 Рабочий процесс
1. **ArticleLibraryView** → выбор/создание статьи
2. **ArticleEditorView** → редактирование контента  
3. **Live Preview** → мгновенный просмотр изменений
4. **Save/Publish** → сохранение + Git коммит

### 🛠 Технический стек
- **SwiftUI** + **Combine** для реактивного UI
- **FileManager** для локального хранения
- **Swift Package Manager** для модульности
- **Git интеграция** через shell commands

### 🎯 Критерии успеха
- [ ] Статьи редактируются в визуальном редакторе
- [ ] Изменения сохраняются в JSON файлы
- [ ] Live Preview показывает актуальный результат
- [ ] Git публикация работает автоматически
- [ ] Интерфейс удобен для регулярного использования

---

## 💡 ПРИМЕЧАНИЯ ДЛЯ РАЗРАБОТЧИКОВ

### Архитектурные решения
- **Модульность**: ArticleKit изолирует логику редактора
- **Кросс-платформенность**: Единый код для iOS/macOS
- **Тестируемость**: ViewModels независимы от UI

### Следующие технические шаги
1. Завершить ArticleEditorView с панелью инструментов
2. Реализовать двустороннюю связь редактор-превью  
3. Добавить диалоги файловых операций для macOS
4. Интегрировать GitPublisher сервис

### Метрики прогресса
- ✅ Модульная архитектура реализована
- ✅ Библиотека статей работает
- 🔄 Визуальный редактор в разработке
- ◻️ Git интеграция в планах

**Текущий статус 17.10.2025 **: Проект имеет прочную архитектурную основу, готова к реализации полнофункционального редактора.
```
